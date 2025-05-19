import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String message;
  final String type;
  final String postId;
  final String storyId; // For story notifications
  final String fromUserId;
  final Timestamp timestamp;
  final List<String> comments; // New field for comments
  final String? followerUserId; // Added field for follower notifications
  final bool? isFollowed; // Field to track if the user was followed or unfollowed

  NotificationModel({
    required this.message,
    required this.type,
    required this.postId,
    required this.storyId,
    required this.fromUserId,
    required this.timestamp,
    required this.comments,
    this.followerUserId,
    this.isFollowed,
  });

  // Factory constructor to create NotificationModel from Firestore data
  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return NotificationModel(
      message: data['message'] ?? '',
      type: data['type'] ?? '',
      postId: data['postId'] ?? '',
      storyId: data['storyId'] ?? '',
      fromUserId: data['fromUserId'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      comments: List<String>.from(data['comments'] ?? []),
      followerUserId: data['followerUserId'],
      isFollowed: data['isFollowed'],
    );
  }

  // Method to convert NotificationModel to a Map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'type': type,
      'postId': postId,
      'storyId': storyId,
      'fromUserId': fromUserId,
      'timestamp': timestamp,
      'comments': comments,
      'followerUserId': followerUserId,
      'isFollowed': isFollowed,
    };
  }
}
