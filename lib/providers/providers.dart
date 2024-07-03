import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firebase_service.dart';
import '../services/friends_notifier.dart';

final firebaseServiceProvider = Provider<FirebaseService>((ref) => FirebaseService());

final friendsProvider = StateNotifierProvider<FriendsNotifier, List<Friend>>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return FriendsNotifier(firebaseService);
});