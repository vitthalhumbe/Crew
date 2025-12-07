import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../crews/crew_detail_screen.dart';

class JoinCrewScreen extends StatefulWidget {
  const JoinCrewScreen({super.key});

  @override
  State<JoinCrewScreen> createState() => _JoinCrewScreenState();
}

class _JoinCrewScreenState extends State<JoinCrewScreen> {
  int selectedTab = 0; // 0 = Public, 1 = Private
  final TextEditingController joinCodeController = TextEditingController();

  final Stream<QuerySnapshot> publicCrewsStream = FirebaseFirestore.instance
      .collection("crews")
      .where("isPrivate", isEqualTo: false)
      .snapshots();

  // =============================================================
  // JOIN PUBLIC CREW
  // =============================================================
  Future<void> joinPublicCrew(DocumentSnapshot crew) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    List<dynamic> members = crew["members"];
    final userRef =
        FirebaseFirestore.instance.collection("users").doc(user.uid);

    // Prevent duplicate join
    if (members.contains(user.uid)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You're already a member of ${crew["name"]}!")),
      );
      return;
    }

    final userDoc = await userRef.get();
    List<dynamic> userCrews = userDoc.data()?["crews"] ?? [];

    if (userCrews.contains(crew.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Already joined this crew!")),
      );
      return;
    }

    // Add user to crew
    await crew.reference.update({
      "members": FieldValue.arrayUnion([user.uid])
    });

    // Add crew to user profile
    await userRef.set({
      "crewsJoined": FieldValue.increment(1),
      "crews": FieldValue.arrayUnion([crew.id])
    }, SetOptions(merge: true));

Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => CrewDetailScreen(crewId: crew.id),
  ),
);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Joined ${crew["name"]}!")),
    );
  }

  // =============================================================
  // JOIN PRIVATE CREW
  // =============================================================
  Future<void> joinPrivateCrew() async {
    String code = joinCodeController.text.trim();
    final user = FirebaseAuth.instance.currentUser;

    if (code.isEmpty || user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid code")),
      );
      return;
    }

    final query = await FirebaseFirestore.instance
        .collection("crews")
        .where("privateCode", isEqualTo: code)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid code!")),
      );
      return;
    }

    final crew = query.docs.first;
    List<dynamic> members = crew["members"];

    // Already joined check
    if (members.contains(user.uid)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You already joined ${crew["name"]}!")),
      );
      return;
    }

    // Add user to crew
    await crew.reference.update({
      "members": FieldValue.arrayUnion([user.uid])
    });

    // Add crew to user
    FirebaseFirestore.instance.collection("users").doc(user.uid).set({
      "crewsJoined": FieldValue.increment(1),
      "crews": FieldValue.arrayUnion([crew.id])
    }, SetOptions(merge: true));
  Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => CrewDetailScreen(crewId: crew.id),
  ),
);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Joined ${crew["name"]} successfully!")),
    );

    Navigator.pop(context);
  }

  // =============================================================
  // UI
  // =============================================================
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -------------------- HEADER --------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Join Crew",
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_none),
                  ),
                ],
              ),
            ),

            // -------------------- TABS --------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _buildTab("Public crews", 0),
                    _buildTab("Private crews", 1),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // -------------------- CONTENT --------------------
            Expanded(
              child: selectedTab == 0
                  ? _buildPublicCrewsList(theme)
                  : _buildPrivateCrewView(theme),
            )
          ],
        ),
      ),
    );
  }

  // =============================================================
  // TAB BUTTON
  // =============================================================
  Widget _buildTab(String text, int index) {
    final theme = Theme.of(context);
    final isSelected = selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => selectedTab = index);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withOpacity(0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
      ),
    );
  }

  // =============================================================
  // PUBLIC CREWS LIST
  // =============================================================
  Widget _buildPublicCrewsList(ThemeData theme) {
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<QuerySnapshot>(
      stream: publicCrewsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final crews = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: crews.length,
          itemBuilder: (context, i) {
            final crew = crews[i];
            List<dynamic> members = crew["members"];
            bool alreadyJoined = members.contains(user!.uid);

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.group, color: Colors.purple),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          crew["name"],
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${members.length} members",
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),

                  alreadyJoined
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            "Joined",
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : GestureDetector(
                          onTap: () => joinPublicCrew(crew),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              "Join",
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // =============================================================
  // PRIVATE JOIN UI
  // =============================================================
  Widget _buildPrivateCrewView(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Join Code", style: theme.textTheme.titleMedium),
          const SizedBox(height: 6),

          TextField(
            controller: joinCodeController,
            decoration: InputDecoration(
              hintText: "e.g. ABX-345",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: joinPrivateCrew,
              child: const Text(
                "Join Crew",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
