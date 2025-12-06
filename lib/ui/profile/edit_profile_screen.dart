import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileScreen extends StatefulWidget {
  final String currentName;
  final String currentBio;
  final String currentAvatarUrl;

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
  String avatarUrl = "";

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.currentName);
    bioController = TextEditingController(text: widget.currentBio);
    avatarUrl = widget.currentAvatarUrl;
  }

  // -------------------------------------------------------------------
  // ✔ PICK AVATAR FROM GALLERY
  // -------------------------------------------------------------------
  Future<void> pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        newAvatarFile = File(picked.path);
      });

      /// For now we WON'T upload to Firebase Storage.
      /// We only store local path (demo mode)
      avatarUrl = picked.path;
    }
  }

  // -------------------------------------------------------------------
  // ✔ SAVE PROFILE DATA
  // -------------------------------------------------------------------
Future<void> saveProfile() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  String name = nameController.text.trim();
  String bio = bioController.text.trim();

  if (name.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Name cannot be empty!")),
    );
    return;
  }

  // --------------------------
  // 🚫 NO Firebase Storage
  // 🚫 NO uploading
  // ✔ Avatar saved locally ONLY
  // --------------------------

  String? localAvatarPath = avatarUrl; // This is a device path

  // -------------------------
  // UPDATE FIRESTORE (no avatar)
  // -------------------------
  await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
    "name": name,
    "bio": bio,
  }, SetOptions(merge: true));

  // -------------------------
  // UPDATE LOCAL STORAGE
  // -------------------------
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString("user_name", name);
  prefs.setString("user_bio", bio);

  // Save avatar path locally (ONLY local)
  prefs.setString("user_avatar", localAvatarPath ?? "");

  Navigator.pop(context, true);
}


  // -------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ---------------------------------------------------
            // ✔ AVATAR PICKER
            // ---------------------------------------------------
            GestureDetector(
              onTap: pickAvatar,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                backgroundImage: newAvatarFile != null
                    ? FileImage(newAvatarFile!)
                    : (avatarUrl.isNotEmpty
                        ? FileImage(File(avatarUrl)) as ImageProvider
                        : null),
                child: avatarUrl.isEmpty && newAvatarFile == null
                    ? Icon(Icons.camera_alt,
                        size: 32, color: theme.colorScheme.primary)
                    : null,
              ),
            ),

            const SizedBox(height: 30),

            // ---------------------------------------------------
            // ✔ NAME FIELD
            // ---------------------------------------------------
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

            // ---------------------------------------------------
            // ✔ BIO FIELD
            // ---------------------------------------------------
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

            // ---------------------------------------------------
            // ✔ SAVE BUTTON
            // ---------------------------------------------------
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
