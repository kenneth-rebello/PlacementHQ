import 'package:flutter/material.dart';
import 'package:placementshq/providers/drives.dart';
import 'package:placementshq/providers/officer.dart';
import 'package:provider/provider.dart';

class CurrentDrivesScreen extends StatefulWidget {
  static const routeName = "/current_drives";
  @override
  _CurrentDrivesScreenState createState() => _CurrentDrivesScreenState();
}

class _CurrentDrivesScreenState extends State<CurrentDrivesScreen> {
  bool _loading = false;

  @override
  void initState() {
    _loading = true;
    String collegeId = Provider.of<Officer>(context, listen: false).collegeId;
    Provider.of<Drives>(context, listen: false).loadDrives(collegeId).then((_) {
      setState(() {
        _loading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final drives = Provider.of<Drives>(context).drives;
    return Scaffold(
      appBar: AppBar(
        title: Text("Current Drives"),
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Container(),
    );
  }
}
