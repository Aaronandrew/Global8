import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:global8/resources/firestore_methods.dart';
import 'package:global8/screens/notifications_screen.dart';
import 'package:global8/screens/search_screen.dart';
import 'package:global8/utils/colors.dart';
import 'package:global8/widgets/story_card.dart';
import 'package:global8/providers/theme_provider.dart';
import 'dart:typed_data';
import 'package:global8/models/user.dart';

import '../providers/user_provider.dart';

final userProvider = StateNotifierProvider<UserNotifier, User>((ref) {
  return UserNotifier();
});

class StoriesScreen extends ConsumerWidget {
  const StoriesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {


    final TextEditingController _storyController = TextEditingController();
    final user = ref.watch(userProvider);

    Future<void> _uploadStory() async {
      if (_storyController.text.trim().isEmpty ||
          _storyController.text.split(' ').length > 30) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter a description with up to 30 words.")),
        );
        return;
      }

      String res = await FireStoreMethods().uploadStory(
        _storyController.text.trim(),
        Uint8List(0), // No image file needed for this text-based story
        user.uid,
        user.username,
        user.photoUrl,
      );

      if (res == "success") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Story uploaded successfully!")),
        );
        _storyController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res)),
        );
      }
    }

    return Scaffold(

      appBar: AppBar(

        elevation: 0,
        title: Text(
          'Stories',
            style: TextStyle(

              fontSize: 24,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 3,
                ),
              ],
            ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.notifications_none_outlined, ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NotificationsScreen()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FireStoreMethods().getStoriesStream(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No stories available.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final storyData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                    return StoryCard(snap: storyData);
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(

              border: Border(top: BorderSide(color: Colors.grey.shade700, width: 0.5)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _storyController,
                    decoration: InputDecoration(
                      hintText: 'Share a story...',
                      filled: true,
                      fillColor: Colors.grey.shade300,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.purpleAccent),
                  onPressed: _uploadStory,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class UserNotifier extends StateNotifier<User> {
  UserNotifier()
      : super(User(
    uid: '',
    username: '',
    photoUrl: '',
    coverPhotoUrl: '',
    location: '',
    email: '',
    bio: '',
    followers: [],
    following: [],
    birthday: null,
  ));

  void updateUser(User newUser) {
    state = newUser;
  }
}

