import 'package:flutter/material.dart';
import 'package:placementhq/providers/auth.dart';
import 'package:placementhq/providers/drives.dart';
import 'package:placementhq/providers/officer.dart';
import 'package:placementhq/providers/user.dart';
import 'package:placementhq/screens/for_officers/new_drive_screen.dart';
import 'package:placementhq/widgets/drive_list_item/drive_list_item.dart';
import 'package:placementhq/widgets/other/empty_list.dart';
import 'package:placementhq/widgets/other/error.dart';
import 'package:provider/provider.dart';

class CurrentDrivesScreen extends StatefulWidget {
  static const routeName = "/current_drives";
  @override
  _CurrentDrivesScreenState createState() => _CurrentDrivesScreenState();
}

class _CurrentDrivesScreenState extends State<CurrentDrivesScreen> {
  bool _loading = false;
  bool _error = false;

  @override
  void initState() {
    _loading = true;
    String collegeId;
    final isTPC = Provider.of<Auth>(context, listen: false).isTPC;
    if (isTPC) {
      collegeId = Provider.of<User>(context, listen: false).collegeId;
    } else {
      collegeId = Provider.of<Officer>(context, listen: false).collegeId;
    }

    Provider.of<Drives>(context, listen: false).loadDrives(collegeId).then((_) {
      if (mounted)
        setState(() {
          _loading = false;
          _error = false;
        });
    }).catchError((e) {
      setState(() {
        _loading = false;
        _error = true;
      });
    });
    super.initState();
  }

  Future<void> _refresher() async {
    setState(() {
      _loading = true;
    });
    String collegeId;
    final isTPC = Provider.of<Auth>(context, listen: false).isTPC;
    if (isTPC) {
      collegeId = Provider.of<User>(context, listen: false).collegeId;
    } else {
      collegeId = Provider.of<Officer>(context, listen: false).collegeId;
    }
    Provider.of<Drives>(context, listen: false).loadDrives(collegeId).then((_) {
      if (mounted)
        setState(() {
          _loading = false;
          _error = false;
        });
    }).catchError((e) {
      setState(() {
        _loading = false;
        _error = true;
      });
    });
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
          : _error
              ? Error(
                  refresher: _refresher,
                )
              : drives.isEmpty
                  ? EmptyList(
                      message:
                          "You do not have any active placement drives at the moment.",
                      action: RaisedButton(
                        child: Text(
                          "Add New Drive",
                          style: Theme.of(context).textTheme.button,
                        ),
                        onPressed: () {
                          Navigator.of(context)
                              .pushNamed(NewDriveScreen.routeName);
                        },
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _refresher,
                      child: Container(
                        margin: EdgeInsets.all(10),
                        child: ListView.builder(
                          itemBuilder: (ctx, idx) => DriveListItem(
                            drive: drives[idx],
                          ),
                          itemCount: drives.length,
                        ),
                      ),
                    ),
    );
  }
}
