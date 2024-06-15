import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_manager.dart';

class TodoListDialog extends StatefulWidget {
  final String userId;

  const TodoListDialog({Key? key, required this.userId}) : super(key: key);

  @override
  _TodoListDialogState createState() => _TodoListDialogState();
}

class _TodoListDialogState extends State<TodoListDialog> {
  final TextEditingController _taskController = TextEditingController();
  final List<String> _tasks = [];

  void _addTask() {
    if (_taskController.text.isNotEmpty) {
      setState(() {
        _tasks.add(_taskController.text);
        _taskController.clear();
      });
    }
  }

  void _saveTasks() async {
    if (_tasks.isNotEmpty) {
      final eventManager = Provider.of<EventManager>(context, listen: false);
      await eventManager.saveTodoList(_tasks);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add TODO List'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _taskController,
            decoration: InputDecoration(
              labelText: 'Enter task',
              suffixIcon: IconButton(
                icon: const Icon(Icons.add),
                onPressed: _addTask,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_tasks[index]),
                );
              },
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveTasks,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
