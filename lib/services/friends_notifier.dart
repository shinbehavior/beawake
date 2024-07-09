import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firebase_service.dart';
import '../models/friend.dart';

class FriendsNotifier extends StateNotifier<List<Friend>> {
  final FirebaseService _firebaseService;

  FriendsNotifier(this._firebaseService) : super([]);

  Future<void> fetchFriends(String userId) async {
    state = await _firebaseService.fetchFriends(userId);
  }

  void searchFriends(String query) {
    if (query.isEmpty) {
      fetchFriends('mockUser1Id'); // Refresh the full list
    } else {
      state = state.where((friend) =>
          friend.name.toLowerCase().contains(query.toLowerCase()) ||
          friend.email.toLowerCase().contains(query.toLowerCase())).toList();
    }
  }

  Future<void> addFriend(String userId, String friendCode) async {
    await _firebaseService.addFriend(userId, friendCode);
    await fetchFriends(userId);
  }

  Future<void> updateFriendState(String userId, String newState) async {
    await _firebaseService.updateUserState(userId, newState);
    await fetchFriends(userId); // Refresh the friends list
  }
}