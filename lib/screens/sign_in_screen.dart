import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/sign_in_button.dart';
import 'home_screen.dart';
import '../services/firebase_service.dart';

class SignInScreen extends StatelessWidget {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign In")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SignInButton(onSignInSuccess: (User user) {
              _promptUserProfileSettings(context, user.uid);
            }),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => HomeScreen()),
                );
              },
              child: Text("Skip"),
            )
          ],
        ),
      ),
    );
  }

  void _promptUserProfileSettings(BuildContext context, String userId) {
    final TextEditingController _usernameController = TextEditingController();
    bool _skipAvatar = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Profile Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _skipAvatar = true;
                  _saveUserProfile(context, userId, _usernameController.text, _skipAvatar);
                },
                child: Text('Skip Avatar'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                _saveUserProfile(context, userId, _usernameController.text, _skipAvatar);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _saveUserProfile(BuildContext context, String userId, String username, bool skipAvatar) async {
    if (username.isNotEmpty) {
      await FirebaseService().updateUserProfile(userId, username, skipAvatar);
      Navigator.of(context).pop();
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => HomeScreen()));
    }
  }
}
