import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_manager.dart';

class TodoListModal extends StatefulWidget {
  final String userId;

  const TodoListModal({Key? key, required this.userId}) : super(key: key);

  @override
  _TodoListModalState createState() => _TodoListModalState();
}

class _TodoListModalState extends State<TodoListModal> {
  final TextEditingController _taskController = TextEditingController();
  List<Map<String, dynamic>> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  void _fetchTasks() async {
    final eventManager = Provider.of<EventManager>(context, listen: false);
    try {
      await eventManager.fetchTodoList();
      setState(() {
        _tasks = eventManager.todoList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Failed to fetch todo list: $e");
    }
  }

  void _addTask() {
    if (_taskController.text.isNotEmpty) {
      setState(() {
        _tasks.add({'task': _taskController.text, 'status': 'pending'});
        _taskController.clear();
      });
    }
  }

  void _editTask(int index) {
    _taskController.text = _tasks[index]['task'];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Task'),
          content: TextField(
            controller: _taskController,
            decoration: const InputDecoration(labelText: 'Task'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _tasks[index]['task'] = _taskController.text;
                  _taskController.clear();
                });
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _updateTaskStatus(int index, String status) {
    setState(() {
      _tasks[index]['status'] = status;
    });
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
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
    return Container(
      padding: const EdgeInsets.all(16.0),
      height: MediaQuery.of(context).size.height * 0.5, // Set the height of the modal sheet
      child: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add TODO List',
                  style: Theme.of(context).textTheme.headline6,
                ),
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
                        title: Text(_tasks[index]['task']),
                        subtitle: Text(_tasks[index]['status']),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _editTask(index);
                            } else if (value == 'delete') {
                              _deleteTask(index);
                            } else {
                              _updateTaskStatus(index, value);
                            }
                          },
                          itemBuilder: (BuildContext context) {
                            return [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Text('Edit'),
                              ),
                              const PopupMenuItem(
                                value: 'done',
                                child: Text('Mark as Done'),
                              ),
                              const PopupMenuItem(
                                value: 'failed',
                                child: Text('Mark as Failed'),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ];
                          },
                        ),
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: _saveTasks,
                  child: const Text('Save'),
                ),
              ],
            ),
    );
  }
}
