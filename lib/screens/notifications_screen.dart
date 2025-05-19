import 'package:flutter/material.dart';
import 'package:global8/models/notification.dart'; // Import the NotificationModel
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:global8/screens/profile_screen.dart';
import '../providers/notifications_provider.dart'; // Notifications Provider
import '../utils/colors.dart'; // Import custom colors file

class NotificationsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsyncValue = ref.watch(notificationsProvider('userId')); // Replace with actual userId

    // Check if the app is in light or dark mode
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: isDarkMode ? appBarColorDark : appBarColorLight, // Dynamic app bar color
      ),
      body: notificationsAsyncValue.when(
        data: (notifications) {
          return notifications.isEmpty
              ? Center(
            child: Text(
              'No new notifications',
              style: TextStyle(
                color: isDarkMode ? textColorDark : textColorLight, // Dynamic text color
              ),
            ),
          )
              : ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              NotificationModel notification = notifications[index] as NotificationModel;
              return ListTile(
                leading: Icon(
                  Icons.notifications,
                  color: isDarkMode ? secondaryColorDark : primaryColorLight, // Dynamic icon color
                ),
                title: Text(
                  notification.message,
                  style: TextStyle(
                    color: isDarkMode ? textColorDark : textColorLight, // Dynamic text color
                  ),
                ),
                subtitle: Text(
                  'Type: ${notification.type}',
                  style: TextStyle(
                    color: isDarkMode ? secondaryColorDark : textColorLight, // Dynamic subtitle color
                  ),
                ),
                trailing: Text(
                  '${notification.timestamp.toDate()}',
                  style: TextStyle(
                    color: isDarkMode ? secondaryColorDark : textColorLight, // Dynamic timestamp color
                  ),
                ),
                onTap: () {
                  if (notification.type == 'follow' || notification.type == 'unfollow') {
                  /*  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(userId: notification.followerUserId!),
                      ),
                    );*/
                  } else if (notification.type == 'like' || notification.type == 'comment') {
                    /*Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PostDetailScreen(postId: notification.postId),
                      ),
                    );

                     */
                  } else if (notification.type == 'story') {
                  /*  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StoryDetailScreen(storyId: notification.storyId),
                      ),
                    );*/
                  }
                },
              );
            },
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text(
            'Error: $error',
            style: TextStyle(
              color: isDarkMode ? textColorDark : textColorLight, // Dynamic error text color
            ),
          ),
        ),
      ),
    );
  }
}


