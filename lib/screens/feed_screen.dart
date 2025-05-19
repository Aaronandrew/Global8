import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:global8/screens/MapScreen.dart';
import 'package:global8/screens/add_post_screen.dart';
import 'package:global8/utils/colors.dart';
import 'package:global8/widgets/post_card.dart';
import 'package:global8/providers/theme_provider.dart';

import '../providers/user_provider.dart'show userProvider; // Ensure you have a theme provider

class FeedScreen extends ConsumerWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final user = ref.watch(userProvider);
    return Scaffold(

      appBar: AppBar(

        title: Text(
          "Community",
            style: TextStyle(

              fontSize: 24,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.white,
                  offset: Offset(1, 1),
                  blurRadius: 3,
                ),
              ],
            ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.add,),
          onPressed: () {
            if (user != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddPostScreen(userId: user.uid),  // Pass the user object
                ),
              );
            } else {
              // Handle the null case, maybe show a loading spinner or an error message
              debugPrint("User is null, cannot navigate to AddPostScreen.");
            }
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.map_outlined,),
            onPressed: () {
              try {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MapScreen()),
                );
              } catch (e) {
                print("Error navigating to MapScreen: $e");
              }
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('posts').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (ctx, index) {
              var post = snapshot.data!.docs[index].data();
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 1),
                child: PostCard(snap: post),
              );
            },
          );
        },
      ),
    );
  }
}

