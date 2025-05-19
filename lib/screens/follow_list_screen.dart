// follow_list_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FollowListScreen extends StatelessWidget {
  final String uid;
  final String listType; // 'followers' or 'following'

  const FollowListScreen({super.key, required this.uid, required this.listType});

  Future<List<DocumentSnapshot>> fetchUsers(String listType) async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final ids = List<String>.from(userDoc.data()?[listType] ?? []);

    if (ids.isEmpty) return [];

    final usersQuery = await FirebaseFirestore.instance
        .collection('users')
        .where(FieldPath.documentId, whereIn: ids)
        .get();

    return usersQuery.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${listType.capitalize()}')),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: fetchUsers(listType),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final users = snapshot.data!;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final userId = user.id;
              final username = user['username'];
              final photoUrl = user['photoUrl'];

              return ListTile(
                leading: CircleAvatar(backgroundImage: NetworkImage(photoUrl)),
                title: Text(username),
                trailing: FollowButton(targetUserId: userId),
              );
            },
          );
        },
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() => '${this[0].toUpperCase()}${substring(1)}';
}

class FollowButton extends StatefulWidget {
  final String targetUserId;
  const FollowButton({super.key, required this.targetUserId});

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  bool isFollowing = false;
  bool isOwnProfile = false;
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    checkFollowingStatus();
  }

  Future<void> checkFollowingStatus() async {
    if (currentUserId == widget.targetUserId) {
      setState(() => isOwnProfile = true);
      return;
    }

    final currentUserDoc = await FirebaseFirestore.instance.collection('users').doc(currentUserId).get();
    final followingList = List<String>.from(currentUserDoc['following'] ?? []);
    setState(() => isFollowing = followingList.contains(widget.targetUserId));
  }

  Future<void> toggleFollow() async {
    final userRef = FirebaseFirestore.instance.collection('users');
    final currentUserRef = userRef.doc(currentUserId);
    final targetUserRef = userRef.doc(widget.targetUserId);

    if (isFollowing) {
      await currentUserRef.update({
        'following': FieldValue.arrayRemove([widget.targetUserId])
      });
      await targetUserRef.update({
        'followers': FieldValue.arrayRemove([currentUserId])
      });
    } else {
      await currentUserRef.update({
        'following': FieldValue.arrayUnion([widget.targetUserId])
      });
      await targetUserRef.update({
        'followers': FieldValue.arrayUnion([currentUserId])
      });
    }

    setState(() => isFollowing = !isFollowing);
  }

  @override
  Widget build(BuildContext context) {
    if (isOwnProfile) return const SizedBox.shrink();
    return TextButton(
      onPressed: toggleFollow,
      child: Text(isFollowing ? 'Unfollow' : 'Follow Back'),
    );
  }
}
