import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:global8/utils/colors.dart';
import 'package:global8/utils/global_variable.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MobileScreenLayout extends StatefulWidget {
  const MobileScreenLayout({Key? key}) : super(key: key);


  @override
  State<MobileScreenLayout> createState() => _MobileScreenLayoutState();
}

class _MobileScreenLayoutState extends State<MobileScreenLayout> {
  int _page = 0;
  late PageController pageController; // for tabs animation


  @override
  void initState() {
    super.initState();
    pageController = PageController();
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
    //Animating Page
    pageController.jumpToPage(page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: pageController,
        onPageChanged: onPageChanged,
        children: homeScreenItems,
      ),
      bottomNavigationBar: Container(
        color: Color(0xFFB2B1B1),
        height: 80,
        alignment: Alignment.bottomCenter,
          padding: const EdgeInsets.all(2.0),
        child: CupertinoTabBar(
          backgroundColor: Color(0xFFB2B1B1),
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Align(

                alignment: Alignment.bottomCenter,
                child: SvgPicture.asset(
                  'assests/images/Vector.svg',
                  color: (_page == 0) ? primaryColor : secondaryColor,
                  alignment: Alignment.bottomCenter,
                  

                ),
              ),
              label: '',
              backgroundColor: primaryColor,
            ),
            BottomNavigationBarItem(
              icon: Align(
                alignment: Alignment.center,
                child: Icon(
                  Icons.add_circle,
                  color: (_page == 1) ? primaryColor : secondaryColor,
                ),
              ),
              label: '',
              backgroundColor: primaryColor,
            ),
            BottomNavigationBarItem(
              icon: Align(
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  'assests/images/globe2.svg',
                  color: (_page == 2) ? primaryColor : secondaryColor,
                ),
              ),
              label: '',
              backgroundColor: primaryColor,
            ),
            BottomNavigationBarItem(
              icon: Align(
                alignment: Alignment.center,
                child: Icon(
                  Icons.search_rounded,
                  color: (_page == 3) ? primaryColor : secondaryColor,
                ),
              ),
              label: '',
              backgroundColor: primaryColor,
            ),
            BottomNavigationBarItem(
              icon: Align(
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  'assests/images/paragraph.svg',
                  color: (_page == 4) ? primaryColor : secondaryColor,
                ),
              ),
              label: '',
              backgroundColor: primaryColor,
            ),
          ],
        onTap: navigationTapped,
        currentIndex: _page,
      ),
      ),
    );
  }
}
