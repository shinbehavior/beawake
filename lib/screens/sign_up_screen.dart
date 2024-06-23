import 'package:flutter/material.dart';

class SignUpScreen extends StatelessWidget {
  final VoidCallback onSkip;
  final Function(String) onSelectMockUser;

  const SignUpScreen({required this.onSkip, required this.onSelectMockUser, Key? key}) : super(key: key);

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
            ElevatedButton(
              onPressed: onSkip,
              child: const Text('Skip'),
            ),
            ElevatedButton(
              onPressed: () => onSelectMockUser("mockUser1Id"),
              child: const Text('Use Mock User 1'),
            ),
            ElevatedButton(
              onPressed: () => onSelectMockUser("mockUser2Id"),
              child: const Text('Use Mock User 2'),
            ),
          ],
        ),
      ),
    );
  }
}
