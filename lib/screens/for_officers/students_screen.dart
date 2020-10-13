import 'package:flutter/material.dart';

class StudentsScreen extends StatefulWidget {
  static const routeName = "/students";
  @override
  _StudentsScreenState createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Students List"),
      ),
      body: Container(),
    );
  }
}
