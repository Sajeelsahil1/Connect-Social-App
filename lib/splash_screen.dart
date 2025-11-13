import 'dart:async';
import 'package:flutter/material.dart';
import 'package:social_connect/main.dart'; // We will create AuthWrapper in main.dart
import 'package:social_connect/theme.dart'; // Import our new theme

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    // Wait for 2.5 seconds
    await Future.delayed(const Duration(milliseconds: 2500), () {});
    // Navigate and remove splash screen from stack
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthWrapper()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your App Logo or Icon
            const Icon(
              Icons.explore, // Or Icons.connect_without_contact
              size: 100,
              color: primaryColor,
            ),
            const SizedBox(height: 20),
            // Your App Name
            Text(
              'Kinekt', // Our new app name!
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            ),
          ],
        ),
      ),
    );
  }
}
