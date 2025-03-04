import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:ui';

import 'package:untitled/search.dart';
import 'package:untitled/trash.dart';
import 'package:flutter_langdetect/flutter_langdetect.dart';


void main() {
  runApp(TaskPage());
}

class TaskPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.system,
      darkTheme: ThemeData(brightness: Brightness.dark),
      debugShowCheckedModeBanner: false,
      home: TaskListScreen(),
    );
  }
}


class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> tasks = [];
  List<Task> deletedTasks = [];
  Task? removedTask;
  int? removedIndex;

  @override
  void initState() {
    super.initState();
    _loadTasks(); // Load tasks when the screen initializes
    _loadDeletedTasks(); // Add this line
  }
  Future<void> _saveDeletedTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> taskList = deletedTasks.map((task) => json.encode(task.toJson())).toList();
    await prefs.setStringList('deleted_tasks', taskList);
  }

// Save tasks to SharedPreferences
  Future<void> _saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> taskList =
        tasks.map((task) => json.encode(task.toJson())).toList();
    await prefs.setStringList('tasks', taskList);
  }

// Load tasks from SharedPreferences
  Future<void> _loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? taskList = prefs.getStringList('tasks');
    if (taskList != null) {
      setState(() {
        tasks =
            taskList.map((task) => Task.fromJson(json.decode(task))).toList();
      });
    }
  }

  Future<void> _loadDeletedTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? taskList = prefs.getStringList('deleted_tasks');
    if (taskList != null) {
      setState(() {
        deletedTasks = taskList.map((task) => Task.fromJson(json.decode(task))).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xff027dc1),
              ),
              child: Text(
                'Task Manager',
                style: GoogleFonts.roboto(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline),
              title: Text('Trash'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TrashScreen(
                      deletedTasks: deletedTasks,
                      onTaskRestored: (Task restoredTask) {
                        setState(() {
                          tasks.add(restoredTask);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Container(decoration:
      BoxDecoration( color: Color(0xff202124),
    //     gradient: LinearGradient(
    // colors: [
    // Color(0xff0295A9),
    //     Color(0xff12ADC1),
    //   // Color(0xffffffff),
    // // Color(0xff15979B),
    // // Color(0xff09D1c7),
    // Color(0xff46DFB1),
    // Color(0xff80EE98)
    // ],
    // begin: Alignment.topRight,
    // end: Alignment.bottomRight,
    // ),
      ),
        child: Column(

          children: <Widget>[AppBar(
            actions: [
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SearchScreen(tasks: tasks)),
                  );
                },
              ),
            ],

            // title: Center(
            //   child:
            //   Text(
            //     'Note List',
            //     style: GoogleFonts.roboto(fontSize: 30),
            //   ),
            // ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await _loadTasks();
                },
                child: ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return Dismissible(
                      key: UniqueKey(),
                      onDismissed: (direction) {
                        removedTask = tasks.removeAt(index);
                        removedIndex = index;
                        setState(() {
                          deletedTasks.add(removedTask!);  // Add the task to deletedTasks
                        });
                        _saveTasks(); // Save after deletion
                        _saveDeletedTasks(); // Save deleted tasks

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Task removed'),
                            action: SnackBarAction(
                              label: 'Undo',
                              onPressed: () {
                                if (removedTask != null && removedIndex != null) {
                                  setState(() {
                                    tasks.insert(removedIndex!, removedTask!);
                                    deletedTasks.remove(removedTask); // Remove from deletedTasks if undone
                                    _saveTasks(); // Save after undo
                                    _saveDeletedTasks(); // Save deleted tasks
                                  });
                                }
                              },
                            ),
                            duration: Duration(seconds: 5),
                          ),
                        );
                      },
                      background: Container(
                        color: Colors.red,
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        child: Icon(Icons.delete, color: Colors.white),
                        alignment: Alignment.centerLeft,
                      ),
                      child: InkWell(
                        // onDoubleTap: ,
                        child: TaskCard(
                          task: task,
                          onTap: (updatedTask) {
                            setState(() {
                              tasks[index] = updatedTask;
                              _saveTasks(); // Save after edit

                            });
                          },

                        ),
                      ),
                    );
                  },

                ),

              ),

            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    decoration: BoxDecoration(

                      // shape: BoxShape.rectangle,
                    ),
                    child: FloatingActionButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AddTaskScreen(onAddTask: (task) {
                              setState(() {
                                tasks.add(task);
                                _saveTasks(); // Save after adding a task
                              });
                            }),
                          ),
                        );
                      },
                      backgroundColor: Color(0xff027dc1),
                      child: Icon(Icons.add),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10,),

          ],
        ),
      ),
    );
  }
}




class TaskCard extends StatelessWidget {
  final Task task;
  final Function(Task) onTap;

  TaskCard({required this.task, required this.onTap});

