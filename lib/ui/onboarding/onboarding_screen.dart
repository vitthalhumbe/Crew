import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding_page.dart';
import 'package:testing/core/constants/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _pageIndex = 0;

  final List<Map<String, String>> onboarding_data = [
    {
      "title": "Work Together. Grow Together.",
      "description":
          "Crew helps small groups stay organised, stay motivated, and complete similar tasks together.",
      "image": "assets/images/onboard1.png",
    },
    {
      "title": "Start a crew or join one",
      "description":
          "Create a private crew or join public crews from learners across colleges.",
      "image": "assets/images/onboard2.png",
    },
    {
      "title": "One Captain. Shared Tasks.",
      "description":
          "Captains assign tasks. Members complete and track their progress easily.",
      "image": "assets/images/onboard3.png",
    },
    {
      "title": "Track your Improvement.",
      "description":
          "See daily streaks, progress, and leaderboard position. Stay motivated.",
      "image": "assets/images/onboard4.png",
    },
    {
      "title": "Ready to join the crew?",
      "description":
          "Create your account to start collaborating and tracking your progress.",
      "image": "assets/images/onboard5.png",
    },
  ];

  // --- FIXED ---
  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();

    // Correct key (matches SplashScreen)
    await prefs.setBool('seenOnboarding', true);


    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: onboarding_data.length,
            onPageChanged: (index) {
              setState(() => _pageIndex = index);
            },
            itemBuilder: (context, index) {
              final page = onboarding_data[index];
              return OnboardingPage(
                title: page['title']!,
                description: page['description']!,
                imagePath: page['image']!,
              );
            },
          ),

          // SKIP button (hide on last page)
          if (_pageIndex != onboarding_data.length - 1)
            Positioned(
              top: 50,
              right: 20,
              child: GestureDetector(
                onTap: _finishOnboarding,
                child: const Text(
                  "Skip",
                  style: TextStyle(fontSize: 16, color: AppColors.primary),
                ),
              ),
            ),

          // BOTTOM CONTROLS
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // PAGE INDICATORS
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    onboarding_data.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _pageIndex == index ? 18 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _pageIndex == index
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // NEXT / GET STARTED BUTTON
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    if (_pageIndex == onboarding_data.length - 1) {
                      _finishOnboarding();
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Text(
                    _pageIndex == onboarding_data.length - 1
                        ? "Get Started"
                        : "Next",
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
