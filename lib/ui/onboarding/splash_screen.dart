import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget{
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
    final hasSeenOnboarding = prefs.getBool('seenOnboarding') ?? false;
    final user = null;  // ######################### temporary placeholder for FirebaseAuth.instance.currentUser; ##########


    if (!hasSeenOnboarding) {
      print('Navigating to Onboarding Screen');
      Navigator.pushReplacementNamed(context, '/onboarding');
      return;
    }

    if (user == null) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      Navigator.pushReplacementNamed(context, '/mainShell');
    }
  }

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Image.asset(
          'assets/images/logo_splash.png',
          width: 50,
          height: 50,
        )
      )
    );
  }
}

