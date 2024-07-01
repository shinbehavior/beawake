import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/awake_sleep_event.dart';
import '../services/firebase_service.dart';
import 'package:intl/intl.dart';

class EventManager extends ChangeNotifier {
  List<Event> events = [];
  Map<String, List<Map<String, dynamic>>> todoLists = {};
  String? userId;
  bool isAwake = true;
  final FirebaseService _firebaseService = FirebaseService();

  EventManager(this.userId);

  void setUserId(String userId) {
    print('Setting user ID: $userId');
    this.userId = userId;
    initializeUserStatus();
    fetchTodoLists();
  }

  String formatDateTime(DateTime dateTime) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
    return formatter.format(dateTime);
  }

  Future<void> initializeUserStatus() async {
    if (userId == null) return;
    
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        isAwake = snapshot.docs.first.data()['type'] == 'awake';
      } else {
        // If no events, default to awake
        isAwake = true;
      }
      notifyListeners();
    } catch (e) {
      print('Failed to initialize user status: $e');
    }
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
    if (userId == null) return;
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

  Future<void> fetchTodoLists() async {
    if (userId == null) {
      print('User ID is null, cannot fetch todo lists');
      return;
    }
    try {
      todoLists = await _firebaseService.fetchTodoLists(userId!);
      print('Fetched ${todoLists.length} todo lists');
      notifyListeners();
    } catch (e) {
      print('Failed to fetch todo lists: $e');
      todoLists = {}; // Initialize with an empty map if there's an error
      notifyListeners();
    }
  }

  Future<void> saveTodoList(String listName, List<Map<String, dynamic>> tasks) async {
    if (userId == null) {
      print('User ID is null, cannot save todo list');
      return;
    }
    try {
      await _firebaseService.saveTodoList(userId!, listName, tasks);
      todoLists[listName] = tasks;
      print('Saved todo list: $listName');
      notifyListeners();
    } catch (e) {
      print('Failed to save todo list: $e');
    }
  }

  Future<void> deleteTodoList(String listName) async {
    if (userId == null) {
      print('User ID is null, cannot delete todo list');
      return;
    }
    try {
      await _firebaseService.deleteTodoList(userId!, listName);
      todoLists.remove(listName);
      print('Deleted todo list: $listName');
      notifyListeners();
    } catch (e) {
      print('Failed to delete todo list: $e');
    }
  }

  Future<bool> toggleEvent() async {
    String newEventType = isAwake ? 'sleep' : 'awake';
    if (events.isNotEmpty && events.first.type == newEventType) {
      print("Cannot add the same event type consecutively.");
      return false;
    }
    bool success = await addEvent(newEventType);
    if (success) {
      isAwake = !isAwake;
      notifyListeners();
    }
    return success;
  }

  Future<bool> addEvent(String type) async {
    DateTime now = DateTime.now();
    String formattedDate = formatDateTime(now);
    final newEvent = Event(userId!, type, formattedDate);
    if (events.isNotEmpty && events.first.type == type) {
      print("Cannot add the same event type consecutively.");
      return false;
    }
    try {
      await _firebaseService.saveEvent(userId!, type, now);
      events.insert(0, newEvent);
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

  void clearData() {
    events.clear();
    todoLists.clear();
    notifyListeners();
  }
}