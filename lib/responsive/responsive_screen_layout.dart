import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../main.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../utils/global_variable.dart';

class ResponsiveLayout extends ConsumerStatefulWidget {
  final Widget webScreenLayout;
  final Widget mobileScreenLayout;
  const ResponsiveLayout({super.key, required this.webScreenLayout, required this.mobileScreenLayout});

  @override
  ConsumerState<ResponsiveLayout> createState() => _ResponsiveLayoutState();
}

class _ResponsiveLayoutState extends ConsumerState<ResponsiveLayout> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    addData(); // Fetch user data, theme preference, and request permission
  }

  Future<void> addData() async {
    try {
      // 1. Check User Authentication
      final authState = ref.read(authProvider).value;
      if (authState != null) {
        // 2. Fetch User Data
        await ref.read(userProvider.notifier).refreshUser(authState.uid);
      }

      // 3. Initialize App Theme


      // 4. Request Notification Permissions using FirebaseMessaging API
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('User granted notification permission');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        debugPrint('User granted provisional notification permission');
      } else {
        debugPrint('User declined or has not accepted notification permission');
      }
    } catch (error) {
      debugPrint('Error in addData(): $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > webScreenSize) {
          // Web Screen
          return widget.webScreenLayout;
        }
        // Mobile screen
        return widget.mobileScreenLayout;
      },
    );
  }
}


