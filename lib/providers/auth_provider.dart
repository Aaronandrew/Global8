import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

final authProvider = StreamProvider<User?>((ref) {
  // This listens to the authentication state changes using FirebaseAuth.
  return FirebaseAuth.instance.authStateChanges();
});
