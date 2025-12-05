import 'package:flutter/material.dart';
import 'dart:math';

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

              // -------------------- HEADER --------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Create Crew",
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

              const SizedBox(height: 20),

              // CARD CONTAINER
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // -------------------- CREW NAME --------------------
                    Text("Crew Name",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        )),
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

                    // -------------------- DESCRIPTION --------------------
                    Text("Description",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        )),
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

                    // -------------------- PRIVATE TOGGLE --------------------
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

                    // -------------------- PRIVATE CODE --------------------
                    if (isPrivate)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant
                              .withOpacity(0.2),
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
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.6),
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

                    // -------------------- BUTTON --------------------
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
                        onPressed: () {
                          // later: send to Firebase
                        },
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
