import 'package:flutter/material.dart';
import 'package:beawake/widgets/toggle_main_button.dart';
import 'package:beawake/widgets/event_list.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E1E2C), Color(0xFF2C2C38)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedToggleButton(),
            Expanded(child: EventList()),
          ],
        ),
      ),
    );
  }
}