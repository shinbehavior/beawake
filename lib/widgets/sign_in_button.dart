import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class SignInButton extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
      await _auth.signInWithCredential(oauthCredential);
      //Navigate to home screen or handle sign in success
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