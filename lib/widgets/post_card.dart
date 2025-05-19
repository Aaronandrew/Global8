import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:global8/models/user.dart' as model;
import 'package:global8/providers/user_provider.dart' show userProvider;
import 'package:global8/screens/comments_screen.dart' as commentsScreen;
import 'package:video_player/video_player.dart';

import '../main.dart';
import '../utils/colors.dart';

class PostCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> snap;
  const PostCard({super.key, required this.snap});

  @override
  ConsumerState<PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<PostCard> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  int commentLen = 0;
  bool isLikeAnimating = false;
  bool isSaved = false;
  String? username;
  String? profImage;

  @override
  void initState() {
    super.initState();
    fetchCommentLen();
    fetchPostUserData(); // Fetch only the post creator's data
    checkIfSaved();
    fetchLikeStatus();

    if (widget.snap['mediaType'] == 'video') {
      _videoController = VideoPlayerController.network(widget.snap['postUrl'])
        ..initialize().then((_) {
          setState(() {}); // Refresh UI after video initialized
          _videoController!.setLooping(true);
          _videoController!.play();
        });
    }
  }

  fetchPostUserData() async {
    try {
      DocumentSnapshot userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.snap['uid']) // Fetch user data using post creator's UID
          .get();

      if (userSnap.exists) {
        setState(() {
          username = userSnap['username'] ?? 'Unknown User';
          profImage = userSnap['photoUrl'] ?? '';
        });
      }
    } catch (err) {
      print("Error fetching post user data: ${err.toString()}");
    }
  }

  fetchCommentLen() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.snap['postId'])
          .collection('comments')
          .get();
      commentLen = snap.docs.length;
    } catch (err) {
      if (kDebugMode) {
        print(err.toString());
      }
    }
    setState(() {});
  }

  checkIfSaved() async {
    final model.User? user = ref.read(userProvider);
    if (widget.snap['saves'] != null && widget.snap['saves'].contains(user?.uid)) {
      setState(() {
        isSaved = true;
      });
    }
  }

  savePost() async {
    final model.User? user = ref.read(userProvider);
    String postId = widget.snap['postId'] ?? '';

    setState(() {
      isSaved = !isSaved;
    });

    if (isSaved) {
      await FirebaseFirestore.instance.collection('posts').doc(postId).update({
        'saves': FieldValue.arrayUnion([user?.uid])
      });
    } else {
      await FirebaseFirestore.instance.collection('posts').doc(postId).update({
        'saves': FieldValue.arrayRemove([user?.uid])
      });
    }
  }

  bool isLiked = false; // To track if the post is liked
  int likeCount = 0; // To track the number of likes

  fetchLikeStatus() async {
    final model.User? user = ref.read(userProvider);
    String postId = widget.snap['postId'] ?? '';

    // Fetching the likes count
    try {
      DocumentSnapshot snap = await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .get();
      List likes = snap['likes'] ?? []; // Assuming likes are stored in a list
      likeCount = likes.length; // Update like count

      // Check if the current user has liked the post
      if (likes.contains(user?.uid)) {
        setState(() {
          isLiked = true;
        });
      }
    } catch (err) {
      if (kDebugMode) {
        print(err.toString());
      }
    }
  }

  likePost() async {
    final model.User? user = ref.read(userProvider);
    String postId = widget.snap['postId'] ?? '';

    // Optimistically update the UI
    setState(() {
      isLiked = !isLiked; // Toggle the like status
      likeCount += isLiked ? 1 : -1; // Increment or decrement the like count
    });

    try {
      // Update Firestore with the new like status
      if (isLiked) {
        await FirebaseFirestore.instance.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([user?.uid])
        });
      } else {
        await FirebaseFirestore.instance.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([user?.uid])
        });
      }
    } catch (err) {
      // If the Firestore update fails, revert the optimistic UI change
      setState(() {
        isLiked = !isLiked; // Revert the like status
        likeCount += isLiked ? -1 : 1; // Revert the like count
      });
    }
  }

  void showPostDetails() {
    final model.User? currentUser = ref.read(userProvider);
    bool isOwner = widget.snap['uid'] == currentUser?.uid;  // Check if the current user is the post creator

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 1.0, // Full screen when opened
          minChildSize: 1.0,
          maxChildSize: 1.0,
          builder: (_, controller) => Stack(
            children: [
              // Fullscreen Image
              if (widget.snap['postUrl'] != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(0), // No corner radius to make it fullscreen
                  child: Image.network(
                    widget.snap['postUrl'],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height, // Make the image fullscreen
                  ),
                ),
              // Overlay Buttons
              Positioned(
                top: 40, // Position buttons near the top of the screen
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Delete Icon for Post Owner
                    if (isOwner)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.white),
                        onPressed: () {
                          deletePost();
                        },
                      ),
                    Row(
                      children: [
                        // Like Button
                        IconButton(
                          icon: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? Colors.red : Colors.white,
                          ),
                          onPressed: likePost,
                        ),
                        Text(
                          likeCount.toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        // Comment Button
                        IconButton(
                          icon: const Icon(Icons.comment, color: Colors.white),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => commentsScreen.CommentsScreen(
                                  postId: widget.snap['postId'] ?? '',
                                ),
                              ),
                            );
                          },
                        ),
                        Text(
                          commentLen.toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Description at the Bottom of the Image
              Positioned(
                bottom: 40, // Position the description near the bottom of the screen
                left: 16,
                right: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6), // Semi-transparent background
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    widget.snap['description'] ?? '',
                    style: const TextStyle(color: Colors.white),
                    maxLines: 3, // Limit description to 3 lines
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void deletePost() async {
    try {
      await FirebaseFirestore.instance.collection('posts').doc(widget.snap['postId']).delete();
      Navigator.of(context).pop(); // Close the modal after deletion
    } catch (e) {
      if (kDebugMode) {
        print("Error deleting post: $e");
      }
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    final themeNotifier = ref.read(themeProvider.notifier); // Access theme notifier
    final isDarkMode = ref.watch(themeProvider); // Watch theme state

    // Dynamically choose background and text colors based on the theme
    final backgroundColor = isDarkMode ? mobileBackgroundColorDark : mobileBackgroundColorLight;
    final appBarColor = isDarkMode ? appBarColorDark : appBarColorLight;
    final textColor = isDarkMode ? textColorLight : textColorDark;
    final iconColor = isDarkMode ? iconColorLight : iconColorDark;

    final photoUrl = widget.snap['photoUrl'] ?? 'https://via.placeholder.com/150'; // Default fallback

    return GestureDetector(
      onTap: showPostDetails, // Image is now clickable to show full post
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 1),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Color.fromRGBO(50, 21, 229, .34),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.deepPurpleAccent),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER SECTION
            Row(
              children: [
                // Display the photoUrl directly from the post data
                CircleAvatar(
                  radius: 25,
                  backgroundImage: profImage != null && profImage!.isNotEmpty
                      ? NetworkImage(profImage!)
                      : const AssetImage('assets/images/g8.jpg') as ImageProvider,
                ),
                const SizedBox(width: 8),
                Text(
                  username ?? 'Loading...', // Show 'Loading...' until fetched
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    isSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: Colors.white,
                  ),
                  onPressed: savePost,
                ),
              ],
            ),
            // POST TEXT DESCRIPTION
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Text(
                widget.snap['description'] ?? '',
                style: const TextStyle(color: Colors.white),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // POST IMAGE with stacked icons at the bottom
            if (widget.snap['postUrl'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Stack(
                  children: [
                    Image.network(
                      widget.snap['postUrl'],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 400, // Full screen image within the container
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Like Button and Count
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.5), // Light purple background
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    isLiked ? Icons.favorite : Icons.favorite_border,
                                    color: isLiked ? Colors.red : Colors.white,
                                  ),
                                  onPressed: likePost,
                                ),
                                Text(
                                  likeCount.toString(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          // Comment Button and Count
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.5), // Light purple background
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.comment, color: Colors.white),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => commentsScreen.CommentsScreen(
                                          postId: widget.snap['postId'] ?? '',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                Text(
                                  commentLen.toString(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

}

