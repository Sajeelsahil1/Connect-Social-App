import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart'; // <-- 1. Import Provider
import 'package:social_connect/home_scaffold.dart';
import 'package:social_connect/login_screen.dart';
import 'package:social_connect/settings_provider.dart'; // <-- 2. Import Settings
import 'package:social_connect/splash_screen.dart';
import 'package:social_connect/theme.dart'; // <-- 3. Import Theme

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // --- 4. WRAP THE APP IN THE PROVIDER ---
  runApp(
    ChangeNotifierProvider(
      create: (context) => SettingsProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // --- 5. CONSUME THE SETTINGS ---
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return MaterialApp(
          title: 'Kinekt',
          debugShowCheckedModeBanner: false,
          theme: lightTheme, // <-- 6. Set light theme
          darkTheme: darkTheme, // <-- 7. Set dark theme
          themeMode: settings.themeMode, // <-- 8. Let provider control it
          home: const SplashScreen(),
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasData) {
          return const HomeScaffold();
        }
        return const LoginScreen();
      },
    );
  }
}
