import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:global8/models/user.dart' as model;
import 'package:global8/resources/storage_methods.dart';
import 'package:global8/providers/user_provider.dart';

import '../providers/user_provider.dart'; // Assuming UserNotifier is defined here

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Constructor to accept a reference for UserNotifier
  final Ref? ref;

  AuthMethods({this.ref});

  // Method to get the current user's UID
  String getCurrentUserUid() {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      return currentUser.uid;
    } else {
      throw Exception("No user is currently signed in.");
    }
  }

  // Fetch user details and update the UserNotifier state
  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot documentSnapshot =
    await _firestore.collection('users').doc(currentUser.uid).get();

    final user = model.User.fromSnap(documentSnapshot);

    // Update UserNotifier state
    ref?.read(userProvider.notifier).state = user;

    return user;
  }

  // Send verification email
  Future<String> sendVerificationEmail() async {
    try {
      User? user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        return "Email sent";
      }
      return "Failed to send email verification.";
    } catch (e) {
      return e.toString();
    }
  }

  // Function to check if the email is verified within a timeout period
  Future<bool> checkEmailVerification({required Duration timeoutDuration}) async {
    User? user = _auth.currentUser;

    if (user == null) return false;

    bool isVerified = false;
    int elapsedSeconds = 0;
    Duration checkInterval = Duration(seconds: 5); // Interval to check if email is verified

    while (elapsedSeconds < timeoutDuration.inSeconds) {
      await Future.delayed(checkInterval);

      await user.reload();
      isVerified = user.emailVerified;

      if (isVerified) {
        return true; // Email is verified, exit the loop
      }

      elapsedSeconds += checkInterval.inSeconds;
    }

    return false; // Timeout reached, email is not verified
  }

  Future<String> completeUserProfile({
    required String uid,
    required String username,
    required String bio,
    required Uint8List profilePhoto,
    Uint8List? bannerPhoto,
    required String location,
    required DateTime birthday,
  }) async {
    String res = "Some error occurred";
    try {
      String profilePhotoUrl =
      await StorageMethods().uploadImageToStorage('profilePics', profilePhoto, false);
      String bannerPhotoUrl = bannerPhoto != null
          ? await StorageMethods().uploadImageToStorage('bannerPhotos', bannerPhoto, false)
          : '';

      // Update user data in Firestore
      await _firestore.collection("users").doc(uid).update({
        'username': username,
        'bio': bio,
        'photoUrl': profilePhotoUrl,
        'coverPhotoUrl': bannerPhotoUrl,
      });

      // Refresh UserNotifier state
      await ref?.read(userProvider.notifier).fetchUserData();

      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String?> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return 'Password reset email sent successfully!';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found for that email.';
      } else if (e.code == 'invalid-email') {
        return 'The email address is invalid.';
      } else {
        return 'An error occurred. Please try again later.';
      }
    } catch (e) {
      return 'Something went wrong. Please try again later.';
    }
  }

  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Some error occurred";
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Fetch user details and update UserNotifier
        await ref?.read(userProvider.notifier).fetchUserData();

        res = "success";
      } else {
        res = "Please enter all the fields";
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  Future<String> signUpUser({
    required String email,
    required String password,
    required String confirmpassword,
  }) async {
    String res = "Some error occurred";
    try {
      if (email.isNotEmpty && password.isNotEmpty && confirmpassword.isNotEmpty) {
        if (password == confirmpassword) {
          UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );

          User user = userCredential.user!;
          model.User newUser = model.User(
            username: '',
            uid: user.uid,
            email: email,
            photoUrl: '',
            coverPhotoUrl: '',
            bio: '',
            followers: [],
            following: [],
            location: '',
            birthday: null,
          );

          // Save to Firestore
          await _firestore.collection('users').doc(user.uid).set(newUser.toJson());

          // Update UserNotifier state
          ref?.read(userProvider.notifier).state = newUser;

          res = "success";
        } else {
          res = "The passwords do not match";
        }
      } else {
        res = "Please enter all the fields";
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        res = "The password provided is too weak.";
      } else if (e.code == 'email-already-in-use') {
        res = "The account already exists for that email.";
      } else {
        res = e.message ?? "An error occurred";
      }
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<void> signOut() async {
    await _auth.signOut();

    // Clear UserNotifier state
    ref?.read(userProvider.notifier).clearUser();
  }
}


