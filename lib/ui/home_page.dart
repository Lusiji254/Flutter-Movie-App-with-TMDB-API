import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:movie_db/ui/popular_movies.dart';
import 'package:movie_db/ui/profile.dart';
import 'package:movie_db/ui/search.dart';
import 'package:movie_db/ui/top_rated.dart';
import 'package:movie_db/ui/favorite_movies.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

import 'login.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PersistentTabController? _controller;
  final List<Widget> _buildScreens = [
    const Movies(),
    const TopRatedMovies(),
    const FavoriteMovies(),
    const Profile()
  ];
  final List<PersistentBottomNavBarItem> _navBarsItems = [
    PersistentBottomNavBarItem(
      icon: const Icon(Icons.local_fire_department),
      title: ('Popular'),
      activeColorPrimary: CupertinoColors.activeOrange,
      inactiveColorPrimary: CupertinoColors.systemGrey,
    ),
    PersistentBottomNavBarItem(
      icon: const Icon(Icons.star),
      title: ('Top Rated'),
      activeColorPrimary: Colors.yellow,
      inactiveColorPrimary: CupertinoColors.systemGrey,
    ),
    PersistentBottomNavBarItem(
      icon: const Icon(Icons.favorite),
      title: ('Favorites'),
      activeColorPrimary: Colors.red,
      inactiveColorPrimary: CupertinoColors.systemGrey,
    ),
    PersistentBottomNavBarItem(
      icon: const Icon(Icons.person),
      title: ('Profile'),
      activeColorPrimary: Colors.blue,
      inactiveColorPrimary: CupertinoColors.systemGrey,
    )
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Disable back button
        return Future.value(false);
      },
      child: MaterialApp(
        home: DefaultTabController(
          length: 3, // Number of tabs (Popular Movies and Top Rated Movies)
          child: Scaffold(
            body: PersistentTabView(
              context,
              controller: _controller,
              screens: _buildScreens,
              items: _navBarsItems,
              confineInSafeArea: true,
              backgroundColor: Colors.white,
              handleAndroidBackButtonPress: true,
              resizeToAvoidBottomInset: true,
              stateManagement: true,
              hideNavigationBarWhenKeyboardShows: true,
              decoration: NavBarDecoration(
                borderRadius: BorderRadius.circular(10.0),
                colorBehindNavBar: Colors.white,
              ),
              popAllScreensOnTapOfSelectedTab: true,
              popActionScreens: PopActionScreensType.all,
              itemAnimationProperties: const ItemAnimationProperties(
                duration: Duration(milliseconds: 200),
                curve: Curves.ease,
              ),
              screenTransitionAnimation: const ScreenTransitionAnimation(
                animateTabTransition: true,
                curve: Curves.ease,
                duration: Duration(milliseconds: 200),
              ),
              navBarStyle: NavBarStyle.style1,
            ),
          ),
        ),
      ),
    );
  }
}
