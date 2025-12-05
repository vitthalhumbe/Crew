import 'package:flutter/material.dart';

class CrewsScreen extends StatelessWidget {
  const CrewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              // ---------------- TOP BAR ----------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Your Crews",
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.notifications_none),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ---------------- CREW LIST ----------------
              _crewCard(
                context,
                title: "English speaking",
                progress: 0.75,
              ),

              const SizedBox(height: 16),

              _crewCard(
                context,
                title: "Python Course",
                progress: 0.42,
              ),

              const SizedBox(height: 16),

              _crewCard(
                context,
                title: "Data Analytics",
                progress: 1.00,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- CREW CARD WIDGET ----------------
  Widget _crewCard(
    BuildContext context, {
    required String title,
    required double progress,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          // TITLE
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 14),

          // PROGRESS LABEL + % RIGHT
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Progress",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              Text(
                "${(progress * 100).toInt()}%",
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // PROGRESS BAR
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: theme.colorScheme.onSurface.withOpacity(0.08),
              valueColor:
                  AlwaysStoppedAnimation(theme.colorScheme.secondary.withOpacity(0.6)),
            ),
          ),
        ],
      ),
    );
  }
}
