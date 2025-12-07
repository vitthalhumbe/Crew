import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskDetailScreen extends StatefulWidget {
  final String crewId;
  final String taskId;

  const TaskDetailScreen({
    super.key,
    required this.crewId,
    required this.taskId,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("crews")
          .doc(widget.crewId)
          .collection("tasks")
          .doc(widget.taskId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;

        final title = data["title"] ?? "";
        final description = data["description"] ?? "";
        final link = data["link"] ?? "";
        final concepts = List<String>.from(data["concepts"] ?? []);
        final completedBy = List<String>.from(data["completedBy"] ?? []);

        final currentUser = FirebaseAuth.instance.currentUser!;
        final currentUid = currentUser.uid;

        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection("crews")
              .doc(widget.crewId)
              .snapshots(),
          builder: (context, crewSnap) {
            if (!crewSnap.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final crewData = crewSnap.data!.data() as Map<String, dynamic>;
            final captainId = crewData["captainId"];

            bool isCaptain = currentUid == captainId;
            bool isCompleted = completedBy.contains(currentUid);

            return Scaffold(
              backgroundColor: theme.scaffoldBackgroundColor,

              // ---------------------- BOTTOM BUTTON ----------------------
              bottomNavigationBar: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCompleted
                          ? Colors.green
                          : theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: isCaptain
                        ? () {
                            // TODO: Edit task screen later
                          }
                        : isCompleted
                            ? null
                            : () async {
                                await FirebaseFirestore.instance
                                    .collection("crews")
                                    .doc(widget.crewId)
                                    .collection("tasks")
                                    .doc(widget.taskId)
                                    .update({
                                  "completedBy":
                                      FieldValue.arrayUnion([currentUid])
                                });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("Task marked as completed")),
                                );
                              },
                    child: Text(
                      isCaptain
                          ? "Edit Task"
                          : isCompleted
                              ? "Completed"
                              : "Mark it as Done",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),

              body: SafeArea(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ---------------------- HEADER ----------------------
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => Navigator.pop(context),
                          ),
                          Text(
                            "Task Detail",
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ---------------------- TITLE ----------------------
                      Text(
                        title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ---------------------- CONCEPT CHIPS ----------------------
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: concepts
                            .map(
                              (c) => Chip(
                                label: Text(c),
                                backgroundColor:
                                    theme.colorScheme.primary.withOpacity(0.1),
                                labelStyle: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                            .toList(),
                      ),

                      const SizedBox(height: 18),

                      // ---------------------- DESCRIPTION ----------------------
                      Text(
                        description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ---------------------- LINK SECTION ----------------------
                      if (link.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  link,
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  if (await canLaunchUrl(Uri.parse(link))) {
                                    await launchUrl(Uri.parse(link),
                                        mode: LaunchMode.externalApplication);
                                  }
                                },
                                child: Icon(
                                  Icons.open_in_new,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
