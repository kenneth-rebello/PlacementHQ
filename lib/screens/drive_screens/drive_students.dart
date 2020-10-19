import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:placementhq/models/registration.dart';
import 'package:placementhq/providers/auth.dart';
import 'package:placementhq/providers/drives.dart';
import 'package:placementhq/providers/officer.dart';
import 'package:placementhq/res/constants.dart';
import 'package:placementhq/screens/drive_screens/drive_details.dart';
import 'package:placementhq/screens/profile_screens/profile_screen.dart';
import 'package:provider/provider.dart';

class DriveStudentsScreen extends StatefulWidget {
  static const routeName = "/drive_students";
  final DriveArguments args;
  DriveStudentsScreen(this.args);
  @override
  _DriveStudentsScreenState createState() => _DriveStudentsScreenState();
}

class _DriveStudentsScreenState extends State<DriveStudentsScreen> {
  final DateFormat formatter = new DateFormat("dd-MM-yyyy hh:mm");
  bool _loading = false;
  String sortBy = SortOptions.uidAsc;

  @override
  void initState() {
    _loading = true;
    Provider.of<Drives>(context, listen: false)
        .getDriveRegistrations(widget.args.id)
        .then((collegeId) {
      Provider.of<Officer>(context, listen: false).loadStudents(cId: collegeId);
      setState(() {
        _loading = false;
      });
    });
    super.initState();
  }

  Future<void> _confirm(Registration reg) async {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          "Confirm selection of ${reg.candidate} for ${reg.company}?",
          style: Theme.of(context).textTheme.headline3,
        ),
        actions: [
          FlatButton(
            onPressed: () {
              Navigator.of(ctx).pop(false);
            },
            child: Text(
              "No",
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ),
          FlatButton(
            onPressed: () {
              Navigator.of(ctx).pop(true);
            },
            child: Text(
              "Yes",
              style: TextStyle(
                color: Colors.indigo[800],
              ),
            ),
          ),
        ],
      ),
    ).then((res) {
      if (res) {
        Provider.of<Drives>(context, listen: false).confirmSelection(reg);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isOfficer = Provider.of<Auth>(context, listen: false).isOfficer;
    final deviceHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;
    final registrations = Provider.of<Drives>(context).registrations;
    if (sortBy == SortOptions.uidAsc)
      registrations.sort((a, b) => a.rollNo.compareTo(b.rollNo));
    else if (sortBy == SortOptions.uidDesc)
      registrations.sort((a, b) => b.rollNo.compareTo(a.rollNo));
    else if (sortBy == SortOptions.nameAsc)
      registrations.sort((a, b) => a.candidate.compareTo(b.candidate));
    else if (sortBy == SortOptions.nameDesc)
      registrations.sort((a, b) => b.candidate.compareTo(a.candidate));
    else if (sortBy == SortOptions.registrationAsc)
      registrations.sort((a, b) => a.registeredOn.compareTo(b.registeredOn));
    else if (sortBy == SortOptions.registrationDesc)
      registrations.sort((a, b) => b.registeredOn.compareTo(a.registeredOn));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.args.companyName),
      ),
      body: Container(
        margin: EdgeInsets.all(10),
        child: _loading
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Container(
                    height: 0.1 * deviceHeight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text("Sort By:"),
                        DropdownButton(
                          value: sortBy,
                          items: Constants.registrationSortOptions
                              .map<DropdownMenuItem>(
                                (value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(value),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              sortBy = val;
                            });
                          },
                        )
                      ],
                    ),
                  ),
                  Container(
                    height: 0.75 * deviceHeight,
                    child: ListView.builder(
                      itemBuilder: (ctx, idx) => Card(
                        color: registrations[idx].selected
                            ? Colors.green
                            : Colors.white,
                        child: ListTile(
                          leading: Container(
                            width: 80,
                            child: Center(
                              child: Text(
                                registrations[idx].rollNo,
                                style: TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo[900],
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            registrations[idx].candidate,
                            style: TextStyle(
                              color: registrations[idx].selected
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                          subtitle: Text(
                            "Registered on: " +
                                formatter.format(DateTime.parse(
                                    registrations[idx].registeredOn)),
                          ),
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              ProfileScreen.routeName,
                              arguments: registrations[idx].userId,
                            );
                          },
                          trailing: isOfficer == true
                              ? Container(
                                  width: 50,
                                  child: PopupMenuButton(
                                    itemBuilder: (ctx1) => [
                                      PopupMenuItem(
                                          child: FlatButton(
                                        onPressed: () async {
                                          await _confirm(registrations[idx]);
                                          Navigator.of(ctx1).pop();
                                        },
                                        child: Text("Confirm Selection"),
                                      )),
                                    ],
                                    icon: Icon(Icons.more_vert),
                                  ),
                                )
                              : null,
                        ),
                      ),
                      itemCount: registrations.length,
                    ),
                  )
                ],
              ),
      ),
    );
  }
}
