import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:testing/ui/tasks/task_list_screen.dart';

class CrewOverviewTab extends StatelessWidget {
  final String crewId;
  const CrewOverviewTab({super.key, required this.crewId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("crews")
          .doc(crewId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final desc = data["description"] ?? "";
        final tasksCompleted = 15;
        final totalTasks = 20;
        final progress = tasksCompleted / totalTasks;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Description", style: theme.textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(
                desc,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
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
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Great Job, Keep going!",
                            style: theme.textTheme.titleMedium),
                        Text(
                          "$tasksCompleted out of $totalTasks tasks completed",
                          style: theme.textTheme.bodySmall,
                        )
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 30),
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
              )
            ],
          ),
        );
      },
    );
  }
}
