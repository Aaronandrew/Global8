import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:global8/screens/login_screen.dart';
import 'package:global8/utils/colors.dart';
import 'package:global8/firebase_options.dart';
import 'package:global8/providers/user_provider.dart'; // Import User Provider
import 'package:global8/providers/navigation_provider.dart'; // Import Navigation Provider


// Theme state provider (Riverpod)
final themeProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<bool> {
  ThemeNotifier() : super(false); // Default to light mode

  void toggleTheme() {
    state = !state; // Toggle between dark and light modes
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
   options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ProviderScope(
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    final user = ref.watch(userProvider); // Watch for user data
    final navState = ref.watch(navigationProvider); // Get navigation state

    // Check if the user state is loading or null

      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Global 8',
        theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: primaryColorLight,
          scaffoldBackgroundColor: startBackgroundColorLight,
          appBarTheme: AppBarTheme(backgroundColor: appBarColorLight),
          textTheme: TextTheme(
            titleLarge: TextStyle(color: textColorLight),
            bodyLarge: TextStyle(color: textColorLight),
            bodyMedium: TextStyle(color: textColorLight),
          ),
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: primaryColorDark,
          scaffoldBackgroundColor: startBackgroundColorDark,
          appBarTheme: AppBarTheme(backgroundColor: appBarColorDark),
          textTheme: TextTheme(
            titleLarge: TextStyle(color: textColorDark),
            bodyLarge: TextStyle(color: textColorDark),
            bodyMedium: TextStyle(color: textColorDark),
          ),
        ),
        themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
        home: const LoginScreen(), // If user is null, show LoginScreen
      );


    // If user is authenticated, show the home screen (profile screen or main app layout)

  }
}







