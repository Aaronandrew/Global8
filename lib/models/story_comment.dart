import 'package:cloud_firestore/cloud_firestore.dart';

class StoryComment {
  final String commentId;
  final String storyId;
  final String uid;
  final String username;
  final String commentText;
  final DateTime datePublished;
  final String profImage;

  StoryComment({
    required this.commentId,
    required this.storyId,
    required this.uid,
    required this.username,
    required this.commentText,
    required this.datePublished,
    required this.profImage,
  });

  factory StoryComment.fromJson(Map<String, dynamic> json) {
    return StoryComment(
      commentId: json['commentId'],
      storyId: json['storyId'],
      uid: json['uid'],
      username: json['username'],
      commentText: json['commentText'],
      datePublished: (json['datePublished'] as Timestamp).toDate(),
      profImage: json['profImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'commentId': commentId,
      'storyId': storyId,
      'uid': uid,
      'username': username,
      'commentText': commentText,
      'datePublished': datePublished,
      'profImage': profImage,
    };
  }

  static StoryComment fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return StoryComment.fromJson(snapshot);
  }
}

