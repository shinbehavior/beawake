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
          ],
        ),
      ),
    );
  }
}