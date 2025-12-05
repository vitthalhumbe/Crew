import 'package:flutter/material.dart';

class JoinCrewScreen extends StatefulWidget {
  const JoinCrewScreen({super.key});

  @override
  State<JoinCrewScreen> createState() => _JoinCrewScreenState();
}

class _JoinCrewScreenState extends State<JoinCrewScreen> {
  int selectedTab = 0; // 0 = Public, 1 = Private

  final TextEditingController joinCodeController = TextEditingController();

  final List<Map<String, dynamic>> publicCrews = [
    {
      "name": "Kabbadi Practice Group",
      "members": 87,
    },
    {
      "name": "App Development Guidance",
      "members": 132,
    },
    {
      "name": "One Piece Theory Discussion",
      "members": 76,
    },
    {
      "name": "Learn How to Draw By Mr.Drawer34",
      "members": 54,
    },
  ];

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

  // ------------------------------------------------------------
  // TAB BUTTON
  // ------------------------------------------------------------
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

  // ------------------------------------------------------------
  // PUBLIC CREWS LIST
  // ------------------------------------------------------------
  Widget _buildPublicCrewsList(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Search bar (UI only)
          TextField(
            decoration: InputDecoration(
              hintText: "Search for a crew...",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 14),

          Expanded(
            child: ListView.builder(
              itemCount: publicCrews.length,
              itemBuilder: (context, index) {
                final crew = publicCrews[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      // Avatar Circle
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

                      // Texts
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
                              "${crew["members"]} members",
                              style: TextStyle(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // View button
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "View",
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // PRIVATE CREW JOIN
  // ------------------------------------------------------------
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
              hintText: "e.g. 8AB-X34-T12",
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
              onPressed: () {},
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
