import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> signInWithApple() async {
    try {
      final appleIdCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oAuthProvider = OAuthProvider('apple.com');
      final credential = oAuthProvider.credential(
        idToken: appleIdCredential.identityToken,
        accessToken: appleIdCredential.authorizationCode,
      );

      final authResult = await FirebaseAuth.instance.signInWithCredential(credential);
      final firebaseUser = authResult.user;

      if (firebaseUser != null) {
        final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
        if (!userDoc.exists) {
          await _firestore.collection('users').doc(firebaseUser.uid).set({
            'email': appleIdCredential.email,
            'fullName': '${appleIdCredential.givenName} ${appleIdCredential.familyName}',
            'friendCode': _generateFriendCode(),
            'friends': [],
          });
        }
      }
      return firebaseUser;
    } catch (e) {
      print('Error signing in with Apple: $e');
      return null;
    }
  }

  String _generateFriendCode() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  Future<void> updateUserProfile(String userId, String username, bool skipAvatar) async {
    await _firestore.collection('users').doc(userId).update({
      'username': username,
      if (!skipAvatar) 'avatarUrl': 'path/to/default/avatar.png',
    });
  }

  Future<void> saveEvent(String userId, String eventType, DateTime eventTime) async {
    CollectionReference users = _firestore.collection('Users');
    await users.doc(userId).collection('Events').add({
      'type': eventType,
      'time': eventTime,
    });
  }

  Future<void> addFriend(String userId, String friendCode) async {
    final querySnapshot = await _firestore.collection('users').where('friendCode', isEqualTo: friendCode).get();

    if (querySnapshot.docs.isNotEmpty) {
      final friendId = querySnapshot.docs.first.id;

      await _firestore.collection('users').doc(userId).update({
        'friends': FieldValue.arrayUnion([friendId])
      });

      await _firestore.collection('users').doc(friendId).update({
        'friends': FieldValue.arrayUnion([userId])
      });
    } else {
      throw Exception('No user found with this friend code');
    }
  }
}
