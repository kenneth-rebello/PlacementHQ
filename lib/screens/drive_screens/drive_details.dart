import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:placementhq/models/arguments.dart';
import 'package:placementhq/providers/auth.dart';
import 'package:placementhq/providers/drives.dart';
import 'package:placementhq/providers/user.dart';
import 'package:placementhq/screens/chat/chat.dart';
import 'package:placementhq/screens/drive_screens/drive_notices_screen.dart';
import 'package:placementhq/screens/drive_screens/drive_offers.dart';
import 'package:placementhq/screens/drive_screens/drive_students.dart';
import 'package:placementhq/widgets/input/no_button.dart';
import 'package:placementhq/widgets/input/yes_button.dart';
import 'package:placementhq/widgets/other/error.dart';
import 'package:placementhq/widgets/other/image_error.dart';
import 'package:placementhq/widgets/other/list_item.dart';
import 'package:provider/provider.dart';

class DriveDetailsScreen extends StatefulWidget {
  static const routeName = "/drive_details";

  @override
  _DriveDetailsScreenState createState() => _DriveDetailsScreenState();
}

class _DriveDetailsScreenState extends State<DriveDetailsScreen> {
  final DateFormat formatter = new DateFormat("dd-MM-yyyy");
  bool _loading = false;
  bool _error = false;

  _closeDrive(String id, String batch) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          "Are you sure?",
          style: Theme.of(context).textTheme.headline3,
          textAlign: TextAlign.left,
        ),
        contentPadding: EdgeInsets.all(15),
        content: Container(
          height: 200,
          child: Column(
            children: [
              Text("Closing the drive will..."),
              Text("- Delete this drive."),
              Text("- Delete all registrations for this drive."),
              Text("- All offers will be retained for archives."),
              Text(
                  "- Offers that have not been accepted by candidates will be considered rejected."),
            ],
          ),
        ),
        actions: [NoButton(ctx), YesButton(ctx)],
      ),
    ).then((res) {
      if (res) {
        setState(() {
          _loading = true;
        });

        Provider.of<Drives>(context, listen: false)
            .closeDrive(id, batch)
            .then((_) {
          Navigator.of(context).pop();
        }).catchError((e) {
          setState(() {
            _loading = false;
            _error = true;
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final driveId = ModalRoute.of(context).settings.arguments;
    final drive = Provider.of<Drives>(context).getById(driveId);
    final isOfficer = Provider.of<Auth>(context, listen: false).isOfficer;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          drive == null ? "Error" : drive.companyName,
          style: Theme.of(context).textTheme.headline1,
        ),
      ),
      body: Container(
        margin: EdgeInsets.all(10),
        child: _loading
            ? Center(child: CircularProgressIndicator())
            : _error
                ? Error()
                : drive == null
                    ? Center(
                        child: Column(children: [
                        Text("Could not find drive"),
                        RaisedButton(onPressed: () {
                          final collegeId =
                              Provider.of<User>(context, listen: false)
                                  .collegeId;
                          Provider.of<Drives>(context, listen: false)
                              .loadDrives(collegeId)
                              .catchError((e) {
                            setState(() {
                              _loading = false;
                              _error = true;
                            });
                          });
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
                                  child: Image.network(
                                    drive.companyImageUrl,
                                    errorBuilder: (ctx, _, _a) => ImageError(),
                                  ),
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
                                label:
                                    "From the office of ${drive.companyName}: ",
                                value: drive.companyMessage,
                                flexibleHeight: true,
                              ),
                            ListItem(
                              label: "Expected By: ",
                              value: formatter
                                  .format(DateTime.parse(drive.expectedDate)),
                            ),
                            ListItem(
                              label: "Expected CTC: ",
                              value: drive.ctc.toStringAsFixed(2),
                            ),
                            Container(
                              margin: EdgeInsets.all(4),
                              width: double.infinity,
                              child: RaisedButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (ctx) => DriveStudentsScreen(
                                        Arguments(
                                          id: drive.id,
                                          title: drive.companyName,
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
                            ),
                            Container(
                              margin: EdgeInsets.all(4),
                              width: double.infinity,
                              child: RaisedButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (ctx) =>
                                          DriveNoticesScreen(drive.id),
                                    ),
                                  );
                                },
                                child: Text(
                                  "See All Notices",
                                  style: Theme.of(context).textTheme.button,
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.all(4),
                              width: double.infinity,
                              child: RaisedButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (ctx) => DriveOffersScreen(
                                        Arguments(
                                          id: drive.id,
                                          title: drive.companyName,
                                          data1: drive.batch,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  "See All Offers",
                                  style: Theme.of(context).textTheme.button,
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.all(4),
                              width: double.infinity,
                              child: RaisedButton(
                                onPressed: () {
                                  Navigator.of(context).pushNamed(
                                    ChatScreen.routeName,
                                    arguments: Arguments(
                                      id: drive.id,
                                      title: drive.companyName,
                                    ),
                                  );
                                },
                                child: Text(
                                  "Q&A",
                                  style: Theme.of(context).textTheme.button,
                                ),
                              ),
                            ),
                            if (isOfficer)
                              Container(
                                margin: EdgeInsets.all(4),
                                width: double.infinity,
                                child: RaisedButton(
                                  color: Colors.red,
                                  onPressed: () {
                                    _closeDrive(drive.id, drive.batch);
                                  },
                                  child: Text(
                                    "Close Drive",
                                    style: Theme.of(context).textTheme.button,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
      ),
    );
  }
}
