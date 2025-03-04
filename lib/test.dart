import 'package:flutter/material.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: EarthInfoScreen(),
//     );
//   }
// }

class EarthInfoScreen extends StatefulWidget {
  @override
  _EarthInfoScreenState createState() => _EarthInfoScreenState();
}

class _EarthInfoScreenState extends State<EarthInfoScreen> {
  final String initialTitle = "";
  final String initialContent = """ """;

  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController.text = initialTitle;
    _contentController.text = initialContent;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        backgroundColor: Colors.grey,
        title: TextField(
          controller: _titleController,
          style: TextStyle(color: Colors.white, fontSize: 20.0),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Enter title',
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: TextField(
          controller: _contentController,
          maxLines: null, // Allows multiple lines
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Enter content',
          ),
          style: TextStyle(fontSize: 16.0),
        ),
      ),
    );
  }
}