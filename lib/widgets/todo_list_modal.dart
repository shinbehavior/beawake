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
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _currentTasks = [];
  String? _currentListName;
  bool _isLoading = true;
  String _searchQuery = '';

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
          _createNewList();
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Failed to fetch todo lists: $e");
    }
  }

  String _getRelativeDateName() {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime yesterday = today.subtract(const Duration(days: 1));

    if (today == DateTime(now.year, now.month, now.day)) {
      return 'Today';
    } else if (yesterday == DateTime(now.year, now.month, now.day)) {
      return 'Yesterday';
    } else {
      return DateFormat('EEEE').format(now);
    }
  }

  void _createNewList() {
    setState(() {
      _currentListName = _getRelativeDateName();
      _currentTasks = [];
      _listNameController.text = _currentListName!;
    });
  }

  void _showEditListNameDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[800],
          title: const Text('Edit List Name', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: _listNameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Enter list name",
              hintStyle: TextStyle(color: Colors.grey[400]),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[400]!)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue[300]!)),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save', style: TextStyle(color: Colors.blue)),
              onPressed: () {
                if (_listNameController.text.isNotEmpty) {
                  setState(() {
                    _currentListName = _listNameController.text;
                  });
                  Navigator.of(context).pop();
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
          backgroundColor: Colors.grey[800],
          title: const Text('Edit Task', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: _taskController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Task',
              labelStyle: TextStyle(color: Colors.grey[400]),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[400]!)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue[300]!)),
            ),
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
              child: const Text('Save', style: TextStyle(color: Colors.blue)),
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
    setState(() {
      _currentListName = null;
      _currentTasks = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final eventManager = Provider.of<EventManager>(context);
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_currentListName == null) ...[
                  TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search lists',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                      fillColor: Colors.grey[800],
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: eventManager.todoLists.length,
                      itemBuilder: (context, index) {
                        String listName = eventManager.todoLists.keys.elementAt(index);
                        if (_searchQuery.isNotEmpty && 
                            !listName.toLowerCase().contains(_searchQuery.toLowerCase())) {
                          return const SizedBox.shrink();
                        }
                        return Card(
                          color: Colors.grey[800],
                          elevation: 2,
                          child: ListTile(
                            leading: const Icon(Icons.list, color: Colors.white),
                            title: Text(listName, style: const TextStyle(color: Colors.white)),
                            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                            onTap: () {
                              setState(() {
                                _currentListName = listName;
                                _currentTasks = List<Map<String, dynamic>>.from(eventManager.todoLists[listName]!);
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _createNewList,
                    child: const Text('Create New List'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ],
                if (_currentListName != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _currentListName!,
                          style: Theme.of(context).textTheme.headline6?.copyWith(color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: _showEditListNameDialog,
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            _currentListName = null;
                            _currentTasks = [];
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _taskController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Enter task',
                      labelStyle: const TextStyle(color: Colors.white70),
                      fillColor: Colors.grey[800],
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.add, color: Colors.white),
                        onPressed: _addTask,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _currentTasks.length,
                      itemBuilder: (context, index) {
                        return Dismissible(
                          key: Key(_currentTasks[index]['task']),
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) {
                            _deleteTask(index);
                          },
                          child: Card(
                            color: Colors.grey[800],
                            child: ListTile(
                              leading: Icon(_getStatusIcon(_currentTasks[index]['status']), color: Colors.white),
                              title: Text(_currentTasks[index]['task'], style: const TextStyle(color: Colors.white)),
                              subtitle: Text(_currentTasks[index]['status'], style: TextStyle(color: Colors.grey[400])),
                              trailing: PopupMenuButton<String>(
                                color: Colors.grey[700],
                                iconColor: Colors.white,
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _editTask(index);
                                  } else {
                                    _updateTaskStatus(index, value);
                                  }
                                },
                                itemBuilder: (BuildContext context) {
                                  return [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Text('Edit', style: TextStyle(color: Colors.white)),
                                    ),
                                    const PopupMenuItem(
                                      value: 'done',
                                      child: Text('Mark as Done', style: TextStyle(color: Colors.white)),
                                    ),
                                    const PopupMenuItem(
                                      value: 'pending',
                                      child: Text('Mark as Pending', style: TextStyle(color: Colors.white)),
                                    ),
                                    const PopupMenuItem(
                                      value: 'failed',
                                      child: Text('Mark as Failed', style: TextStyle(color: Colors.white)),
                                    ),
                                  ];
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _saveTasks,
                    child: const Text('Save List'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'done':
        return Icons.check_circle;
      case 'failed':
        return Icons.cancel;
      default:
        return Icons.pending;
    }
  }
}
