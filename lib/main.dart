import 'package:AnimeTalk/screens/fav_screen.dart';
import 'package:AnimeTalk/screens/messages_screen.dart';
// import 'package:AnimeTalk/widgets/feature/first_time_user_check.dart';
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'widgets/bottom_nav_bar.dart';
import 'core/service_locator.dart';

void main() {
  setupServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AnimeTalk',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // final FirstTimeUserCheck _firstTimeCheck = FirstTimeUserCheck();

  int _currentIndex = 0;


  @override
  void initState() {
    super.initState();
    // _firstTimeCheck.checkFirstTimeUser(context);
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    FavScreen(),
    MessagesScreen(),
    const Center(child: Text('Discover')),
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
