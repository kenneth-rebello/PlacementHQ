import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:placementhq/providers/drives.dart';
import 'package:placementhq/providers/user.dart';
import 'package:placementhq/screens/drive_screens/drive_students.dart';
import 'package:placementhq/widgets/other/list_item.dart';
import 'package:provider/provider.dart';

class DriveDetailsScreen extends StatelessWidget {
  final DateFormat formatter = new DateFormat("dd-MM-yyyy");
  static const routeName = "/drive_details";
  @override
  Widget build(BuildContext context) {
    final driveId = ModalRoute.of(context).settings.arguments;
    final drive = Provider.of<Drives>(context).getById(driveId);
    return Scaffold(
      appBar: AppBar(
        title: Text(drive.companyName),
      ),
      body: Container(
        margin: EdgeInsets.all(10),
        child: drive == null
            ? Center(
                child: Column(children: [
                Text("Could not find drive"),
                RaisedButton(onPressed: () {
                  final collegeId =
                      Provider.of<User>(context, listen: false).collegeId;
                  Provider.of<Drives>(context, listen: false)
                      .loadDrives(collegeId);
                })
              ]))
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Card(
                      color: Colors.indigo[100],
                      child: Column(children: [
                        Container(
                          height: 130,
                          width: double.infinity,
                          child: Image.network(drive.companyImageUrl),
                        ),
                        Text(
                          drive.companyName,
                          style: Theme.of(context).textTheme.headline3,
                        ),
                      ]),
                    ),
                    if (drive.companyMessage != null &&
                        drive.companyMessage != "")
                      ListItem(
                        label: "From the office of ${drive.companyName}: ",
                        value: drive.companyMessage,
                        flexibleHeight: true,
                      ),
                    ListItem(
                      label: "Expected By: ",
                      value:
                          formatter.format(DateTime.parse(drive.expectedDate)),
                    ),
                    ListItem(
                      label: "Expected CTC: ",
                      value: drive.ctc.toStringAsFixed(2),
                    ),
                    Container(
                      margin: EdgeInsets.all(10),
                      child: RaisedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) => DriveStudentsScreen(
                                DriveArguments(
                                  id: drive.id,
                                  companyName: drive.companyName,
                                ),
                              ),
                            ),
                          );
                        },
                        child: Text(
                          "See All Candidates",
                          style: Theme.of(context).textTheme.button,
                        ),
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }
}

class DriveArguments {
  final String id;
  final String companyName;

  DriveArguments({this.id, this.companyName});
}
