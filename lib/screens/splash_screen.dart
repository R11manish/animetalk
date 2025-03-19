import 'package:animetalk/constants/app_logo.dart';
import 'package:animetalk/utility/functions.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _handleNavigation();
  }

  Future<void> _handleNavigation() async {
    String navigationRoute;
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    bool isLoggedIn = await IsFirstTime();
    navigationRoute = isLoggedIn ? '/register' : '/main';

    if (!mounted) return;

    Navigator.pushReplacementNamed(context, navigationRoute);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppLogo(),
            SizedBox(height: 30),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
