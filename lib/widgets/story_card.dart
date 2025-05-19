import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/story_comment.dart';
import '../models/user.dart'as model;
import '../providers/user_provider.dart';
import 'story_comment_card.dart';

class StoryCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> snap;
  const StoryCard({super.key, required this.snap});

  @override
  ConsumerState<StoryCard> createState() => _StoryCardState();
}

class _StoryCardState extends ConsumerState<StoryCard> {
  int likeCount = 0;
  bool isLiked = false;
  final TextEditingController _commentController = TextEditingController();
  List<StoryComment> comments = [];
  bool showComments = false;
  String? username;
  String? profImage;

  @override
  void initState() {
    super.initState();
    fetchPostUserData();
    fetchLikeStatus();
    fetchComments();
  }


  fetchPostUserData() async {
    try {
      DocumentSnapshot userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.snap['uid'])
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


  fetchLikeStatus() async {
    try {
      DocumentSnapshot snap = await FirebaseFirestore.instance
          .collection('story')
          .doc(widget.snap['storyId'])
          .get();
      List likes = snap['likes'] ?? [];
      final model.User? user = ref.read(userProvider);
      setState(() {
        likeCount = likes.length;
        isLiked = user != null && likes.contains(user.uid);
      });
    } catch (err) {
      print(err.toString());
    }
  }

  fetchComments() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('story')
          .doc(widget.snap['storyId'])
          .collection('commentsStory')
          .orderBy('datePublished', descending: true)
          .get();

      setState(() {
        comments = snap.docs.map((doc) => StoryComment.fromSnap(doc)).toList();
      });
    } catch (err) {
      print(err.toString());
    }
  }

  postComment() async {
    final model.User? user = ref.read(userProvider);
    if (user == null || _commentController.text.trim().isEmpty) return;

    String commentId = const Uuid().v4();
    StoryComment newComment = StoryComment(
      commentId: commentId,
      storyId: widget.snap['storyId'],
      uid: user.uid,
      username: user.username,
      profImage: user.photoUrl,
      commentText: _commentController.text.trim(),
      datePublished: DateTime.now(),
    );

    try {
      await FirebaseFirestore.instance
          .collection('story')
          .doc(widget.snap['storyId'])
          .collection('commentsStory')
          .doc(commentId)
          .set(newComment.toJson());

      setState(() {
        comments.insert(0, newComment);
      });

      _commentController.clear();
    } catch (err) {
      print(err.toString());
    }
  }

  likePost() async {
    final model.User? user = ref.read(userProvider);
    String storyId = widget.snap['storyId'];

    setState(() {
      isLiked = !isLiked;
      likeCount += isLiked ? 1 : -1;
    });

    try {
      if (isLiked) {
        await FirebaseFirestore.instance.collection('story').doc(storyId).update({
          'likes': FieldValue.arrayUnion([user?.uid])
        });
      } else {
        await FirebaseFirestore.instance.collection('story').doc(storyId).update({
          'likes': FieldValue.arrayRemove([user?.uid])
        });
      }
    } catch (err) {
      setState(() {
        isLiked = !isLiked;
        likeCount += isLiked ? -1 : 1;
      });
      print(err.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = '';
    if (widget.snap['datePublished'] is Timestamp) {
      Timestamp timestamp = widget.snap['datePublished'];
      formattedDate = DateFormat('MMM dd, yyyy').format(timestamp.toDate());
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 1),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color.fromRGBO(50, 21, 229, .34), // Dark background color for story card
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: profImage != null && profImage!.isNotEmpty
                    ? NetworkImage(profImage!)
                    : const AssetImage('assets/images/g8.jpg') as ImageProvider,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username ?? 'Loading...',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedDate.isNotEmpty ? formattedDate : 'Loading...',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              _buildMoreMenu(),
            ],
          ),

          const SizedBox(height: 8),

          // Story Content
          Text(
            widget.snap['description'] ?? '',
            style: const TextStyle(color: Colors.white),
          ),

          const SizedBox(height: 8),

          // Like & Comment Row
          Row(
            children: [
              IconButton(
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.red : Colors.white,
                ),
                onPressed: likePost,
              ),
              Text('$likeCount', style: const TextStyle(color: Colors.white)),
              IconButton(
                icon: Icon(
                  showComments ? Icons.comment : Icons.comment_outlined,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    showComments = !showComments;
                  });
                },
              ),
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: "Leave a comment...",
                    hintStyle: TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.deepPurple.shade300,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white60),
                      onPressed: postComment,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Display Comments if toggled
          if (showComments)
            Column(
              children: comments.map((comment) => StoryCommentCard(comment: comment)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildMoreMenu() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.white60),
      onSelected: (value) => print("Selected action: $value"),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'edit', child: Text('Edit')),
        const PopupMenuItem(value: 'delete', child: Text('Delete')),
      ],
    );
  }
}








