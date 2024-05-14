// lib/screens/sign_up_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:beawake/services/firebase_service.dart';
import 'home_screen.dart';
import 'package:beawake/widgets/sign_in_button.dart';

class SignUpScreen extends StatelessWidget {
  final FirebaseService _firebaseService = FirebaseService();
  final VoidCallback onSkip;

  SignUpScreen({required this.onSkip});

  void _navigateToHome(BuildContext context, User? user) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> mockUsers = [
      {"id": "mockUser1Id", "name": "Mock User 1"},
      {"id": "mockUser2Id", "name": "Mock User 2"},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SignInButton(
              onSignInSuccess: (user) => _navigateToHome(context, user),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: onSkip,
              child: Text('Skip'),
            ),
            SizedBox(height: 20),
            Text("Select Mock User for Testing:"),
            for (var mockUser in mockUsers)
              ElevatedButton(
                onPressed: () async {
                  await _firebaseService.createMockUsers();
                  // Simulate user sign-in with mock user
                  // Use mockUser["id"] to simulate the Firebase Auth UID
                  _navigateToHome(context, null);
                },
                child: Text(mockUser["name"]!),
              ),
          ],
        ),
      ),
    );
  }
}