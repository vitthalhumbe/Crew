import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'ui/onboarding/splash_screen.dart';
import 'ui/onboarding/onboarding_screen.dart';

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
      home: const SplashScreen(),
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => Scaffold(body: Center(child: Text("Login (todo)"))),
        '/mainShell': (context) => Scaffold(body: Center(child: Text("Main Shell (todo)"))),
      },
    );
  }
}
