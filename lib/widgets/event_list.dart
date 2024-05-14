// lib/widgets/event_list.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/event_manager.dart';

class EventList extends StatelessWidget {
  String formatTime(String timestamp) {
    DateTime dateTime = DateTime.parse(timestamp);
    return DateFormat('hh:mm a').format(dateTime);
  }

  String formatDate(String timestamp) {
    DateTime dateTime = DateTime.parse(timestamp);
    return DateFormat('MMM dd').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EventManager>(
      builder: (context, manager, child) {
        if (manager.events.isEmpty) {
          return Center(child: Text('No events yet'));
        }

        return ListView.builder(
          itemCount: manager.events.length,
          itemBuilder: (context, index) {
            final event = manager.events.reversed.toList()[index];
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: ListTile(
                leading: Icon(
                  event.type == 'awake' ? Icons.wb_sunny : Icons.nightlight_round,
                  color: event.type == 'awake' ? Colors.orange : Colors.blue,
                  size: 40.0,
                ),
                title: Text(
                  formatTime(event.timestamp),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
                subtitle: Text(
                  formatDate(event.timestamp),
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
              ),
            );
          },
        );
      },
    );
  }
}