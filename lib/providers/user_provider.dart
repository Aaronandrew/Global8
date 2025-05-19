import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:global8/models/user.dart';
import 'package:global8/resources/auth_methods.dart';

class UserNotifier extends StateNotifier<User?> {
  final Ref ref;

  UserNotifier(this.ref) : super(null) {
    fetchUserData(); // Fetch user data when the notifier is initialized
  }

  Future<void> fetchUserData() async {
    try {
      final authMethods = ref.read(authMethodsProvider);
      final user = await authMethods.getUserDetails();
      debugPrint("User fetched successfully: ${user.uid}");
      state = user;
    } catch (e) {
      debugPrint("Error fetching user data: $e");
      state = null;
    }
  }

  void clearUser() {
    state = null;
  }

  Future<void> refreshUser(String uid) async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        state = User.fromSnap(userDoc);
      }
    } catch (e) {
      debugPrint("Error refreshing user: $e");
    }
  }
}

// Define the user provider globally
final userProvider = StateNotifierProvider<UserNotifier, User?>((ref) {
  return UserNotifier(ref);
});

// Provider for AuthMethods
final authMethodsProvider = Provider<AuthMethods>((ref) {
  return AuthMethods();
});

