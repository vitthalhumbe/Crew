import 'package:flutter/material.dart';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../crews/crew_detail_screen.dart';

class CreateCrewScreen extends StatefulWidget {
  const CreateCrewScreen({super.key});

  @override
  State<CreateCrewScreen> createState() => _CreateCrewScreenState();
}

class _CreateCrewScreenState extends State<CreateCrewScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  bool isPrivate = false;
  String privateCode = "";

  @override
  void initState() {
    super.initState();
    privateCode = _generateCode();
  }

  String _generateCode() {
    const letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    const nums = "0123456789";
    final rand = Random();

    return "${letters[rand.nextInt(26)]}${letters[rand.nextInt(26)]}${letters[rand.nextInt(26)]}"
        "-${nums[rand.nextInt(10)]}${nums[rand.nextInt(10)]}${nums[rand.nextInt(10)]}";
  }

  Future<void> createCrew() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("You must be logged in")));
      return;
    }

    final name = nameController.text.trim();
    final desc = descController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Crew name cannot be empty")),
      );
      return;
    }

    try {
      final crewId = FirebaseFirestore.instance.collection("crews").doc().id;

      await FirebaseFirestore.instance.collection("crews").doc(crewId).set({
        "crewId": crewId,
        "name": name,
        "description": desc,
        "isPrivate": isPrivate,
        "privateCode": isPrivate ? privateCode : "",
        "createdBy": user.uid,
        "createdAt": DateTime.now(),
        "members": [user.uid],
        "memberCount": 1,
      });
      FirebaseFirestore.instance.collection("users").doc(user.uid).set({
        "crewsJoined": FieldValue.increment(1),
        "crews": FieldValue.arrayUnion([crewId]),
      }, SetOptions(merge: true));

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CrewDetailScreen(crewId: crewId)),
      );
      // SUCCESS POPUP
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Crew created successfully!"),
          backgroundColor: Colors.green,
        ),
      );
      nameController.clear();
      descController.clear();
      setState(() {
        isPrivate = false;
        privateCode = _generateCode();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to create crew: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Create Crew",
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Crew Name",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),

                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: "Enter a name for your crew",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      "Description",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),

                    TextField(
                      controller: descController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: "Describe what your crew is all about",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.lock_outline,
                            color: Colors.purple,
                            size: 22,
                          ),
                        ),

                        const SizedBox(width: 14),
                        Text(
                          "Set crew to private",
                          style: theme.textTheme.bodyLarge,
                        ),

                        const Spacer(),
                        Switch(
                          value: isPrivate,
                          activeColor: theme.colorScheme.primary,
                          onChanged: (value) {
                            setState(() {
                              isPrivate = value;
                              if (value) privateCode = _generateCode();
                            });
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    if (isPrivate)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant.withOpacity(0.2,),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.4),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              "Private Code",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.6,),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              privateCode,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.copy, size: 18),
                          ],
                        ),
                      ),

                    const SizedBox(height: 26),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: createCrew,
                        child: const Text(
                          "Create Crew",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
