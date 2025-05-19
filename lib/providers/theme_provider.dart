import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Define a provider to manage the theme mode (dark or light)
final themeProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<bool> {
  ThemeNotifier() : super(false); // default to light mode (false)

  // Toggle theme between dark and light mode
  void toggleTheme() {
    state = !state;
  }
  Future<bool?> fetchUserThemePreference() async {
    try {
      final auth = FirebaseAuth.instance;
      final user = auth.currentUser;
      if (user == null) return null;

      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return doc.data()?['isDarkMode'] as bool?; // Get theme preference
      }
    } catch (e) {
      debugPrint("Error fetching theme preference: $e");
    }
    return null;

  }

  void updateTheme(bool isDarkMode) async {
    try {
      final auth = FirebaseAuth.instance;
      final user = auth.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'isDarkMode': isDarkMode,
      });

      state = isDarkMode; // Update theme state
    } catch (e) {
      debugPrint("Error updating theme: $e");
    }
  }

}
