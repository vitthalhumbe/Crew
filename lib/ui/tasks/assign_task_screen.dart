import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AssignTaskScreen extends StatefulWidget {
  final String crewId;

  const AssignTaskScreen({super.key, required this.crewId});

  @override
  State<AssignTaskScreen> createState() => _AssignTaskScreenState();
}

class _AssignTaskScreenState extends State<AssignTaskScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController linkController = TextEditingController();
  final TextEditingController conceptController = TextEditingController();

  List<String> concepts = [];

  void addConcept() {
    final concept = conceptController.text.trim();
    if (concept.isNotEmpty) {
      setState(() {
        concepts.add(concept);
      });
      conceptController.clear();
    }
  }

  Future<void> assignTask() async {
    final title = titleController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Task title cannot be empty!")),
      );
      return;
    }


    await FirebaseFirestore.instance
        .collection("crews")
        .doc(widget.crewId)
        .collection("tasks")
        .add({
          "title": titleController.text.trim(),
          "description": descriptionController.text.trim(),
          "concepts": concepts,
          "link": linkController.text.trim(),
          "completedBy": [], 
          "createdAt": Timestamp.now(),
        });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Task assigned successfully!")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: assignTask,
            child: const Text("Assign Task", style: TextStyle(fontSize: 16)),
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Assign task",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: "Task Title",
                  hintText: "e.g., Problem: Data Cleaning in Titanic DB",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Description",
                  hintText: "Add a detailed description...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: linkController,
                decoration: InputDecoration(
                  labelText: "Add Link",
                  hintText: "https://example.com",
                  prefixIcon: const Icon(Icons.link),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Text("Concepts to know", style: theme.textTheme.titleMedium),

              const SizedBox(height: 10),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: concepts
                    .map(
                      (concept) => Chip(
                        label: Text(concept),
                        deleteIcon: const Icon(Icons.close),
                        onDeleted: () {
                          setState(() {
                            concepts.remove(concept);
                          });
                        },
                      ),
                    )
                    .toList(),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: conceptController,
                      decoration: InputDecoration(
                        hintText: "Add a concept...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: addConcept,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
