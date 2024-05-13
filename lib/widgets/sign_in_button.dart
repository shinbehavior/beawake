import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class SignInButton extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final void Function(User) onSignInSuccess;

  SignInButton({required this.onSignInSuccess});

  Future<void> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );
      UserCredential userCredential = await _auth.signInWithCredential(oauthCredential);
      User? user = userCredential.user;

      if (user != null) {
        onSignInSuccess(user);
      }
    } catch (e) {
      // Handle errors or cancellation
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: signInWithApple,
      child: Text("Sign in with Apple"),
    );
  }
}
