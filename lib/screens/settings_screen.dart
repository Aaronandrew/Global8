import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:global8/Settings/notifications.dart';
import 'package:global8/screens/login_screen.dart';
import 'package:global8/Settings/edit_profile_screen.dart';
import 'package:global8/resources/auth_methods.dart';
import 'package:global8/providers/theme_provider.dart';
import 'package:global8/providers/navigation_provider.dart';

import '../Settings/About.dart';
import '../Settings/Account.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<String> fetchUid() async {
    try {
      return AuthMethods().getCurrentUserUid();
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching UID: $e");
      }
      return '';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Scaffold(

      appBar: AppBar(

        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',

        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<String>(
          future: fetchUid(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("Error fetching UID"));
            } else {
              return Column(
                children: [
                  _buildSettingsOption(context, Icons.lock, 'Account', const AccountScreen()),
                  _buildSettingsOption(context, Icons.notifications, 'Notifications', const NotifyScreen()),
                  _buildSettingsOption(context, Icons.edit, 'Edit Profile', EditProfileScreen(userData: {})),
                  _buildSettingsOption(context, Icons.account_box_outlined, 'About', const AboutScreen()),

                  const Spacer(),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.logout, ),
                    title: Text(
                      'Logout',

                    ),
                    onTap: () async {
                      try {
                        await AuthMethods().signOut();

                        if (context.mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                                (route) => false,
                          );
                        }
                      } catch (e) {
                        if (kDebugMode) {
                          print('Error logging out: $e');
                        }
                      }
                    },
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildSettingsOption(
      BuildContext context,
      IconData icon,
      String title,
      Widget screen,
      ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: colorScheme.primary),
          title: Text(title, style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onBackground)),
          trailing: Icon(Icons.arrow_forward_ios, color: colorScheme.primary),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
          },
        ),
        Divider(color: theme.dividerColor),
      ],
    );
  }
}





