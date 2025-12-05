import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'ui/onboarding/splash_screen.dart';
import 'ui/onboarding/onboarding_screen.dart';
import 'ui/auth/login_screen.dart';
import 'ui/auth/create_account_screen.dart';
import 'ui/auth/forgot_password_screen.dart';
import 'ui/navigation/main_shell.dart';

void main() {
  // WidgetsFlutterBinding.ensureInitialized();

  // await Firebase.initializeApp();
  runApp(const CrewApp());
}

class CrewApp extends StatelessWidget {
  const CrewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,

      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/createAccount': (context) => const CreateAccountScreen(),
        '/forgotPassword': (context) => const ForgotPasswordScreen(),
        '/mainShell': (context) => const MainShell(),
      },
    );
  }
}
