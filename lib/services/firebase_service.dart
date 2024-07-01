import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:beawake/utils/friend_code.dart';

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
            'friendCode': await _generateUniqueFriendCode(),
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

  Future<String> _generateUniqueFriendCode() async {
    String code = '';
    bool isUnique = false;

    while (!isUnique) {
      code = CodeGenerator.generateCode(8);
      isUnique = await _checkCodeUnique(code);
    }

    return code;
  }

  Future<bool> _checkCodeUnique(String code) async {
    QuerySnapshot snapshot = await _firestore.collection('users').where('friendCode', isEqualTo: code).get();
    return snapshot.docs.isEmpty;
  }

  Future<void> createMockUsers() async {
    await _firestore.collection('users').doc('mockUser1Id').set({
      'email': 'mockuser1@example.com',
      'fullName': 'Mock User 1',
      'friendCode': await _generateUniqueFriendCode(),
      'friends': [],
    });

    await _firestore.collection('users').doc('mockUser2Id').set({
      'email': 'mockuser2@example.com',
      'fullName': 'Mock User 2',
      'friendCode': await _generateUniqueFriendCode(),
      'friends': [],
    });
  }

  Future<void> updateUserProfile(String userId, String username, bool skipAvatar) async {
    await _firestore.collection('users').doc(userId).update({
      'username': username,
      if (!skipAvatar) 'avatarUrl': 'path/to/default/avatar.png',
    });
  }

  Future<void> saveEvent(String userId, String eventType, DateTime eventTime) async {
    CollectionReference events = _firestore.collection('events');
    final Map<String, dynamic> event = {
      'userId': userId,
      'type': eventType,
      'timestamp': eventTime.toIso8601String(),
    };
    await events.add(event);
  }

  Future<void> saveTodoList(String userId, String listName, List<Map<String, dynamic>> tasks) async {
    try {
      await _firestore.collection('todos').doc('$userId-$listName').set({
        'userId': userId,
        'listName': listName,
        'tasks': tasks.map((task) => {
          'task': task['task'] ?? '',
          'status': task['status'] ?? 'pending',
        }).toList(),
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('Todo list saved successfully: $listName');
    } catch (e) {
      print('Error saving todo list: $e');
      throw e;
    }
  }

  Future<void> deleteTodoList(String userId, String listName) async {
    try {
      await _firestore.collection('todos').doc('$userId-$listName').delete();
      print('Todo list deleted successfully: $listName');
    } catch (e) {
      print('Error deleting todo list: $e');
      throw e;
    }
  }
  
  Future<Map<String, List<Map<String, dynamic>>>> fetchTodoLists(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('todos')
          .where('userId', isEqualTo: userId)
          .get();
      
      Map<String, List<Map<String, dynamic>>> todoLists = {};
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        String? listName = data['listName'] as String?;
        if (listName != null && data['tasks'] != null) {
          List<Map<String, dynamic>> tasks = [];
          for (var task in data['tasks']) {
            if (task is Map<String, dynamic>) {
              tasks.add({
                'task': task['task'] ?? '',
                'status': task['status'] ?? 'pending',
              });
            }
          }
          todoLists[listName] = tasks;
        }
      }
      print('Fetched ${todoLists.length} todo lists for user $userId');
      return todoLists;
    } catch (e) {
      print('Error fetching todo lists: $e');
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> fetchUserEvents(String userId) async {
    QuerySnapshot snapshot = await _firestore.collection('events')
      .where('userId', isEqualTo: userId)
      .orderBy('timestamp', descending: true)
      .orderBy('type', descending: false)
      .get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
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
