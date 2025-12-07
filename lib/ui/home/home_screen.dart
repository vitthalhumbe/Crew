import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/progress_service.dart';
import '../crews/crew_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int tasksCompleted = 0;
  List<String> crewIds = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadHomeData();
  }

  Future<void> loadHomeData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final progress = ProgressService();

    final completed = await progress.getTotalTasksCompleted(user.uid);
    final joined = await progress.getCrewsJoined(user.uid);
    final users = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();
    setState(() {
      tasksCompleted = completed;
      crewIds = List<String>.from(joined == 0 ? [] : []);
      crewIds = (users).data()?["crews"]?.cast<String>() ?? [];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---------------- TOP BAR ----------------
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Crew",
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Text(
                      "Quick stats",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _statCard(
                            context,
                            icon: Icons.check_circle_outline,
                            iconColor: theme.colorScheme.primary,
                            count: "$tasksCompleted",
                            label: "Tasks completed",
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _statCard(
                            context,
                            icon: Icons.rocket_launch_outlined,
                            iconColor: theme.colorScheme.secondary,
                            count: "${crewIds.length}",
                            label: "Joined Crews",
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    Text(
                      "Your crews",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 14),

                    if (crewIds.isEmpty)
                      Text(
                        "You have not joined any crews yet.",
                        style: theme.textTheme.bodyMedium,
                      ),

                    ...crewIds.map((id) => _buildCrewItem(id)),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildCrewItem(String crewId) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final progressService = ProgressService();

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("crews")
          .doc(crewId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox.shrink();
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final title = data["name"] ?? "Unnamed Crew";
        final caption = data["notice"] ?? "No updates yet";

        return FutureBuilder<double>(
          future: progressService.getUserProgressInCrew(crewId, uid),
          builder: (context, progressSnap) {
            if (!progressSnap.hasData) {
              return _crewItem(
                context,
                title: title,
                caption: caption,
                progress: 0.0, 
              );
            }

            final progress = progressSnap.data ?? 0.0;

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CrewDetailScreen(crewId: crewId),
                  ),
                );
              },
              child: _crewItem(
                context,
                title: title,
                caption: caption,
                progress: progress,
              ),
            );
          },
        );
      },
    );
  }

  Widget _statCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String count,
    required String label,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.20),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 22, color: iconColor),
          ),

          const SizedBox(height: 12),

          Text(
            count,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _crewItem(
    BuildContext context, {
    required String title,
    required double progress,
    required String caption,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 12),

          Text("progress", style: theme.textTheme.bodyMedium),

          const SizedBox(height: 12),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: theme.colorScheme.onSurface.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
            ),
          ),

          const SizedBox(height: 12),

          RichText(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              text: "Captain: ",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              children: [
                TextSpan(
                  text: caption,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
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
