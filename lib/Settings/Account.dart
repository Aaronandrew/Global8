import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:global8/resources/firestore_methods.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Account Settings')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: user == null
            ? const Center(child: Text("No user found"))
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Email:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(user.email ?? 'No email'),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.sendPasswordResetEmail(email: user.email!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Password reset link sent")),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: ${e.toString()}")),
                  );
                }
              },
              child: const Text("Reset Password"),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirm Delete'),
                    content: const Text('This will delete your account and all your data permanently.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                      ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete")),
                    ],
                  ),
                );

                if (confirm == true && user != null) {
                  final result = await FireStoreMethods().deleteUserAccount(user.uid);
                  if (result == "success") {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Account deleted")),
                    );
                    // Navigate to login or welcome screen
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: $result")),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Delete Account"),
            ),
          ],
        ),
      ),
    );
  }
}
