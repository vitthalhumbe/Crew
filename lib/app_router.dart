import 'package:flutter/material.dart';


import 'ui/onboarding/splash_screen.dart';
import 'ui/onboarding/onboarding_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String onboarding = '/onboarding';


  static Map<String, WidgetBuilder> get routes {
    return {
      splash: (context) => const SplashScreen(),
      onboarding: (context) => const OnboardingScreen(),
    };
  }
}