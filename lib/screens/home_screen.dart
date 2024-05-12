import 'package:beawake/widgets/toggle_main_button.dart';
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedToggleButton(),
          Expanded(child: EventList()),
        ],
      ),
    );
  }
}