import 'package:flutter/material.dart';
import 'package:placementhq/providers/drives.dart';
import 'package:placementhq/providers/officer.dart';
import 'package:placementhq/screens/for_officers/new_drive_screen.dart';
import 'package:placementhq/widgets/drive_list_item/drive_list_item.dart';
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
      if (mounted)
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
        title: Text(
          "Current Drives",
          style: Theme.of(context).textTheme.headline1,
        ),
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : drives.length <= 0
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "You do not have any active placement drives at the moment.",
                      textAlign: TextAlign.center,
                    ),
                    RaisedButton(
                      child: Text(
                        "Add New Drive",
                        style: Theme.of(context).textTheme.button,
                      ),
                      onPressed: () {
                        Navigator.of(context)
                            .pushNamed(NewDriveScreen.routeName);
                      },
                    ),
                  ],
                )
              : Container(
                  margin: EdgeInsets.all(10),
                  child: ListView.builder(
                    itemBuilder: (ctx, idx) => DriveListItem(
                      drive: drives[idx],
                    ),
                    itemCount: drives.length,
                  ),
                ),
    );
  }
}
