import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../screens/stories_screen.dart' as stories;
import '../screens/feed_screen.dart';
import '../screens/profile_screen.dart';
import '../providers/user_provider.dart'; // Make sure this is correct

class NavigationState {
  final int currentPage;
  final String uid;
  final String username;
  final String profilePic;

  NavigationState({
    required this.currentPage,
    required this.uid,
    required this.username,
    required this.profilePic,
  });

  NavigationState copyWith({
    int? currentPage,
    String? uid,
    String? username,
    String? profilePic,
  }) {
    return NavigationState(
      currentPage: currentPage ?? this.currentPage,
      uid: uid ?? this.uid,
      username: username ?? this.username,
      profilePic: profilePic ?? this.profilePic,
    );
  }
}

final navigationProvider =
StateNotifierProvider<NavigationNotifier, NavigationState>((ref) {
  final user = ref.watch(userProvider);

  return NavigationNotifier(
    uid: user?.uid ?? '',
    username: user?.username ?? '',
    profilePic: user?.photoUrl ?? '',
  );
});

class NavigationNotifier extends StateNotifier<NavigationState> {
  NavigationNotifier({
    required String uid,
    required String username,
    required String profilePic,
  }) : super(NavigationState(
    currentPage: 0,
    uid: uid,
    username: username,
    profilePic: profilePic,
  ));

  void updatePage(int index, BuildContext context) {
    if (state.currentPage != index) {
      state = state.copyWith(currentPage: index);
    }
  }

  void resetNavigation() {
    state = state.copyWith(currentPage: 0);
  }

  void updateUserData({
    required String uid,
    required String username,
    required String profilePic,
  }) {
    state = state.copyWith(uid: uid, username: username, profilePic: profilePic);
  }
}

// Helper method to get screen from currentPage
Widget getScreenForIndex(NavigationState state) {
  switch (state.currentPage) {
    case 0:
      return ProfileScreen(uid: state.uid);
    case 1:
      return FeedScreen();
    case 2:
      return stories.StoriesScreen();
    default:
      return ProfileScreen(uid: state.uid);
  }
}




