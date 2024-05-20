// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:beawake/widgets/toggle_main_button.dart';
import 'package:beawake/widgets/event_list.dart';

class HomeScreen extends StatelessWidget {
  final String userId;

  const HomeScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E1E2C), Color(0xFF2C2C38)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AnimatedToggleButton(),
              const SizedBox(height: 20),
              Expanded(child: EventList()),
            ],
          ),
        ),
      ),
    );
  }
}