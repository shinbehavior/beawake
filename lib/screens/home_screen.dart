// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:beawake/widgets/toggle_main_button.dart';
import 'package:beawake/widgets/event_list.dart';
import 'package:beawake/widgets/todo_list_modal.dart';

class HomeScreen extends StatelessWidget {
  final String userId;

  const HomeScreen({Key? key, required this.userId}) : super(key: key);

  void _openTodoListModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return TodoListModal(userId: userId);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E1E2C), Color(0xFF2C2C38)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AnimatedToggleButton(),
              const SizedBox(height: 20),
              Expanded(child: EventList()),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _openTodoListModal(context),
                child: const Text('Add TODO List'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
