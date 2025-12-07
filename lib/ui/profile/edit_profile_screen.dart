import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileScreen extends StatefulWidget {
  final String currentName;
  final String currentBio;
  final String currentAvatarUrl; // base64 string

  const EditProfileScreen({
    super.key,
    required this.currentName,
    required this.currentBio,
    required this.currentAvatarUrl,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController bioController;

  File? newAvatarFile;
  String avatarBase64 = ""; // safe storage

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.currentName);
    bioController = TextEditingController(text: widget.currentBio);
    avatarBase64 = widget.currentAvatarUrl; // may be empty
  }

  Future<void> pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 55, // compress to make Base64 small
    );

    if (picked != null) {
      newAvatarFile = File(picked.path);

      final bytes = await newAvatarFile!.readAsBytes();
      setState(() {
        avatarBase64 = base64Encode(bytes); // safe forever
      });
    }
  }

  Future<void> saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final name = nameController.text.trim();
    final bio = bioController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Name cannot be empty!")),
      );
      return;
    }


    await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
      "name": name,
      "bio": bio,
      "avatarBase64": avatarBase64, // SAFE value
    }, SetOptions(merge: true));

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("user_name", name);
    prefs.setString("user_bio", bio);
    prefs.setString("user_avatar", avatarBase64); // SAFE local save

    Navigator.pop(context, true); // return success
  }

  // -------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    ImageProvider? avatarProvider;
    if (avatarBase64.isNotEmpty) {
      try {
        avatarProvider = MemoryImage(base64Decode(avatarBase64));
      } catch (_) {
        avatarProvider = null;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            GestureDetector(
              onTap: pickAvatar,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                backgroundImage: avatarProvider,
                child: avatarProvider == null
                    ? Icon(
                        Icons.camera_alt,
                        size: 32,
                        color: theme.colorScheme.primary,
                      )
                    : null,
              ),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Your Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: bioController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Bio",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: saveProfile,
                child: const Text(
                  "Save Changes",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
