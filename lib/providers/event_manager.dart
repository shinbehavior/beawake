import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/awake_sleep_event.dart';

class EventManager extends ChangeNotifier {
  List<Event> events = [];

  // Fetch events from Firestore
  Future<void> fetchEvents() async {
    try {
      var snapshot = await FirebaseFirestore.instance.collection('events').get();
      events = snapshot.docs
          .map((doc) => Event.fromJson(doc.data()))
          .toList();
      notifyListeners();
    } catch (e) {
      print('Failed to fetch events: $e');
    }
  }

  // Add a new event
  Future<void> addEvent(String type) async {
    final newEvent = Event(type, DateTime.now());
    if (events.isNotEmpty && events.last.type == type) {
      print("Cannot add the same event type consecutively.");
      return;
    }
    try {
      await FirebaseFirestore.instance.collection('events').add(newEvent.toJson());
      events.add(newEvent);
      notifyListeners();
    } catch (e) {
      print('Failed to add event: $e');
    }
  }

  // Clear all events
  void clearEvents() {
    events.clear();
    notifyListeners();
  }
}
