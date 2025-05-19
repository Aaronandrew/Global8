import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global8/models/user.dart';
import 'package:global8/models/notification.dart'; // Adjust with your Notification model

final notificationsProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, userId) async {
  try {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .doc(userId)  // Get notifications for the current user
        .collection('notifications')  // Notifications subcollection
        .orderBy('timestamp', descending: true)  // Order by timestamp
        .get();

    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  } catch (e) {
    throw Exception('Error fetching notifications: $e');
  }
});
