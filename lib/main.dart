import 'package:animetalk/screens/discover_screen.dart';
import 'package:animetalk/screens/home_screen.dart';
import 'package:animetalk/screens/main_screen.dart';
import 'package:animetalk/screens/register_screen.dart';
import 'package:animetalk/screens/splash_screen.dart';
import 'package:animetalk/services/ad_service.dart';
import 'package:animetalk/viewmodels/home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AdService.initialize();
  setupServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        // Add other providers here as needed
      ],
      child: MaterialApp(
        navigatorKey: getIt<GlobalKey<NavigatorState>>(),
        title: 'AnimeTalk',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/main': (context) => const MainScreen(),
          '/home': (context) => const HomeScreen(),
          '/register': (context) => const RegisterScreen(),
          '/discover': (context) => const DiscoverScreen(),
        },
      ),
    );
  }
}
