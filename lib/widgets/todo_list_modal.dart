import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_manager.dart';
import 'package:intl/intl.dart';

class TodoListModal extends StatefulWidget {
  final String userId;

  const TodoListModal({Key? key, required this.userId}) : super(key: key);

  @override
  _TodoListModalState createState() => _TodoListModalState();
}

class _TodoListModalState extends State<TodoListModal> {
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _listNameController = TextEditingController();
  List<Map<String, dynamic>> _currentTasks = [];
  String? _currentListName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchTodoLists());
  }

  void _fetchTodoLists() async {
    final eventManager = Provider.of<EventManager>(context, listen: false);
    eventManager.setUserId(widget.userId);
    try {
      await eventManager.fetchTodoLists();
      setState(() {
        _isLoading = false;
        if (eventManager.todoLists.isEmpty) {
          _showCreateNewListDialog();
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Failed to fetch todo lists: $e");
    }
  }

  void _showCreateNewListDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create New Todo List'),
          content: TextField(
            controller: _listNameController,
            decoration: const InputDecoration(hintText: "Enter list name"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Create'),
              onPressed: () {
                if (_listNameController.text.isNotEmpty) {
                  _currentListName = _listNameController.text;
                  _currentTasks = [];
                  Navigator.of(context).pop();
                  setState(() {});
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _addTask() {
    if (_taskController.text.isNotEmpty) {
      setState(() {
        _currentTasks.add({'task': _taskController.text, 'status': 'pending'});
        _taskController.clear();
      });
    }
  }

  void _editTask(int index) {
    _taskController.text = _currentTasks[index]['task'];
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
                  _currentTasks[index]['task'] = _taskController.text;
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
      _currentTasks[index]['status'] = status;
    });
  }

  void _deleteTask(int index) {
    setState(() {
      _currentTasks.removeAt(index);
    });
  }

  void _saveTasks() async {
    if (_currentListName == null || _currentListName!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please create a list first')),
      );
      return;
    }
    final eventManager = Provider.of<EventManager>(context, listen: false);
    await eventManager.saveTodoList(_currentListName!, _currentTasks);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final eventManager = Provider.of<EventManager>(context);
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      height: MediaQuery.of(context).size.height * 0.8,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (eventManager.todoLists.isNotEmpty && _currentListName == null)
                  Expanded(
                    child: ListView.builder(
                      itemCount: eventManager.todoLists.length,
                      itemBuilder: (context, index) {
                        String listName = eventManager.todoLists.keys.elementAt(index);
                        String creationDate = DateFormat('MMM dd').format(DateTime.now()); // Replace with actual creation date
                        return ListTile(
                          title: Text(listName),
                          subtitle: Text(creationDate),
                          onTap: () {
                            setState(() {
                              _currentListName = listName;
                              _currentTasks = eventManager.todoLists[listName]!;
                            });
                          },
                        );
                      },
                    ),
                  ),
                if (eventManager.todoLists.isNotEmpty && _currentListName == null)
                  ElevatedButton(
                    onPressed: _showCreateNewListDialog,
                    child: const Text('Create New List'),
                  ),
                if (_currentListName != null) ...[
                  Text(
                    _currentListName!,
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
                      itemCount: _currentTasks.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_currentTasks[index]['task']),
                          subtitle: Text(_currentTasks[index]['status']),
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
              ],
            ),
    );
  }
}