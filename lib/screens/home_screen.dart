import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_manager.dart';
import '../widgets/event_list.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Awake/Sleep")),
      body: Column(
        children: [
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => Provider.of<EventManager>(context, listen: false).addEvent('awake'),
                child: Text('I\'m Awake'),
              ),
              ElevatedButton(
                onPressed: () => Provider.of<EventManager>(context, listen: false).addEvent('sleep'),
                child: Text('I\'m Sleep'),
              ),
            ],
          ),
          Expanded( // This widget is now moved under the ButtonBar
            child: EventList(),
          ),
        ],
      ),
    );
  }
}
