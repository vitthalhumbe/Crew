import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CrewLeaderboardTab extends StatelessWidget {
  final String crewId;
  const CrewLeaderboardTab({super.key, required this.crewId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance.collection("crews").doc(crewId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final members = data["members"] as List<dynamic>;

        return FutureBuilder<List<Map<String, dynamic>>>(
          future: _getLeaderboardData(members),
          builder: (context, snap) {
            if (!snap.hasData) return const Center(child: CircularProgressIndicator());

            final leaderboard = snap.data!;

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: leaderboard.length,
              itemBuilder: (context, index) {
                final user = leaderboard[index];
                final rank = index + 1;
                final tasksDone = user["tasksDone"];
                final totalTasks = user["totalTasks"];
                final progress = tasksDone / totalTasks;

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Text(rank.toString(),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          )),
                      const SizedBox(width: 16),
                      const CircleAvatar(radius: 22),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user["name"],
                                style: theme.textTheme.bodyLarge),
                            const SizedBox(height: 6),
                            LinearProgressIndicator(
                              value: progress,
                              minHeight: 6,
                            ),
                            const SizedBox(height: 4),
                            Text("$tasksDone/$totalTasks Tasks",
                                style: theme.textTheme.bodySmall),
                          ],
                        ),
                      )
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

  Future<List<Map<String, dynamic>>> _getLeaderboardData(
      List<dynamic> members) async {
    List<Map<String, dynamic>> data = [];

    for (String uid in members) {
      final userDoc =
          await FirebaseFirestore.instance.collection("users").doc(uid).get();
      final u = userDoc.data() as Map<String, dynamic>;

      data.add({
        "name": u["name"],
        "tasksDone": u["tasksCompleted"] ?? 0,
        "totalTasks": 20
      });
    }

    data.sort((a, b) => b["tasksDone"].compareTo(a["tasksDone"]));
    return data;
  }
}
