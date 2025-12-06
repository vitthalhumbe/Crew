import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = "";
  String email = "";
  String bio = "";
  String avatarUrl = "";
  int streak = 0;
  int crewsJoined = 0;
  int tasksCompleted = 0;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadLocalData();
    fetchUserData();
  }

  // ------------------------------ LOCAL CACHE ------------------------------
  Future<void> loadLocalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      name = prefs.getString("user_name") ?? "";
      email = prefs.getString("user_email") ?? "";
      bio = prefs.getString("user_bio") ?? "";
      streak = prefs.getInt("user_streak") ?? 0;
      avatarUrl = prefs.getString("user_avatar") ?? "";
      crewsJoined = prefs.getInt("user_crews") ?? 0;
      tasksCompleted = prefs.getInt("user_tasks") ?? 0;
    });
  }

  Future<void> saveLocalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("user_name", name);
    prefs.setString("user_email", email);
    prefs.setString("user_bio", bio);
    prefs.setString("user_avatar", avatarUrl);
    prefs.setInt("user_streak", streak);
    prefs.setInt("user_crews", crewsJoined);
    prefs.setInt("user_tasks", tasksCompleted);
  }

  // ------------------------------ FIRESTORE FETCH ------------------------------
  Future<void> fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => isLoading = false);
      return;
    }

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        name = data["name"] ?? "";
        email = data["email"] ?? user.email ?? "";
        bio = data["bio"] ?? "";
        streak = data["streak"] ?? 0;
        avatarUrl = data["avatarUrl"] ?? "";
        crewsJoined = data["crewsJoined"] ?? 0;
        tasksCompleted = data["tasksCompleted"] ?? 0;
        isLoading = false;
      });

      saveLocalData();
    } else {
      /// NEW IMPORTANT FIX — prevent infinite loading
      setState(() {
        name = user.displayName ?? "User";
        email = user.email ?? "";
        bio = "No bio added yet.";
        streak = 0;
        crewsJoined = 0;
        tasksCompleted = 0;
        isLoading = false;
      });

      /// Optionally create empty profile if missing
      FirebaseFirestore.instance.collection("users").doc(user.uid).set({
        "name": name,
        "email": email,
        "bio": bio,
        "streak": 0,
        "crewsJoined": 0,
        "avatarUrl": avatarUrl,
        "tasksCompleted": 0,
      }, SetOptions(merge: true));

      saveLocalData();
    }
  }

  void confirmLogout() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Logout?"),
          content: const Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await logout();
              },
              child: const Text("Logout", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // ------------------------------ LOGOUT ------------------------------
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ------------------------------ UI ------------------------------
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---------------- HEADER ----------------
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Profile",
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.notifications_none),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProfileScreen(
                                  currentName: name,
                                  currentBio: bio,
                                  currentAvatarUrl: avatarUrl, // for now
                                ),
                              ),
                            );

                            if (result == true) {
                              fetchUserData(); // refresh UI
                            }
                          },
                        ),
                          ]),
                        
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ---------------- USER CARD ----------------
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 35,
                            backgroundColor: theme.colorScheme.primary
                                .withOpacity(0.15),
                           backgroundImage: avatarUrl.isNotEmpty
    ? (avatarUrl.startsWith("http")
        ? NetworkImage(avatarUrl)
        : FileImage(File(avatarUrl)) as ImageProvider)
    : null,

                            child: avatarUrl.isEmpty
                                ? Icon(
                                    Icons.person,
                                    size: 38,
                                    color: theme.colorScheme.primary,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  email,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.6),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  bio,
                                  maxLines: 2,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ---------------- TWO STATS ----------------
                    Row(
                      children: [
                        _StatCard(
                          icon: Icons.local_fire_department,
                          iconColor: Colors.blue,
                          value: streak.toString(),
                          label: "Days Streak",
                        ),
                        const SizedBox(width: 14),
                        _StatCard(
                          icon: Icons.group,
                          iconColor: Colors.purple,
                          value: crewsJoined.toString(),
                          label: "Crew Joined",
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ---------------- TASK COMPLETED ----------------
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Overall tasks completed",
                                  style: theme.textTheme.titleMedium,
                                ),
                                Text(
                                  "Keep up your fire!",
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.6),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: theme.colorScheme.primary
                                .withOpacity(0.15),
                            child: Text(
                              tasksCompleted.toString(),
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    Text(
                      "SETTINGS",
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 10),

                    _SettingsTile(
                      icon: Icons.settings,
                      title: "Settings",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 10),

                    _SettingsTile(
                      icon: Icons.logout,
                      iconColor: Colors.red,
                      title: "Logout",
                      onTap: confirmLogout,
                      isDestructive: true,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

// --------------------------------------------------------------------------
// CARD WIDGETS
// --------------------------------------------------------------------------

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: iconColor.withOpacity(0.15),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------------------------------

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SettingsTile({
    required this.icon,
    this.iconColor,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? theme.colorScheme.onSurface),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isDestructive ? Colors.red : null,
                ),
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
