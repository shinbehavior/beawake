import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_manager.dart'; // Ensure this path matches your project structure

class EventList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<EventManager>(
      builder: (context, manager, child) {
        return ListView.builder(
          itemCount: manager.events.length,
          itemBuilder: (context, index) {
            final event = manager.events[index];
            return ListTile(
              title: Text('${event.type} at ${event.timestamp}'),
            );
          },
        );
      },
    );
  }
}
