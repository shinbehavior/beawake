import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';

// Assume we have a FriendsProvider that manages the state of friends
final friendsProvider = StateNotifierProvider<FriendsNotifier, List<Friend>>((ref) => FriendsNotifier());

class FriendsScreen extends ConsumerStatefulWidget {
  final String userId;

  const FriendsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  final TextEditingController _searchController = TextEditingController();
  bool _isListView = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(friendsProvider.notifier).fetchFriends(widget.userId);
    });
  }

  void _onRefresh() async {
    await ref.read(friendsProvider.notifier).fetchFriends(widget.userId);
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final friends = ref.watch(friendsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Friends', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(_isListView ? Icons.grid_view : Icons.list),
            onPressed: () => setState(() => _isListView = !_isListView),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search friends',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onChanged: (value) {
                ref.read(friendsProvider.notifier).searchFriends(value);
              },
            ),
          ),
          Expanded(
            child: SmartRefresher(
              controller: _refreshController,
              onRefresh: _onRefresh,
              child: friends.isEmpty
                  ? _buildShimmerList()
                  : _isListView
                      ? _buildListView(friends)
                      : _buildGridView(friends),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.person_add),
        onPressed: () {
          // Show add friend dialog
        },
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: ListTile(
            leading: CircleAvatar(),
            title: Container(height: 16, color: Colors.white),
            subtitle: Container(height: 12, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildListView(List<Friend> friends) {
    return ListView.builder(
      itemCount: friends.length,
      itemBuilder: (context, index) {
        final friend = friends[index];
        return Slidable(
          endActionPane: ActionPane(
            motion: ScrollMotion(),
            children: [
              SlidableAction(
                onPressed: (_) {
                  // Remove friend action
                },
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Remove',
              ),
            ],
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(friend.avatarUrl),
            ),
            title: Text(friend.name, style: GoogleFonts.poppins()),
            subtitle: Text(friend.email),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to friend details
            },
          ),
        );
      },
    );
  }

  Widget _buildGridView(List<Friend> friends) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
      ),
      itemCount: friends.length,
      itemBuilder: (context, index) {
        final friend = friends[index];
        return Card(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(friend.avatarUrl),
              ),
              SizedBox(height: 8),
              Text(friend.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              Text(friend.email, style: TextStyle(fontSize: 12)),
            ],
          ),
        );
      },
    );
  }
}

class Friend {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final String currentState;
  final DateTime currentStateTime;
  final String previousState;
  final DateTime previousStateTime;

  Friend({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.currentState,
    required this.currentStateTime,
    required this.previousState,
    required this.previousStateTime,
  });
}

class FriendsNotifier extends StateNotifier<List<Friend>> {
  FriendsNotifier() : super([]);

  Future<void> fetchFriends(String userId) async {
    // Implement friend fetching logic
  }

  void searchFriends(String query) {
    // Implement friend search logic
  }
}