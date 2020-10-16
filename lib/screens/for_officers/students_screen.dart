import 'package:flutter/material.dart';
import 'package:placementshq/providers/officer.dart';
import 'package:provider/provider.dart';

class StudentsScreen extends StatefulWidget {
  static const routeName = "/students";
  @override
  _StudentsScreenState createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  @override
  void initState() {
    Provider.of<Officer>(context, listen: false).loadStudents();
    super.initState();
  }

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
