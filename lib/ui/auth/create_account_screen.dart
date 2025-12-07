import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  bool obscurePassword = true;
  bool acceptTerms = false;
  bool isLoading = false;

  Future<void> createAccount() async {
    if (!acceptTerms) return;

    String name = nameController.text.trim();
    String bio = bioController.text.trim();
    String email = emailController.text.trim();
    String pass = passController.text.trim();

    if (name.isEmpty || email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Name, Email, Password required")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      UserCredential cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: pass);

      User? user = cred.user;
      if (user == null) throw Exception("User not created");

      await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
        "uid": user.uid,
        "name": name,
        "email": email,
        "bio": bio.isEmpty ? "No bio added yet." : bio,
        "streak": 0,
        "crewsJoined": 0,
        "tasksCompleted": 0,
        "createdAt": DateTime.now(),
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("user_name", name);
      prefs.setString("user_email", email);
      prefs.setString("user_bio", bio);
      prefs.setInt("user_streak", 0);
      prefs.setInt("user_crews", 0);
      prefs.setInt("user_tasks", 0);

      Navigator.pushReplacementNamed(context, "/mainShell");
    } on FirebaseAuthException catch (e) {
      String msg = "Signup failed";

      if (e.code == "email-already-in-use") msg = "Email already registered!";
      if (e.code == "weak-password") msg = "Choose a stronger password.";

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unexpected error occurred.")),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              Text(
                "Create Account",
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              _label("Name"),
              TextField(
                controller: nameController,
                decoration: _input("Enter your name"),
              ),

              const SizedBox(height: 20),

              _label("Email"),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _input("Enter your email"),
              ),

              const SizedBox(height: 20),

              _label("Password"),
              TextField(
                controller: passController,
                obscureText: obscurePassword,
                decoration: _input("Enter your password").copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => obscurePassword = !obscurePassword),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              _label("Bio"),
              TextField(
                controller: bioController,
                maxLines: 3,
                decoration: _input("Tell us a bit about yourself"),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Checkbox(
                    value: acceptTerms,
                    onChanged: (v) => setState(() => acceptTerms = v!),
                  ),
                  const Expanded(
                    child: Text("I accept the terms & conditions*"),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: acceptTerms && !isLoading ? createAccount : null,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Create Account",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 25),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? "),
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushReplacementNamed(context, "/login"),
                    child: Text(
                      "Sign in",
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }


  Widget _label(String text) =>
      Text(text, style: Theme.of(context).textTheme.labelLarge);

  InputDecoration _input(String hint) => InputDecoration(
    hintText: hint,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
  );
}
