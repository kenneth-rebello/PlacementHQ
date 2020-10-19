import 'package:flutter/material.dart';
import 'package:placementhq/providers/drives.dart';
import 'package:placementhq/providers/user.dart';
import 'package:placementhq/widgets/drive_list_item/drive_list_item.dart';
import 'package:provider/provider.dart';

class DrivesScreen extends StatefulWidget {
  static const routeName = "/dirves";

  @override
  _DrivesScreenState createState() => _DrivesScreenState();
}

class _DrivesScreenState extends State<DrivesScreen> {
  bool _loading = false;

  @override
  void initState() {
    _loading = true;
    String collegeId = Provider.of<User>(context, listen: false).collegeId;
    Provider.of<Drives>(context, listen: false).loadDrives(collegeId).then((_) {
      setState(() {
        _loading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<User>(context).profile;
    final registered = profile.hasRegistered;
    var drives = Provider.of<Drives>(context).drives;
    drives = drives.where((drive) => !registered.contains(drive.id)).toList();
    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
            child: Text(
          "Latest Placement Drives",
          style: Theme.of(context).textTheme.headline1,
        )),
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : drives.length <= 0
              ? Center(
                  child: Text(
                    "You do not have any active placement drives at the moment.",
                    textAlign: TextAlign.center,
                  ),
                )
              : Container(
                  margin: EdgeInsets.all(10),
                  child: ListView.builder(
                    itemBuilder: (ctx, idx) => DriveListItem(
                      profile: profile,
                      drive: drives[idx],
                    ),
                    itemCount: drives.length,
                  ),
                ),
    );
  }
}
