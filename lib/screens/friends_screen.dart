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

  Future<List<Map<String, dynamic>>> _fetchFriendsData(List<dynamic> friendIds) async {
    List<Map<String, dynamic>> friendsData = [];
    for (String friendId in friendIds) {
      DocumentSnapshot friendDoc = await _firestore.collection('users').doc(friendId).get();
      Map<String, dynamic> friendData = friendDoc.data() as Map<String, dynamic>;
      List<Map<String, dynamic>> events = await _firebaseService.fetchUserEvents(friendId);
      friendData['events'] = events;
      friendsData.add(friendData);
    }
    return friendsData;
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

                  return FutureBuilder<List<Map<String, dynamic>>>(
                    future: _fetchFriendsData(friends),
                    builder: (context, friendsSnapshot) {
                      if (!friendsSnapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      var friendsData = friendsSnapshot.data!;

                      return ListView.builder(
                        itemCount: friendsData.length,
                        itemBuilder: (context, index) {
                          var friendData = friendsData[index];
                          var events = friendData['events'] as List<Map<String, dynamic>>;

                          return ExpansionTile(
                            leading: friendData['avatarUrl'] != null
                                ? CircleAvatar(
                                    backgroundImage: NetworkImage(friendData['avatarUrl']),
                                  )
                                : const CircleAvatar(
                                    child: Icon(Icons.person),
                                  ),
                            title: Text(friendData['username'] ?? 'No Name'),
                            subtitle: Text(friendData['email'] ?? 'No Email'),
                            children: events.map((event) {
                              return ListTile(
                                title: Text('${event['type']} at ${event['timestamp']}'),
                              );
                            }).toList(),
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