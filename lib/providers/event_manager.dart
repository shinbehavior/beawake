import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/awake_sleep_event.dart';
import '../services/firebase_service.dart';
import 'package:intl/intl.dart';

class EventManager extends ChangeNotifier {
  List<Event> events = [];
  List<Map<String, dynamic>> todoList = [];
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
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.data()['type'] as String;
      }
      return 'none';
    } catch (e) {
      print('Failed to fetch the last event: $e');
      return 'error';
    }
  }

  Future<void> fetchEvents() async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();
      events = snapshot.docs.map((doc) => Event.fromJson(doc.data())).toList();
      notifyListeners();
    } catch (e) {
      print('Failed to fetch events: $e');
    }
  }

  Future<void> fetchTodoList() async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('todos')
          .doc(userId)
          .get();

      if (snapshot.exists) {
        todoList = List<Map<String, dynamic>>.from(snapshot.data()!['tasks']);
      } else {
        todoList = [];
      }
      notifyListeners();
    } catch (e) {
      print('Failed to fetch todo list: $e');
    }
  }

  Future<void> saveTodoList(List<Map<String, dynamic>> tasks) async {
    try {
      await _firebaseService.saveTodoList(userId!, tasks);
      todoList = tasks;
      notifyListeners();
    } catch (e) {
      print('Failed to save todo list: $e');
    }
  }

  Future<bool> addEvent(String type) async {
    DateTime now = DateTime.now();
    String formattedDate = formatDateTime(now);
    final newEvent = Event(userId!, type, formattedDate);

    if (events.isNotEmpty && events.last.type == type) {
      print("Cannot add the same event type consecutively.");
      return false;
    }

    try {
      await _firebaseService.saveEvent(userId!, type, now);
      events.add(newEvent);
      notifyListeners();
      return true;
    } catch (e) {
      print('Failed to add event: $e');
      return false;
    }
  }

  void clearEvents() {
    events.clear();
    notifyListeners();
  }
}
