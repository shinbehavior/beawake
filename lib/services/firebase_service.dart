import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:beawake/utils/friend_code.dart';
import '../models/awake_sleep_event.dart';
import '../models/friend.dart';

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
          String friendCode = await _generateUniqueFriendCode();
          await _firestore.collection('users').doc(firebaseUser.uid).set({
            'email': appleIdCredential.email,
            'fullName': '${appleIdCredential.givenName} ${appleIdCredential.familyName}',
            'friendCode': friendCode,
            'friends': [],
            'avatarUrl': 'https://i.pravatar.cc/150?img=${firebaseUser.uid.hashCode % 70}',
            'currentState': 'awake',
            'currentStateTime': FieldValue.serverTimestamp(),
            'previousState': 'sleep',
            'previousStateTime': FieldValue.serverTimestamp(),
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

  Future<void> updateUserState(String userId, String newState) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      String currentState = userDoc['currentState'];
      DateTime currentStateTime = (userDoc['currentStateTime'] as Timestamp).toDate();

      await _firestore.collection('users').doc(userId).update({
        'previousState': currentState,
        'previousStateTime': Timestamp.fromDate(currentStateTime),
        'currentState': newState,
        'currentStateTime': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating user state: $e');
      throw e;
    }
  }

  Future<void> createMockUsers() async {
      List<Map<String, dynamic>> mockUsers = [
        {
          'id': 'mockUser1Id',
          'email': 'mockuser1@example.com',
          'fullName': 'Alice Smith',
          'friendCode': await _generateUniqueFriendCode(),
          'avatarUrl': 'https://i.pinimg.com/736x/63/ba/02/63ba0265bdb20faedbfd7578253a07f6.jpg',
          'currentState': 'awake',
          'currentStateTime': FieldValue.serverTimestamp(),
          'previousState': 'sleep',
          'previousStateTime': FieldValue.serverTimestamp(),
          'friends': ['mockUser2Id', 'mockUser3Id'],
        },
        {
          'id': 'mockUser2Id',
          'email': 'mockuser2@example.com',
          'fullName': 'Bob Johnson',
          'friendCode': await _generateUniqueFriendCode(),
          'avatarUrl': 'https://i.pinimg.com/736x/4a/cf/54/4acf54fd5b02c1010aa5a92e47b6aedb.jpg',
          'currentState': 'sleep',
          'currentStateTime': FieldValue.serverTimestamp(),
          'previousState': 'awake',
          'previousStateTime': FieldValue.serverTimestamp(),
          'friends': ['mockUser1Id', 'mockUser3Id'],
        },
        {
          'id': 'mockUser3Id',
          'email': 'mockuser3@example.com',
          'fullName': 'Charlie Brown',
          'friendCode': await _generateUniqueFriendCode(),
          'avatarUrl': 'https://i.pinimg.com/736x/0c/76/a1/0c76a1717bd6beef3e790b89d0c3ffd8.jpg',
          'currentState': 'awake',
          'currentStateTime': FieldValue.serverTimestamp(),
          'previousState': 'sleep',
          'previousStateTime': FieldValue.serverTimestamp(),
          'friends': ['mockUser1Id', 'mockUser2Id'],
        },
      ];

      for (var user in mockUsers) {
        await _firestore.collection('users').doc(user['id']).set(user);
      }
    }

  Future<List<Friend>> fetchFriends(String userId) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (!userDoc.exists) {
        print('User document does not exist for userId: $userId');
        return [];
      }

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      if (!userData.containsKey('friends')) {
        print('Friends field does not exist in user document for userId: $userId');
        return [];
      }

      List<String> friendIds = List<String>.from(userData['friends'] ?? []);

      List<Friend> friends = [];
      for (String friendId in friendIds) {
        DocumentSnapshot friendDoc = await _firestore.collection('users').doc(friendId).get();
        if (friendDoc.exists) {
          Map<String, dynamic> friendData = friendDoc.data() as Map<String, dynamic>;
          friends.add(Friend(
            id: friendId,
            name: friendData['fullName'] ?? 'Unknown',
            email: friendData['email'] ?? 'Unknown',
            avatarUrl: friendData['avatarUrl'] ?? 'https://i.pravatar.cc/150',
            currentState: friendData['currentState'] ?? 'Unknown',
            currentStateTime: (friendData['currentStateTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
            previousState: friendData['previousState'] ?? 'Unknown',
            previousStateTime: (friendData['previousStateTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
          ));
        } else {
          print('Friend document does not exist for friendId: $friendId');
        }
      }

      return friends;
    } catch (e) {
      print('Error fetching friends: $e');
      return [];
    }
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

  Future<List<Event>> fetchUserEvents(String userId) async {
    try {
      var snapshot = await FirebaseFirestore.instance
        .collection('events')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(2)  // We only need the latest two events
        .get();
      return snapshot.docs.map((doc) => Event.fromJson(doc.data())).toList();
    } catch (e) {
      print('Failed to fetch user events: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getFriendStatus(String friendId) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(friendId).get();
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      return {
        'currentState': userData['currentState'],
        'currentStateTime': userData['currentStateTime'],
        'previousState': userData['previousState'],
        'previousStateTime': userData['previousStateTime'],
      };
    } catch (e) {
      print('Error fetching friend status: $e');
      return {};
    }
  }
 
  Future<String> getUserFriendCode(String userId) async {
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
    return userDoc['friendCode'] as String;
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
