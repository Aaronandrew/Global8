import 'package:flutter/material.dart';
import 'package:global8/utils/colors.dart';
import 'package:global8/utils/global_variable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WebScreenLayout extends ConsumerStatefulWidget {
  const WebScreenLayout({super.key});

  @override
  ConsumerState<WebScreenLayout> createState() => _WebScreenLayoutState();
}

class _WebScreenLayoutState extends ConsumerState<WebScreenLayout> {
  int _page = 0;
  late PageController pageController; // for tabs animation

  @override
  void initState() {
    super.initState();
    //pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  void navigationTapped(int page) {
    // Animating Page
    pageController.jumpToPage(page);
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color background = isDarkMode ? mobileBackgroundColorDark : mobileBackgroundColorLight;
    final Color primary = isDarkMode ? primaryColorDark : primaryColorLight;
    final Color secondary = isDarkMode ? secondaryColorDark : secondaryColorLight;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: background,
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(
              Icons.home,
              color: _page == 0 ? primary : secondary,
            ),
            onPressed: () => navigationTapped(0),
          ),
          IconButton(
            icon: Icon(
              Icons.search,
              color: _page == 1 ? primary : secondary,
            ),
            onPressed: () => navigationTapped(1),
          ),
          IconButton(
            icon: Icon(
              Icons.add_a_photo,
              color: _page == 2 ? primary : secondary,
            ),
            onPressed: () => navigationTapped(2),
          ),
          IconButton(
            icon: Icon(
              Icons.favorite,
              color: _page == 3 ? primary : secondary,
            ),
            onPressed: () => navigationTapped(3),
          ),
          IconButton(
            icon: Icon(
              Icons.person,
              color: _page == 4 ? primary : secondary,
            ),
            onPressed: () => navigationTapped(4),
          ),
        ],
      ),
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: pageController,
        onPageChanged: onPageChanged,
        children: homeScreenItems,
      ),
    );
  }
}
