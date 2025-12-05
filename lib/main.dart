import 'package:blink_flutter/screens/Login_screen.dart';
import 'package:blink_flutter/screens/dashboard.dart';
import 'package:blink_flutter/screens/on_boarding.dart';
import 'package:blink_flutter/screens/sign_screen.dart';
import 'package:blink_flutter/screens/splash_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}
