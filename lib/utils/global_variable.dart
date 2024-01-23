import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:global8/screens/add_post_screen.dart';
import 'package:global8/screens/feed_screen.dart';
import 'package:global8/screens/profile_screen.dart';
import 'package:global8/screens/search_screen.dart';


const webScreenSize = 600;

List<Widget> homeScreenItems = [
  ProfileScreen(
    uid: FirebaseAuth.instance.currentUser!.uid,
  ),
  const AddPostScreen(),
  const FeedScreen(),
  const SearchScreen(),
  const Text('feed'),
];