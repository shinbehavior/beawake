// lib/screens/friends_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';

class FriendsScreen extends StatefulWidget {
  final String userId;

  const FriendsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _friendCodeController = TextEditingController();
  String? _friendCode;

  @override
  void initState() {
    super.initState();
    _loadFriendCode();
  }

  void _loadFriendCode() async {
    final userDoc = await _firestore.collection('users').doc(widget.userId).get();
    setState(() {
      _friendCode = userDoc['friendCode'];
    });
  }

  void _addFriend() async {
    final friendCode = _friendCodeController.text;

    if (friendCode.isNotEmpty) {
      try {
        await _firebaseService.addFriend(widget.userId, friendCode);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Friend added successfully')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error adding friend: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E1E2C), Color(0xFF2C2C38)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Friends Page'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  TextField(
                    controller: _friendCodeController,
                    decoration: InputDecoration(
                      labelText: 'Enter friend code',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _addFriend,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Your Friend Code: ${_friendCode ?? "loading..."}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<DocumentSnapshot>(
                stream: _firestore.collection('users').doc(widget.userId).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
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
                            return const ListTile(title: Text('Loading...'));
                          }

                          var friendData = friendSnapshot.data?.data() as Map<String, dynamic>;
                          return ListTile(
                            leading: friendData['avatarUrl'] != null
                                ? CircleAvatar(
                                    backgroundImage: NetworkImage(friendData['avatarUrl']),
                                  )
                                : const CircleAvatar(
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