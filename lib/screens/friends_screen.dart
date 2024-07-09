import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import '../providers/providers.dart';
import '../models/friend.dart';
import 'package:intl/intl.dart';

class FriendsScreen extends ConsumerStatefulWidget {
  final String userId;

  const FriendsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _userFriendCode = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(friendsProvider.notifier).fetchFriends(widget.userId);
      _fetchUserFriendCode();
    });
  }

  Future<void> _fetchUserFriendCode() async {
    final firebaseService = ref.read(firebaseServiceProvider);
    final friendCode = await firebaseService.getUserFriendCode(widget.userId);
    setState(() {
      _userFriendCode = friendCode;
    });
  }

  Future<void> _handleRefresh() async {
    await ref.read(friendsProvider.notifier).fetchFriends(widget.userId);
  }

  void _showAddFriendDialog() {
    final TextEditingController codeController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2C38),
          title: Text('Add Friend', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your Friend Code:', style: TextStyle(color: Colors.white70)),
              SizedBox(height: 8),
              Text(
                _userFriendCode,
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              TextField(
                controller: codeController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Enter friend's code",
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[600]!)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.grey[400])),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Add', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                try {
                  await ref.read(friendsProvider.notifier).addFriend(widget.userId, codeController.text);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Friend added successfully'), backgroundColor: Colors.green),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error adding friend: $e'), backgroundColor: Colors.red),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final friends = ref.watch(friendsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E2C),
        title: Text('Friends', style: TextStyle(color: Colors.white)),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search friends',
                hintStyle: TextStyle(color: Colors.grey[600]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                filled: true,
                fillColor: const Color(0xFF2C2C38),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                ref.read(friendsProvider.notifier).searchFriends(value);
              },
            ),
          ),
          Expanded(
            child: LiquidPullToRefresh(
              onRefresh: _handleRefresh,
              color: const Color(0xFF2C2C38),  // Adjust this color to match your theme
              backgroundColor: Colors.blue[700],
              height: 80,  // Reduced height
              animSpeedFactor: 4,
              showChildOpacityTransition: false,
              child: friends.isEmpty
                  ? _buildEmptyState()
                  : _buildFriendsList(friends),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.person_add, color: Colors.white),
        backgroundColor: const Color(0xFF2C2C38),
        onPressed: _showAddFriendDialog,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'No friends yet. Add some friends to get started!',
        style: TextStyle(color: Colors.white, fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildFriendsList(List<Friend> friends) {
    return ListView.builder(
      itemCount: friends.length,
      itemBuilder: (context, index) {
        final friend = friends[index];
        return _buildFriendListTile(friend);
      },
    );
  }

  Widget _buildFriendListTile(Friend friend) {
    final stateColor = friend.currentState == 'awake' ? Colors.green : Colors.blue;
    final currentStateString = '${friend.currentState.capitalize()} since ${_formatTime(friend.currentStateTime)}';
    final previousStateString = 'Last ${friend.previousState.capitalize()} at ${_formatTime(friend.previousStateTime)}';

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(friend.avatarUrl),
        radius: 25,
      ),
      title: Text(friend.name, style: TextStyle(color: Colors.white, fontSize: 16)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            currentStateString,
            style: TextStyle(color: stateColor, fontSize: 14),
          ),
          Text(
            previousStateString,
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
          ),
        ],
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final eventDate = DateTime(time.year, time.month, time.day);

    if (eventDate == today) {
      return DateFormat('HH:mm').format(time);
    } else if (eventDate == yesterday) {
      return 'Yesterday ${DateFormat('HH:mm').format(time)}';
    } else {
      return DateFormat('MMM d, HH:mm').format(time);
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}