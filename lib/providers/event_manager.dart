import 'package:beawake/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/awake_sleep_event.dart';
import 'package:intl/intl.dart';

class EventManager extends ChangeNotifier {
  List<Event> events = [];
  String? userId;
  final FirebaseService _firebaseService = FirebaseService();

  EventManager(this.userId);

  String formatDateTime(DateTime dateTime) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
    return formatter.format(dateTime);
  }

  Future<String> getLastEvent() async {
    try {
      var snapshot = await FirebaseFirestore.instance
        .collection('events')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.data()['type'] as String;
      }
      return 'none';
    } catch (e) {
      print('Failed to fetch the last evnet: $e');
      return 'error';
    }
  }

  // Fetch events from Firestore
  Future<void> fetchEvents() async {
    try {
      var snapshot = await FirebaseFirestore.instance.collection('events').where('userId', isEqualTo: userId).get();
      events = snapshot.docs
          .map((doc) => Event.fromJson(doc.data()))
          .toList();
      notifyListeners();
    } catch (e) {
      print('Failed to fetch events: $e');
    }
  }

  // Add a new event
Future<bool> addEvent(String type) async {
  DateTime now = DateTime.now();
  String formattedDate = formatDateTime(now);
  final newEvent = Event(userId!, type, formattedDate);

  if (events.isNotEmpty && events.last.type == type) {
    print("Cannot add the same event type consecutively.");
    return false;
  }

  try {
    await FirebaseFirestore.instance.collection('events').add(newEvent.toJson());
    events.add(newEvent);
    notifyListeners();
    return true;
  } catch (e) {
    print('Failed to add event: $e');
    return false;
  }
}

  // Clear all events
  void clearEvents() {
    events.clear();
    notifyListeners();
  }
}
