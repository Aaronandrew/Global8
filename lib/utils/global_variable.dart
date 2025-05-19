import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// Alias one of the imports to avoid conflict
import 'package:global8/screens/profile_screen.dart' as profile_screen;
import 'package:global8/screens/Stories_screen.dart';
import 'package:global8/screens/add_post_screen.dart';
import 'package:global8/screens/feed_screen.dart';
import 'package:global8/screens/notifications_screen.dart';
import 'package:global8/screens/search_screen.dart';

const webScreenSize = 600;

List<Widget> homeScreenItems = <Widget>[
  profile_screen.ProfileScreen(
    uid: FirebaseAuth.instance.currentUser!.uid,
  ),
 // NotificationsScreen(),
  const FeedScreen(),
  //const SearchScreen(),
  StoriesScreen(),
];
