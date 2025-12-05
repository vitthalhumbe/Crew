import 'package:flutter/material.dart';


import 'ui/onboarding/splash_screen.dart';
import 'ui/onboarding/onboarding_screen.dart';
import 'ui/auth/login_screen.dart';
import 'ui/auth/create_account_screen.dart';
import 'ui/auth/forgot_password_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/createAccount';
  static const String forgotPassword = '/forgotPassword';


  static Map<String, WidgetBuilder> get routes {
    return {
      splash: (context) => const SplashScreen(),
      onboarding: (context) => const OnboardingScreen(),
      login: (context) => const LoginScreen(),
      signup: (context) => const CreateAccountScreen(),
      forgotPassword: (context) => const ForgotPasswordScreen(),
    };
  }
}