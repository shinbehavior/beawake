import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'package:beawake/widgets/sign_in_button.dart';

class SignUpScreen extends StatefulWidget {
  final VoidCallback onSkip;
  final Function(String) onSelectMockUser;

  const SignUpScreen({
    Key? key,
    required this.onSkip,
    required this.onSelectMockUser,
  }) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  void _navigateToHome(String userId) {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => HomeScreen(userId: userId),
      ),
    );
  }

  void _selectMockUser(String mockUserId) {
    widget.onSelectMockUser(mockUserId);
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
                if (user != null) {
                  _navigateToHome(user.uid);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sign in failed')),
                  );
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
              onPressed: () => _selectMockUser("mockUser1Id"),
              child: const Text('Use Mock User 1'),
            ),
            ElevatedButton(
              onPressed: () => _selectMockUser("mockUser2Id"),
              child: const Text('Use Mock User 2'),
            ),
          ],
        ),
      ),
    );
  }
}
