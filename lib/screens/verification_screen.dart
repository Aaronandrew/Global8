import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:global8/screens/profile_creation_sceen.dart'; // Correct import for ProfileCreationPage

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool isEmailVerified = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    var user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified) {
      user.sendEmailVerification();
    }
    // Check email verification every 3 seconds
    timer = Timer.periodic(const Duration(seconds: 3), (_) => checkEmailVerified());
  }

  // Check if the email is verified
  checkEmailVerified() async {
    var user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await user.reload();
    setState(() {
      isEmailVerified = user.emailVerified;
    });

    if (isEmailVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email Successfully Verified"))
      );
      timer?.cancel();
      // Navigate to Profile Creation screen after email verification
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ProfileCreationPage())
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: isEmailVerified
            ? const Center(
          child: Text(
            "Email Successfully Verified",
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
          ),
        )
            : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 35),
              const SizedBox(height: 30),
              const Center(
                child: Text(
                  'Check your Email',
                  textAlign: TextAlign.center, style: TextStyle(color: Colors.black)
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Center(
                  child: Text(
                    'We have sent you an Email to ${FirebaseAuth.instance.currentUser?.email ?? "your email"}',
                    textAlign: TextAlign.center, style: TextStyle(color: Colors.black)
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.0),
                child: Center(
                  child: Text(
                    'Verifying email....',
                    textAlign: TextAlign.center, style: TextStyle(color: Colors.black)

                  ),
                ),
              ),
              const SizedBox(height: 57),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: ElevatedButton(
                  child: const Text('Resend', style: TextStyle(color: Colors.black)),
                  onPressed: () async {
                    try {
                      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Verification email sent!"))
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error: $e"))
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
