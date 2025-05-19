import 'package:flutter/material.dart';

class FullPostScreen extends StatelessWidget {
  final dynamic postData;
  final bool isOwner;
  final bool isLiked;
  final int likeCount;
  final int commentCount;
  final VoidCallback? onLikePressed;
  final VoidCallback? onDeletePressed;
  final VoidCallback? onCommentPressed;

  const FullPostScreen({
    super.key,
    required this.postData,
    this.isOwner = false,
    this.isLiked = false,
    this.likeCount = 0,
    this.commentCount = 0,
    this.onLikePressed,
    this.onDeletePressed,
    this.onCommentPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Fullscreen image
          if (postData['postUrl'] != null)
            SizedBox.expand(
              child: Image.network(
                postData['postUrl'],
                fit: BoxFit.cover,
              ),
            ),

          // Top controls including back button inside SafeArea
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.6),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  // Optional delete button if owner
                  if (isOwner)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.white),
                      onPressed: onDeletePressed,
                    ),
                ],
              ),
            ),
          ),

          // Like and comment actions
          Positioned(
            top: 80,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : Colors.white,
                  ),
                  onPressed: onLikePressed,
                ),
                Text(
                  likeCount.toString(),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.comment, color: Colors.white),
                  onPressed: onCommentPressed,
                ),
                Text(
                  commentCount.toString(),
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),

          // Description at the bottom
          Positioned(
            bottom: 40,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                postData['description'] ?? '',
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


