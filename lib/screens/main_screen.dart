import 'package:animetalk/screens/discover_screen.dart';
import 'package:animetalk/screens/fav_screen.dart';
import 'package:animetalk/screens/home_screen.dart';
import 'package:animetalk/screens/messages_screen.dart';
import 'package:animetalk/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    FavScreen(),
    MessagesScreen(),
    DiscoverScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
