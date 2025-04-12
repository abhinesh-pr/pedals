import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:pedals/views/authentication/auth_page.dart'; // Using GetX for navigation

class Dashboard extends StatelessWidget {
  final String username; // User's username
  final String email; // User's email

  const Dashboard({required this.username, required this.email, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: const Text("Dashboard")),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Updated text theme properties
            Text(
              "Welcome, $username!",
              style: Theme.of(context).textTheme.headlineMedium, // Use headlineMedium for the title
            ),
            const SizedBox(height: 20),
            Text(
              "Email: $email",
              style: Theme.of(context).textTheme.bodyMedium, // Use bodyMedium for the email
            ),
            const SizedBox(height: 40),

            // Logout Button
            ElevatedButton(
              onPressed: () async {
                // Sign out the user
                await FirebaseAuth.instance.signOut();

                // Navigate back to the login screen
                Get.off(() => AuthPage()); // Navigate to LoginPage
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Set the background color to red
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 130), // Button padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}