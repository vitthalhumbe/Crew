import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startApp();
  }

  Future<void> _startApp() async {
    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    final bool hasSeenOnboarding = prefs.getBool('seenOnboarding') ?? false;

    final User? currentUser = FirebaseAuth.instance.currentUser;

    // CASE 1 → First time user → Onboarding
    if (!hasSeenOnboarding) {
      Navigator.pushReplacementNamed(context, '/onboarding');
      return;
    }

    // CASE 2 → Not logged in → Login screen
    if (currentUser == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    // CASE 3 → Logged in user → MainShell
    Navigator.pushReplacementNamed(context, '/mainShell');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Image.asset(
          'assets/images/logo_splash.png',
          width: 60,
        ),
      ),
    );
  }
}
