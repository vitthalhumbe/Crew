import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/progress_service.dart';
import 'crew_detail_screen.dart';

class CrewsScreen extends StatefulWidget {
  const CrewsScreen({super.key});

  @override
  State<CrewsScreen> createState() => _CrewsScreenState();
}

class _CrewsScreenState extends State<CrewsScreen> {
  List<String> userCrewIds = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserCrews();
  }

  Future<void> fetchUserCrews() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    final data = doc.data();
    if (data == null) return;

    setState(() {
      userCrewIds = List<String>.from(data["crews"] ?? []);
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
            : userCrewIds.isEmpty
                ? Center(
                    child: Text(
                      "You haven't joined any crews yet.",
                      style: theme.textTheme.titleMedium,
                    ),
                  )
                : ListView(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Your Crews",
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      ...userCrewIds.map((id) => _buildCrewStreamCard(id)),
                    ],
                  ),
      ),
    );
  }

 Widget _buildCrewStreamCard(String crewId) {
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

      return FutureBuilder<double>(
        future: progressService.getUserProgressInCrew(crewId, uid),
        builder: (context, progressSnap) {
          double progress = progressSnap.data ?? 0.0;

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CrewDetailScreen(crewId: crewId),
                ),
              );
            },
            child: _crewCard(
              context,
              title: title,
              progress: progress,
            ),
          );
        },
      );
    },
  );
}

  Widget _crewCard(
    BuildContext context, {
    required String title,
    required double progress,
  }) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
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
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 14),

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

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor:
                  theme.colorScheme.onSurface.withOpacity(0.08),
              valueColor: AlwaysStoppedAnimation(
                theme.colorScheme.secondary.withOpacity(0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
