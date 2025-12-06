import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Privacy Policy")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Privacy Policy",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                "• We collect basic profile details such as name, email, bio, and avatar.\n"
                "• Your data is securely stored using Firebase Authentication & Firestore.\n"
                "• We do not sell or share your personal information.\n"
                "• You can request deletion of your account anytime.\n"
                "• This app is designed for educational and personal use.",
                style: theme.textTheme.bodyLarge,
              ),

              const SizedBox(height: 20),

              Text(
                "Last updated: December 2025",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
