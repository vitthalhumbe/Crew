import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'crew_overview_tab.dart';
import 'crew_members_tab.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'crew_leaderboard_tab.dart';

class CrewDetailScreen extends StatefulWidget {
  final String crewId;
  const CrewDetailScreen({super.key, required this.crewId});

  @override
  State<CrewDetailScreen> createState() => _CrewDetailScreenState();
}

class _CrewDetailScreenState extends State<CrewDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  void _openEditNoticeSheet({
    required String crewId,
    required String oldNotice,
  }) {
    final controller = TextEditingController(text: oldNotice);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Edit Notice",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),

              TextField(
                controller: controller,
                maxLength: 200,
                maxLines: 4,

                decoration: InputDecoration(
                  hintText: "Write a notice for your crew...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    await _saveNotice(crewId, controller.text.trim());
                    Navigator.pop(context);
                  },
                  child: const Text("Save"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveNotice(String crewId, String newNotice) async {
    if (newNotice.isEmpty) return;
    if (newNotice.length > 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Notice cannot exceed 200 characters.")),
      );
      return;
    }

    await FirebaseFirestore.instance.collection("crews").doc(crewId).update({
      "notice": newNotice,
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Notice updated!")));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("crews")
          .doc(widget.crewId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final crewName = data["name"] ?? "";
        final notice = data["notice"] ?? "";
        final isPrivate = data["isPrivate"] ?? false;
        final currentUserId = FirebaseAuth.instance.currentUser?.uid;
        final captainId = data["createdBy"] ?? "";

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Crew details",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    crewName,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.public,
                              size: 16,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isPrivate ? "Private" : "Public",
                              style: const TextStyle(color: Colors.blue),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),

                      if (currentUserId == captainId)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.star, size: 16, color: Colors.purple),
                              SizedBox(width: 4),
                              Text(
                                "Captain",
                                style: TextStyle(color: Colors.purple),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notice.isEmpty ? "No notices yet." : notice,
                          style: theme.textTheme.bodyMedium,
                        ),

                        const SizedBox(height: 10),

                        if (currentUserId == captainId)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              icon: const Icon(Icons.edit, size: 18),
                              label: const Text("Edit notice"),
                              onPressed: () => _openEditNoticeSheet(
                                crewId: widget.crewId,
                                oldNotice: notice,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                TabBar(
                  controller: tabController,
                  indicatorColor: theme.colorScheme.primary,
                  labelColor: theme.colorScheme.primary,
                  unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(
                    0.6,
                  ),
                  tabs: const [
                    Tab(text: "Overview"),
                    Tab(text: "Members"),
                    Tab(text: "Leaderboard"),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: tabController,
                    children: [
                      CrewOverviewTab(crewId: widget.crewId),
                      CrewMembersTab(
                        crewId: widget.crewId,
                        captainId: captainId,
                      ),
                      CrewLeaderboardTab(crewId: widget.crewId),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
