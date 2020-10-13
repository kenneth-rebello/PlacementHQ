import 'package:flutter/material.dart';

class CurrentDrivesScreen extends StatefulWidget {
  static const routeName = "/current_drives";
  @override
  _CurrentDrivesScreenState createState() => _CurrentDrivesScreenState();
}

class _CurrentDrivesScreenState extends State<CurrentDrivesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Current Drives"),
      ),
      body: Container(),
    );
  }
}
