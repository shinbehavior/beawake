import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beawake/widgets/toggle_main_button.dart';
import 'package:beawake/widgets/event_list.dart';
import 'package:beawake/widgets/todo_list_modal.dart';
import '../providers/event_manager.dart';

class HomeScreen extends ConsumerWidget {
  final String userId;

  const HomeScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventManager = ref.watch(eventManagerProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      eventManager.setUserId(userId);
      eventManager.fetchEvents();
    });

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

  void _openTodoListModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return TodoListModal(userId: userId);
      },
    );
  }
}