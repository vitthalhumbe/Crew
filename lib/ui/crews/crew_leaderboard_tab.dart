import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CrewLeaderboardTab extends StatelessWidget {
  final String crewId;
  const CrewLeaderboardTab({super.key, required this.crewId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("crews")
          .doc(crewId)
          .snapshots(),
      builder: (context, crewSnap) {
        if (!crewSnap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final crewData = crewSnap.data!.data() as Map<String, dynamic>;
        final members = List<String>.from(crewData["members"] ?? []);

        return FutureBuilder<List<Map<String, dynamic>>>(
          future: _buildLeaderboard(members),
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final leaderboard = snap.data!;

            if (leaderboard.isEmpty) {
              return const Center(child: Text("No members yet."));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: leaderboard.length,
              itemBuilder: (context, index) {
                final user = leaderboard[index];
                final rank = index + 1;

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Text(
                        "$rank",
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 16),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user["name"],
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),

                            LinearProgressIndicator(
                              value: user["total"] == 0
                                  ? 0
                                  : user["done"] / user["total"],
                              minHeight: 6,
                              backgroundColor: Colors.grey.shade300,
                              color: theme.colorScheme.primary,
                            ),

                            const SizedBox(height: 4),

                            Text(
                              "${user["done"]}/${user["total"]} tasks",
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _buildLeaderboard(
    List<String> members,
  ) async {
    List<Map<String, dynamic>> result = [];

    final tasksSnap = await FirebaseFirestore.instance
        .collection("crews")
        .doc(crewId)
        .collection("tasks")
        .get();

    final totalTasks = tasksSnap.docs.length;

    for (String uid in members) {
      int done = 0;

      for (var task in tasksSnap.docs) {
        final completedBy = List<String>.from(task["completedBy"] ?? []);
        if (completedBy.contains(uid)) {
          done++;
        }
      }

      final userDoc =
          await FirebaseFirestore.instance.collection("users").doc(uid).get();
      final userData = userDoc.data() ?? {};

      result.add({
        "uid": uid,
        "name": userData["name"] ?? "Unknown User",
        "done": done,
        "total": totalTasks,
      });
    }
    
    result.sort((a, b) => b["done"].compareTo(a["done"]));

    return result;
  }
}
