import 'package:flutter/material.dart';
import 'package:global8/models/story_comment.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StoryCommentCard extends StatefulWidget {
  final StoryComment comment;

  const StoryCommentCard({super.key, required this.comment});

  @override
  _StoryCommentCardState createState() => _StoryCommentCardState();
}

class _StoryCommentCardState extends State<StoryCommentCard> {
  String username = 'Loading...';
  String profImage = '';

  @override
  void initState() {
    super.initState();
    fetchPostUserData();
  }

  Future<void> fetchPostUserData() async {
    try {
      DocumentSnapshot userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.comment.uid) // Assuming 'uid' is in the StoryComment
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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.black12, // Change this color if needed
          width: 1.5, // Adjust the border width
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Picture
          CircleAvatar(
            backgroundImage: profImage.isNotEmpty
                ? NetworkImage(profImage)
                : const AssetImage('assets/images/g8.jpg') as ImageProvider,
            radius: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display the user's name
                Text(
                  username,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                // Display the comment text
                Text(
                  widget.comment.commentText,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          // Display the comment date
          Text(
            DateFormat('MMM d, yyyy').format(widget.comment.datePublished),
            style: const TextStyle(fontSize: 12, color: Colors.white),
          ),
        ],
      ),
    );
  }
}




