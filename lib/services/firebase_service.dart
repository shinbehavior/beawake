import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  Future<void> saveEvent(String userId, String eventType, DateTime eventTime) async {
    CollectionReference users = FirebaseFirestore.instance.collection('Users');
    await users.doc(userId).collection('Events').add({
      'type': eventType,
      'time': eventTime,
    });
  }
}
