import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'assign_task_screen.dart';
import 'task_detail_screen.dart';

class TaskListScreen extends StatefulWidget {
  final String crewId;

  const TaskListScreen({super.key, required this.crewId});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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

        final crew = crewSnap.data!.data() as Map<String, dynamic>;
        final captainId = crew["createdBy"];
        final uid = FirebaseAuth.instance.currentUser!.uid;

        final bool isCaptain = uid == captainId;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,

          // ---------------- BOTTOM BUTTON ----------------
          bottomNavigationBar: isCaptain
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AssignTaskScreen(crewId: widget.crewId),
                          ),
                        );
                      },
                      child: const Text(
                        "Assign Task",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                )
              : null,

          body: SafeArea(
            child: Column(
              children: [
                // ---------------- HEADER ----------------
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      Text(
                        "Tasks",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                // ---------------- TABS ----------------
                TabBar(
                  controller: tabController,
                  indicatorColor: theme.colorScheme.primary,
                  labelColor: theme.colorScheme.primary,
                  unselectedLabelColor:
                      theme.colorScheme.onSurface.withOpacity(0.6),
                  tabs: const [
                    Tab(text: "All"),
                    Tab(text: "Pending"),
                    Tab(text: "Completed"),
                  ],
                ),

                // ---------------- TAB CONTENT ----------------
                Expanded(
                  child: TabBarView(
                    controller: tabController,
                    children: [
                      _TaskListView(crewId: widget.crewId, filter: "all"),
                      _TaskListView(crewId: widget.crewId, filter: "pending"),
                      _TaskListView(crewId: widget.crewId, filter: "completed"),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

// =========================================================================
// TASK LIST VIEW — Reusable widget for All / Pending / Completed
// =========================================================================
class _TaskListView extends StatelessWidget {
  final String crewId;
  final String filter; // all / pending / completed

  const _TaskListView({
    required this.crewId,
    required this.filter,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("crews")
          .doc(crewId)
          .collection("tasks")
          .orderBy("createdAt", descending: true)
          .snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snap.data!.docs;

        // Apply Filter
        final filteredTasks = docs.where((task) {
          final completedBy = List<String>.from(task["completedBy"] ?? []);
          final isCompleted = completedBy.contains(uid);

          if (filter == "pending") return !isCompleted;
          if (filter == "completed") return isCompleted;

          return true; // all
        }).toList();

        if (filteredTasks.isEmpty) {
          return const Center(child: Text("No tasks yet"));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          itemCount: filteredTasks.length,
          itemBuilder: (context, i) {
            final task = filteredTasks[i];
            final title = task["title"] ?? "";
            final completedBy = List<String>.from(task["completedBy"]);
            final isDone = completedBy.contains(uid);

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TaskDetailScreen(
                      crewId: crewId,
                      taskId: task.id,
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.open_in_new,
                      size: 20,
                      color: theme.colorScheme.primary,
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
