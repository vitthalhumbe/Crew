import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CrewMembersTab extends StatelessWidget {
  final String crewId;
  final String captainId;

  const CrewMembersTab({
    super.key,
    required this.crewId,
    required this.captainId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection("crews").doc(crewId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final members = data["members"] as List<dynamic>;

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: members.length,
          itemBuilder: (context, index) {
            final userId = members[index];

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection("users").doc(userId).get(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const SizedBox.shrink();
                }

                final u = snap.data!.data() as Map<String, dynamic>;
                final name = u["name"] ?? "";

                final isCaptain = userId == captainId;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(radius: 22),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          isCaptain ? "$name (Captain)" : name,
                          style: theme.textTheme.bodyLarge,
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
}
