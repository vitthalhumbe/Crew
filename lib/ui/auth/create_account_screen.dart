import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  bool obscurePassword = true;
  bool acceptTerms = false;
  bool isLoading = false;

  Future<void> _createAccount() async {
    if (!acceptTerms) return;

    setState(() => isLoading = true);

    try {
      // 1️⃣ CREATE USER (Firebase Auth)
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      User? user = userCredential.user;

      if (user == null) throw Exception("User creation failed");

      // 2️⃣ SAVE USER DATA TO FIRESTORE
      await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
        "uid": user.uid,
        "name": nameController.text.trim(),
        "email": emailController.text.trim(),
        "bio": bioController.text.trim(),
        "createdAt": DateTime.now(),
      });

      // 3️⃣ MOVE TO MAIN APP
      Navigator.pushReplacementNamed(context, "/mainShell");
    } on FirebaseAuthException catch (e) {
      String msg = "Signup failed";

      if (e.code == "email-already-in-use") {
        msg = "This email is already registered.";
      } else if (e.code == "weak-password") {
        msg = "Choose a stronger password.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unexpected error occurred.")),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              Text(
                "Create Account",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: 25),

              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.grey.shade300,
                      child: const Icon(Icons.person, size: 60),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor:
                            Theme.of(context).colorScheme.primary,
                        child: const Icon(Icons.camera_alt,
                            size: 18, color: Colors.white),
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // NAME
              _label("Name"),
              TextField(
                controller: nameController,
                decoration: _input("Enter your name"),
              ),

              const SizedBox(height: 20),

              // EMAIL
              _label("Email"),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _input("Enter your email"),
              ),

              const SizedBox(height: 20),

              // PASSWORD
              _label("Password"),
              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                decoration: _input("Enter your password").copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => obscurePassword = !obscurePassword),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // BIO
              _label("Bio"),
              TextField(
                controller: bioController,
                maxLines: 3,
                decoration: _input("Tell us a bit about yourself"),
              ),

              const SizedBox(height: 20),

              // TERMS CHECKBOX
              Row(
                children: [
                  Checkbox(
                    value: acceptTerms,
                    onChanged: (value) =>
                        setState(() => acceptTerms = value!),
                  ),
                  const Expanded(
                    child: Text("I accept the terms & conditions*"),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // BUTTON
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: acceptTerms && !isLoading
                      ? _createAccount
                      : null,
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
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Simple UI helpers
  Widget _label(String text) => Text(
        text,
        style: Theme.of(context).textTheme.labelLarge,
      );

  InputDecoration _input(String hint) => InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      );
}
