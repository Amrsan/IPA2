import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Taskpage.dart';

class SearchScreen extends StatefulWidget {
  final List<Task> tasks;

  SearchScreen({required this.tasks});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Task> filteredTasks = [];
  final TextEditingController searchController = TextEditingController();

  void filterTasks(String query) {
    setState(() {
      filteredTasks = widget.tasks.where((task) {
        return task.title.toLowerCase().contains(query.toLowerCase()) ||
            task.content.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff027dc1),
        title: TextField(
          controller: searchController,
          autofocus: true,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search tasks...',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
          onChanged: filterTasks,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xff202124),
        ),
        child: ListView.builder(
          itemCount: filteredTasks.length,
          itemBuilder: (context, index) {
            final task = filteredTasks[index];
            return TaskCard(
              task: task,
              onTap: (updatedTask) {
                setState(() {
                  // Update the task in the original list
                  int originalIndex = widget.tasks.indexWhere(
                          (t) => t.title == task.title && t.content == task.content);
                  if (originalIndex != -1) {
                    widget.tasks[originalIndex] = updatedTask;
                  }
                  // Update the filtered list
                  filteredTasks[index] = updatedTask;
                });
              },
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}