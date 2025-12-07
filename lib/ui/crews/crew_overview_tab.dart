import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/progress_service.dart';
import '../tasks/task_list_screen.dart';

class CrewOverviewTab extends StatelessWidget {
  final String crewId;
  const CrewOverviewTab({super.key, required this.crewId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final progressService = ProgressService();

    return FutureBuilder<Map<String, dynamic>>(
      future: _loadOverviewData(progressService, uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!;
        final description = data["description"];
        final completed = data["completed"];
        final total = data["total"];
        final progress = total == 0 ? 0.0 : completed / total;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ---------------- DESCRIPTION ----------------
              Text("Description", style: theme.textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(
                description,
                style: theme.textTheme.bodyMedium,
              ),

              const SizedBox(height: 20),

              // ---------------- PROGRESS CARD ----------------
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 6,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 20),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Great Job, Keep Going!",
                          style: theme.textTheme.titleMedium,
                        ),
                        Text(
                          "$completed out of $total tasks completed",
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ---------------- TASK LIST BUTTON ----------------
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TaskListScreen(crewId: crewId),
                      ),
                    );
                  },
                  child: const Text("Task List →"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // -----------------------------------------------------------
  // Load description + total tasks + completed tasks
  // -----------------------------------------------------------
  Future<Map<String, dynamic>> _loadOverviewData(
    ProgressService service,
    String uid,
  ) async {
    final crewDoc = await FirebaseFirestore.instance
        .collection("crews")
        .doc(crewId)
        .get();

    final crewData = crewDoc.data() ?? {};

    final tasksSnap = await FirebaseFirestore.instance
        .collection("crews")
        .doc(crewId)
        .collection("tasks")
        .get();

    int totalTasks = tasksSnap.docs.length;
    int completedTasks = 0;

    for (var t in tasksSnap.docs) {
      final completedBy = List<String>.from(t["completedBy"] ?? []);
      if (completedBy.contains(uid)) completedTasks++;
    }

    return {
      "description": crewData["description"] ?? "",
      "completed": completedTasks,
      "total": totalTasks,
    };
  }
}
