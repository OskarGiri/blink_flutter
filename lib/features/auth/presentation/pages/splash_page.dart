import 'dart:async';
import 'package:blink_flutter/features/auth/presentation/pages/dashboard_page.dart';
import 'package:blink_flutter/features/auth/presentation/pages/onboarding_page.dart';
import 'package:blink_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateNext();
  }

  void _navigateNext() async {
    // Wait 3 seconds for splash effect
    await Future.delayed(const Duration(seconds: 3));

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isLoggedIn = await authProvider.isLoggedIn();

    if (isLoggedIn) {
      // Go straight to Dashboard if user already logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } else {
      // Otherwise go to Onboarding
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 169, 109, 181),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            const Icon(Icons.favorite, size: 100, color: Colors.white),
            const SizedBox(height: 20),

            // App Name
            const Text(
              "Blink Dating",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
