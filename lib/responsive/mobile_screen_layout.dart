import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:global8/providers/navigation_provider.dart';
import 'package:global8/providers/user_provider.dart'  as user_provider;

import 'package:global8/screens/Stories_screen.dart';
import 'package:global8/screens/feed_screen.dart';
import 'package:global8/screens/profile_screen.dart';



class MobileScreenLayout extends ConsumerStatefulWidget {
  const MobileScreenLayout({super.key});

  @override
  ConsumerState<MobileScreenLayout> createState() => _MobileScreenLayoutState();
}

class _MobileScreenLayoutState extends ConsumerState<MobileScreenLayout> {
  late PageController pageController;

  @override
  @override
  void initState() {
    super.initState();
    pageController = PageController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchUserData(); // ✅ safe
    });
  }


  Future<void> fetchUserData() async {
    final user = ref.read(user_provider.userProvider); // Sync read is fine here
    if (user != null && mounted) {
      ref.read(navigationProvider.notifier).updateUserData(
        username: user.username ?? 'Guest',
        profilePic: user.photoUrl ?? '', uid: '',
      );
    }
  }


  void onPageChanged(int page) {
    ref.read(navigationProvider.notifier).updatePage(page, context);
  }

  void navigationTapped(int page) {
    ref.read(navigationProvider.notifier).updatePage(page, context);
    pageController.animateToPage(page, duration: const Duration(milliseconds: 300), curve: Curves.ease);
  }



  @override
  Widget build(BuildContext context) {
    final navState = ref.watch(navigationProvider);
    final user = ref.watch(user_provider.userProvider); // Watch for user updates

    return Scaffold(

      body: PageView(
        controller: pageController,
        onPageChanged: onPageChanged,
        children: [
          ProfileScreen(uid: user?.uid ?? ''), // Profile screen
          FeedScreen(), // Feed screen
          StoriesScreen(), // Stories screen
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.deepPurple,
        height: 90,
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.all(0.0),
        child: CupertinoTabBar(
          backgroundColor: Colors.deepPurple,
          items: <BottomNavigationBarItem>[
            _buildNavItem('assets/images/Vector.svg', 0, "Profile"),
            _buildNavItem('assets/images/globe2.svg', 1, "Feed"),
            _buildNavItem('assets/images/paragraph.svg', 2, "Stories"),
          ],
          onTap: navigationTapped,
          currentIndex: navState.currentPage, // Use the current page from the provider
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(String icon, int index, String label) {
    final navState = ref.watch(navigationProvider);
    return BottomNavigationBarItem(
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            icon,
            color: (navState.currentPage == index) ? Colors.purpleAccent : Colors.white,
            height: 30,
            width: 40,
          ),
          const SizedBox(height: 4),
        ],
      ),
      label: label,
    );
  }
}





