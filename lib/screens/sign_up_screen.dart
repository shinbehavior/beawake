// lib/screens/sign_up_screen.dart
import 'package:flutter/material.dart';
import 'package:beawake/services/firebase_service.dart';
import 'home_screen.dart';
import 'package:beawake/widgets/sign_in_button.dart';

class SignUpScreen extends StatefulWidget {
  final VoidCallback onSkip;
  final Function(String) onSelectMockUser;

  SignUpScreen({required this.onSkip, required this.onSelectMockUser});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  void _navigateToHome(String userId) {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => HomeScreen(userId: userId),
      ),
    );
  }

  void _selectMockUser1() {
    widget.onSelectMockUser("mockUser1Id");
  }

  void _selectMockUser2() {
    widget.onSelectMockUser("mockUser2Id");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SignInButton(
              onSignInSuccess: (user) {
                if (mounted) {
                  _navigateToHome(user!.uid);
                }
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: widget.onSkip,
              child: const Text('Skip'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _selectMockUser1,
              child: const Text('Use Mock User 1'),
            ),
            ElevatedButton(
              onPressed: _selectMockUser2,
              child: const Text('Use Mock User 2'),
            ),
          ],
        ),
      ),
    );
  }
}