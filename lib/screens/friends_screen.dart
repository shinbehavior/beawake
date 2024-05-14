import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';

class FriendsScreen extends StatefulWidget {
  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseService _firebaseService = FirebaseService();
  TextEditingController _friendCodeController = TextEditingController();

  void _addFriend() async {
    final user = _auth.currentUser;
    final friendCode = _friendCodeController.text;

    if (user != null && friendCode.isNotEmpty) {
      try {
        await _firebaseService.addFriend(user.uid, friendCode);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Friend added successfully')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error adding friend: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E1E2C), Color(0xFF2C2C38)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Friends Page'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _friendCodeController,
                decoration: InputDecoration(
                  labelText: 'Enter friend code',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.add),
                    onPressed: _addFriend,
                  ),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<DocumentSnapshot>(
                stream: _firestore.collection('users').doc(user?.uid).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  var userData = snapshot.data?.data() as Map<String, dynamic>;
                  var friends = userData['friends'] as List<dynamic>;

                  return ListView.builder(
                    itemCount: friends.length,
                    itemBuilder: (context, index) {
                      return FutureBuilder<DocumentSnapshot>(
                        future: _firestore.collection('users').doc(friends[index]).get(),
                        builder: (context, friendSnapshot) {
                          if (!friendSnapshot.hasData) {
                            return ListTile(title: Text('Loading...'));
                          }

                          var friendData = friendSnapshot.data?.data() as Map<String, dynamic>;
                          return ListTile(
                            leading: friendData['avatarUrl'] != null
                                ? CircleAvatar(
                                    backgroundImage: NetworkImage(friendData['avatarUrl']),
                                  )
                                : CircleAvatar(
                                    child: Icon(Icons.person),
                                  ),
                            title: Text(friendData['username'] ?? 'No Name'),
                            subtitle: Text(friendData['email'] ?? 'No Email'),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}