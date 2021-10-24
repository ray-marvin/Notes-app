import 'package:notes_app/Doodle/drawing_page.dart';
import 'package:flutter/material.dart';

// void main() {
//   runApp(MyApp());
// }

class MyApp1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NoteKeeper',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DrawingPage(),
    );
  }
}
