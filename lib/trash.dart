import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'Taskpage.dart';

class TrashScreen extends StatefulWidget {
  final List<Task> deletedTasks;
  final Function(Task) onTaskRestored;

  TrashScreen({
    required this.deletedTasks,
    required this.onTaskRestored,
  });

  @override
  _TrashScreenState createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  late List<Task> deletedTasks;

  @override
  void initState() {
    super.initState();
    deletedTasks = widget.deletedTasks;
  }

  Future<void> _clearTrash() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      deletedTasks.clear();
    });
    await prefs.setStringList('deleted_tasks', []);
  }

  Future<void> _restoreTask(Task task) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get current tasks
    List<String>? taskList = prefs.getStringList('tasks');
    List<Task> tasks = [];
    if (taskList != null) {
      tasks = taskList.map((task) => Task.fromJson(json.decode(task))).toList();
    }
    
    // Add task to main list
    tasks.add(task);
    await prefs.setStringList('tasks', 
      tasks.map((task) => json.encode(task.toJson())).toList()
    );

    // Remove from deleted tasks
    setState(() {
      deletedTasks.remove(task);
    });
    await prefs.setStringList('deleted_tasks',
      deletedTasks.map((task) => json.encode(task.toJson())).toList()
    );

    // Call the callback to update the main screen
    widget.onTaskRestored(task);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trash'),
        backgroundColor: Color(0xff027dc1),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Clear Trash'),
                    content: Text('Are you sure you want to permanently delete all items?'),
                    actions: [
                      TextButton(
                        child: Text('Cancel'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      TextButton(
                        child: Text('Clear'),
                        onPressed: () {
                          _clearTrash();
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xff202124),
        ),
        child: ListView.builder(
          itemCount: deletedTasks.length,
          itemBuilder: (context, index) {
            final task = deletedTasks[index];
            return Card(
              margin: EdgeInsets.all(8.0),
              color: Colors.white.withOpacity(0.1),
              child: ListTile(
                title: Text(
                  task.title,
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                subtitle: Text(
                  task.content,
                  style: GoogleFonts.roboto(
                    color: Colors.white70,
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(
                    Icons.restore,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Restore Task'),
                          content: Text('Do you want to restore this task?'),
                          actions: [
                            TextButton(
                              child: Text('Cancel'),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            TextButton(
                              child: Text('Restore'),
                              onPressed: () {
                                _restoreTask(task);
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}