  TextDirection _getTextDirection(String text) {
    final firstChar = text.isEmpty ? '' : text[0];
    return RegExp(r'^[\u0591-\u07FF\uFB1D-\uFDFD\uFE70-\uFEFC]').hasMatch(firstChar) 
        ? TextDirection.rtl 
        : TextDirection.ltr;
  }

  @override
  Widget build(BuildContext context) {
    final titleDirection = _getTextDirection(task.title);
    final contentDirection = _getTextDirection(task.content);

    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: InkWell(
          onTap: () {
            _showTaskDetailsDialog(context, task);
          },
          child: Card(
            margin: EdgeInsets.all(8.0),
            elevation: 0,
            color: task.isBlue
                ? Colors.blue.withOpacity(0.2)
                : Colors.white.withOpacity(0.1),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withOpacity(0.2)),
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                title: Directionality(
                  textDirection: titleDirection,
                  child: Container(
                    width: double.infinity,
                    alignment: titleDirection == TextDirection.rtl 
                        ? Alignment.centerRight 
                        : Alignment.centerLeft,
                    child: Text(
                      task.title,
                      style: GoogleFonts.roboto(
                        fontSize: 28,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: titleDirection == TextDirection.rtl 
                      ? CrossAxisAlignment.end 
                      : CrossAxisAlignment.start,
                  children: <Widget>[
                    Directionality(
                      textDirection: contentDirection,
                      child: Container(
                        width: double.infinity,
                        alignment: contentDirection == TextDirection.rtl 
                            ? Alignment.centerRight 
                            : Alignment.centerLeft,
                        child: Text(
                          task.content,
                          style: GoogleFonts.roboto(
                            fontSize: 20,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showTaskDetailsDialog(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
         // title: Text('Edit Task'),
          content: SingleChildScrollView(
            child: EditTaskScreen(task: task, onTaskUpdated: onTap),
          ),
        );
      },
    );
  }
}

class EditTaskScreen extends StatefulWidget {
  final Task task;
  final Function(Task) onTaskUpdated;

  EditTaskScreen({required this.task, required this.onTaskUpdated});

  @override
  _EditTaskScreenState createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  String selectedPriority = 'Medium';
  bool isExpanded = false;
  String? titleErrorText;
  String? contentErrorText;

  // Add helper method for text direction
  TextDirection _getTextDirection(String text) {
    final firstChar = text.isEmpty ? '' : text[0];
    return RegExp(r'^[\u0591-\u07FF\uFB1D-\uFDFD\uFE70-\uFEFC]').hasMatch(firstChar) 
        ? TextDirection.rtl 
        : TextDirection.ltr;
  }

  @override
  void initState() {
    super.initState();
    titleController.text = widget.task.title;
    contentController.text = widget.task.content;
    selectedPriority = widget.task.priority;
  }

  @override
  Widget build(BuildContext context) {
    List<String> priorities = ['Low', 'Medium', 'High'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Directionality(
          textDirection: _getTextDirection(titleController.text),
          child: TextField(
            controller: titleController,
            style: TextStyle(color: Colors.white, fontSize: 20.0),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: '',
            ),
            onChanged: (text) {
              // Trigger rebuild when text changes to update text direction
              setState(() {});
            },
          ),
        ),
        if (isExpanded)
          Column(
            children: priorities.map<Widget>((String priority) {
              return ListTile(
                title: Text(priority),
                onTap: () {
                  setState(() {
                    selectedPriority = priority;
                    isExpanded = false;
                  });
                },
              );
            }).toList(),
          ),
        SizedBox(height: 20),
        Directionality(
          textDirection: _getTextDirection(contentController.text),
          child: TextField(
            controller: contentController,
            maxLines: null,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: '',
            ),
            style: TextStyle(fontSize: 16.0),
            onChanged: (text) {
              // Trigger rebuild when text changes to update text direction
              setState(() {});
            },
          ),
        ),
        Center(
          child: ElevatedButton(
            onPressed: () {
              if (titleController.text.isEmpty ||
                  contentController.text.isEmpty) {
                setState(() {
                  if (titleController.text.isEmpty) {
                    titleErrorText = 'Field is empty';
                  } else {
                    titleErrorText = null;
                  }
                  if (contentController.text.isEmpty) {
                    contentErrorText = 'Field is empty';
                  } else {
                    contentErrorText = null;
                  }
                });
              } else {
                setState(() {
                  titleErrorText = null;
                  contentErrorText = null;
                });
                final title = titleController.text;
                final priority = selectedPriority;
                final content = contentController.text;
                final updatedTask =
                    Task(title: title, priority: priority, content: content);
                widget.onTaskUpdated(updatedTask);
                // You can implement the code to save the updated task here if needed.
                Navigator.of(context).pop();
              }
            },
            child: Text('Save'),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }
}

class AddTaskScreen extends StatefulWidget {
  final Function(Task) onAddTask;

  AddTaskScreen({required this.onAddTask});

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  // CollectionReference category = FirebaseFirestore.instance.collection('category');

  // Future<void> addUser() {
  //   // Call the user's CollectionReference to add a new user
  //   return category
  //       .add({
  //     "name" : titleController.text
  //   })
  //       .then((value) => print("User Added"))
  //       .catchError((error) => print("Failed to add user: $error"));
  // }

  String selectedPriority = 'Medium';
  bool isExpanded = false;
  String? titleErrorText;
  String? contentErrorText;

  // Add helper method for text direction
  TextDirection _getTextDirection(String text) {
    final firstChar = text.isEmpty ? '' : text[0];
    return RegExp(r'^[\u0591-\u07FF\uFB1D-\uFDFD\uFE70-\uFEFC]').hasMatch(firstChar) 
        ? TextDirection.rtl 
        : TextDirection.ltr;
  }

  @override
  Widget build(BuildContext context) {
    List<String> priorities = ['Low', 'Medium', 'High'];

    return Scaffold(
      appBar: AppBar(
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Directionality(
                textDirection: _getTextDirection(titleController.text),
                child: TextField(
                  controller: titleController,
                  style: TextStyle(color: Colors.white, fontSize: 20.0),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter title',
                  ),
                  onChanged: (text) {
                    // Trigger rebuild when text changes to update text direction
                    setState(() {});
                  },
                ),
              ),
              SizedBox(height: 20),
              if (isExpanded)
                Column(
                  children: priorities.map<Widget>((String priority) {
                    return ListTile(
                      title: Text(priority),
                      onTap: () {
                        setState(() {
                          selectedPriority = priority;
                          isExpanded = false;
                        });
                      },
                    );
                  }).toList(),
                ),
              SizedBox(height: 20),
              Directionality(
                textDirection: _getTextDirection(contentController.text),
                child: TextField(
                  controller: contentController,
                  maxLines: null,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter content',
                  ),
                  style: TextStyle(fontSize: 16.0),
                  onChanged: (text) {
                    // Trigger rebuild when text changes to update text direction
                    setState(() {});
                  },
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isEmpty ||
                        contentController.text.isEmpty) {
                      setState(() {
                        if (titleController.text.isEmpty) {
                          titleErrorText = 'Field is empty';
                        } else {
                          titleErrorText = null;
                        }
                        if (contentController.text.isEmpty) {
                          contentErrorText = 'Field is empty';
                        } else {
                          contentErrorText = null;
                        }
                      });
                    } else {
                      setState(() {
                        titleErrorText = null;
                        contentErrorText = null;
                      });
                      final title = titleController.text;
                      final priority = selectedPriority;
                      final content = contentController.text;
                      final task = Task(
                          title: title, priority: priority, content: content);
                      widget.onAddTask(task);
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text('Add Task'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }
}

class Task {
  final String title;
  final String priority;
  final String content;
  bool isBlue;

  Task(
      {required this.title,
      required this.priority,
      required this.content,
      this.isBlue = false});

  // Convert Task to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'priority': priority,
      'content': content,
      'isBlue': isBlue,
    };
  }

  // Convert JSON to Task
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['title'],
      priority: json['priority'],
      content: json['content'],
      isBlue: json['isBlue'] ?? false,
    );
  }
}

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = true;
  String selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Color(0xff027dc1),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xff202124),
        ),
        child: ListView(
          children: [
            ListTile(
              leading: Icon(Icons.dark_mode, color: Colors.white),
              title: Text('Dark Mode', 
                style: GoogleFonts.roboto(color: Colors.white)),
              trailing: Switch(
                value: isDarkMode,
                onChanged: (value) {
                  setState(() {
                    isDarkMode = value;
                    // Implement theme switching logic here
                  });
                },
              ),
            ),
            ListTile(
              leading: Icon(Icons.language, color: Colors.white),
              title: Text('Language',
                style: GoogleFonts.roboto(color: Colors.white)),
              subtitle: Text(selectedLanguage,
                style: GoogleFonts.roboto(color: Colors.white70)),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Select Language'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: Text('English'),
                            onTap: () {
                              setState(() {
                                selectedLanguage = 'English';
                              });
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            title: Text('Spanish'),
                            onTap: () {
                              setState(() {
                                selectedLanguage = 'Spanish';
                              });
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            title: Text('French'),
                            onTap: () {
                              setState(() {
                                selectedLanguage = 'French';
                              });
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.info_outline, color: Colors.white),
              title: Text('About',
                style: GoogleFonts.roboto(color: Colors.white)),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'Task Manager',
                  applicationVersion: '1.0.0',
                  applicationIcon: Icon(Icons.task_alt),
                  children: [
                    Text('A simple and efficient task management application.'),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
