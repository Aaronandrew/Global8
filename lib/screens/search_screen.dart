import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:global8/screens/profile_screen.dart';
import 'package:global8/utils/colors.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:global8/providers/theme_provider.dart';

import 'comments_screen.dart';
import 'full_post_screen.dart'; // Import your theme provider

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  bool isShowUsers = false;

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
      // Use dynamic appBar color
        title: Form(
          child: TextFormField(
            controller: searchController,
            style: TextStyle(), // Dynamic text color
            decoration: InputDecoration(
              labelText: 'Search for a user...',
              labelStyle: TextStyle(), // Dynamic label color
            ),
            onFieldSubmitted: (String _) {
              setState(() {
                isShowUsers = true;
              });
            },
          ),
        ),
      ),
      body: isShowUsers
          ? FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('users')
            .where(
          'username',
          isGreaterThanOrEqualTo: searchController.text,
        )
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
            itemCount: (snapshot.data! as dynamic).docs.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(
                      uid: (snapshot.data! as dynamic).docs[index]['uid'],
                    ),
                  ),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                      (snapshot.data! as dynamic).docs[index]['photoUrl'],
                    ),
                    radius: 16,
                  ),
                  title: Text(
                    (snapshot.data! as dynamic).docs[index]['username'],
                    style: TextStyle(), // Dynamic text color
                  ),
                ),
              );
            },
          );
        },
      )
          : FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('posts')
            .orderBy('datePublished')
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1, // Ensures a square shape
            ),
            itemCount: (snapshot.data! as dynamic).docs.length,
            itemBuilder: (context, index) {
              final post = (snapshot.data! as dynamic).docs[index];
              final currentUser = FirebaseAuth.instance.currentUser;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullPostScreen(
                        postData: post,
                        isOwner: post['uid'] == currentUser?.uid,
                        isLiked: (post['likes'] ?? []).contains(currentUser?.uid),
                        likeCount: (post['likes'] ?? []).length,
                        commentCount: post.data().containsKey('commentCount') ? post['commentCount'] : 0,
                        onLikePressed: () {
                          // Like logic
                        },
                        onDeletePressed: () {
                          // Delete logic
                        },
                        onCommentPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CommentsScreen(postId: post['postId']),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
                child: Image.network(
                  post['postUrl'],
                  fit: BoxFit.cover,
                ),
              );

            },
          );

        },
      ),
    );
  }

}
