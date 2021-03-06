import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:placementhq/models/arguments.dart';
import 'package:placementhq/providers/drives.dart';
import 'package:placementhq/providers/officer.dart';
import 'package:placementhq/widgets/input/check_list_item.dart';
import 'package:placementhq/widgets/input/no_button.dart';
import 'package:placementhq/widgets/input/yes_button.dart';
import 'package:provider/provider.dart';

class DriveReport extends StatefulWidget {
  final Arguments args;
  DriveReport(this.args);
  @override
  _DriveReportState createState() => _DriveReportState();
}

class _DriveReportState extends State<DriveReport> {
  bool _generating = false;
  Map<String, bool> columns = {
    "firstName": false,
    "middleName": false,
    "lastName": false,
    "fullName": true,
    "uid": true,
    "email": true,
    "phone": true,
    "dob": false,
    "gender": false,
    "address": false,
    "secMarks": true,
    "highSecMarks": true,
    "diplomaMarks": true,
    "cgpa": true,
    "beMarks": true,
    "numOfKTs": false,
    "numOfGapYears": false,
    "regDate": false,
  };
  final DateFormat formatter = new DateFormat("dd-MM-yyyy hh:mm");

  void generateReport() async {
    final registrations =
        Provider.of<Drives>(context, listen: false).registrations;
    if (registrations.isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => SimpleDialog(
          title: Text(
            "Error",
            style: TextStyle(
              fontFamily: "Ubuntu",
              color: Colors.red,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          contentPadding: EdgeInsets.all(25),
          children: [
            Text("Nothing to export"),
            RaisedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text(
                "OK",
                style: Theme.of(context).textTheme.button,
              ),
            )
          ],
        ),
      );
      return;
    }
    if (mounted)
      setState(() {
        _generating = true;
      });

    List<List<dynamic>> toFile = new List();
    List<dynamic> row = new List();
    if (columns["firstName"]) row.add("First Name");
    if (columns["middleName"]) row.add("Middle Name");
    if (columns["lastName"]) row.add("Last Name");
    if (columns["fullName"]) row.add("Full Name");
    if (columns["uid"]) row.add("UID");
    if (columns["email"]) row.add("Email");
    if (columns["phone"]) row.add("Contact Number");
    if (columns["dob"]) row.add("DoB");
    if (columns["gender"]) row.add("Gender");
    if (columns["address"]) row.add("Address");
    if (columns["secMarks"]) row.add("Xth %");
    if (columns["highSecMarks"]) row.add("XIIth %");
    if (columns["diplomaMarks"]) row.add("Diploma %");
    if (columns["beMarks"]) row.add("BE %");
    if (columns["cgpa"]) row.add("CGPA");
    if (columns["numOfKTs"]) row.add("Live KTs");
    if (columns["numOfGapYears"]) row.add("No. of Gap Years");
    if (columns["regDate"]) row.add("Registered On");
    toFile.add(row);
    registrations.forEach((reg) {
      final profile = Provider.of<Officer>(context, listen: false)
          .getProfileById(reg.userId);
      if (profile != null) {
        List<dynamic> row = new List();
        if (columns["firstName"]) row.add(profile.firstName);
        if (columns["middleName"]) row.add(profile.middleName);
        if (columns["lastName"]) row.add(profile.lastName);
        if (columns["fullName"]) row.add(profile.fullName);
        if (columns["uid"]) row.add(reg.rollNo);
        if (columns["email"]) row.add(profile.email);
        if (columns["phone"]) row.add(profile.phone);
        if (columns["dob"])
          row.add(formatter.format(DateTime.parse(profile.dateOfBirth)));
        if (columns["gender"]) row.add(profile.gender);
        if (columns["address"]) row.add(profile.fullAddress);
        if (columns["secMarks"]) row.add(profile.secMarks);
        if (columns["highSecMarks"]) row.add(profile.highSecMarks);
        if (columns["diplomaMarks"]) {
          if (profile.hasDiploma) {
            row.add(profile.diplomaMarks);
          } else {
            row.add("N/A");
          }
        }
        if (columns["beMarks"]) row.add(profile.beMarks);
        if (columns["cgpa"]) row.add(profile.cgpa);
        if (columns["numOfKTs"]) row.add(profile.numOfKTs);
        if (columns["numOfGapYears"]) row.add(profile.numOfGapYears);
        if (columns["regDate"]) row.add(reg.registeredOn);
        toFile.add(row);
      }
    });

    //   await SimplePermissions.requestPermission(Permission. WriteExternalStorage);
    // bool checkPermission=await SimplePermissions.checkPermission(Permission.WriteExternalStorage);
    // if(checkPermission)

    String dir = (await getExternalStorageDirectory()).absolute.path +
        "/Drive_Documents/";
    Directory directory = Directory(dir);
    if (!(await directory.exists())) {
      new Directory(dir).createSync();
    }
    String file = "$dir";
    File f = new File(file + widget.args.title + "_Registrations" + ".csv");
    if (f.existsSync()) {
      f.deleteSync();
    }

// convert rows to String and write as csv file

    String csv = const ListToCsvConverter().convert(toFile);
    File newFile = await f.writeAsString(csv);
    if (mounted)
      setState(() {
        _generating = false;
      });
    if (newFile != null)
      showDialog(
        context: context,
        builder: (ctx) => SimpleDialog(
          title: Text(
            "CSV file created",
            style: Theme.of(context).textTheme.headline3,
            textAlign: TextAlign.left,
          ),
          children: [
            Text(
              "Find your file at...",
              style: TextStyle(fontFamily: 'Ubuntu'),
            ),
            Text(
              newFile.path,
              style: TextStyle(
                fontFamily: 'Ubuntu',
                color: Colors.orange[700],
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.normal,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            Container(
              margin: EdgeInsets.all(15),
              padding: EdgeInsets.all(8),
              color: Colors.red,
              child: Text(
                "Convert file to Excel format (.xls or .xlsx) if you must make any changes to the file.\n Editing the generated file will make it corrupt!!\n Your application (eg. Google Sheets) will allow you to easily save the file as xls.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Ubuntu",
                  fontSize: 13,
                ),
              ),
            ),
            FlatButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text("OK", style: TextStyle(fontFamily: "Ubuntu")),
            )
          ],
          contentPadding: EdgeInsets.all(15),
        ),
      ).then((_) {
        Navigator.of(context).pop();
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
        "Generate Report Sheet",
        style: Theme.of(context).textTheme.headline1,
      )),
      body: Container(
        margin: EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Pick columns to include in report",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline3,
              ),
              CheckListItem(
                label: "First Name",
                value: columns["firstName"],
                onChanged: (val) {
                  if (mounted)
                    setState(() {
                      columns["firstName"] = val;
                    });
                },
              ),
              CheckListItem(
                label: "Middle Name",
                value: columns["middleName"],
                onChanged: (val) {
                  if (mounted)
                    setState(() {
                      columns["middleName"] = val;
                    });
                },
              ),
              CheckListItem(
                label: "Last Name",
                value: columns["lastName"],
                onChanged: (val) {
                  if (mounted)
                    setState(() {
                      columns["lastName"] = val;
                    });
                },
              ),
              CheckListItem(
                label: "Full Name",
                value: columns["fullName"],
                onChanged: (val) {
                  if (mounted)
                    setState(() {
                      columns["fullName"] = val;
                    });
                },
              ),
              CheckListItem(
                label: "UID",
                value: columns["uid"],
                onChanged: (val) {
                  if (mounted)
                    setState(() {
                      columns["uid"] = val;
                    });
                },
              ),
              CheckListItem(
                label: "Email",
                value: columns["email"],
                onChanged: (val) {
                  if (mounted)
                    setState(() {
                      columns["email"] = val;
                    });
                },
              ),
              CheckListItem(
                label: "Contact Number",
                value: columns["phone"],
                onChanged: (val) {
                  if (mounted)
                    setState(() {
                      columns["phone"] = val;
                    });
                },
              ),
              CheckListItem(
                label: "Date Of Birth",
                value: columns["dob"],
                onChanged: (val) {
                  if (mounted)
                    setState(() {
                      columns["dob"] = val;
                    });
                },
              ),
              CheckListItem(
                label: "Gender",
                value: columns["gender"],
                onChanged: (val) {
                  if (mounted)
                    setState(() {
                      columns["gender"] = val;
                    });
                },
              ),
              CheckListItem(
                label: "Address",
                value: columns["address"],
                onChanged: (val) {
                  if (mounted)
                    setState(() {
                      columns["address"] = val;
                    });
                },
              ),
              CheckListItem(
                label: "Std X Marks",
                value: columns["secMarks"],
                onChanged: (val) {
                  if (mounted)
                    setState(() {
                      columns["secMarks"] = val;
                    });
                },
              ),
              CheckListItem(
                label: "Std XII Marks",
                value: columns["highSecMarks"],
                onChanged: (val) {
                  if (mounted)
                    setState(() {
                      columns["highSecMarks"] = val;
                    });
                },
              ),
              CheckListItem(
                label: "Diploma Marks",
                value: columns["diplomaMarks"],
                onChanged: (val) {
                  if (mounted)
                    setState(() {
                      columns["diplomaMarks"] = val;
                    });
                },
              ),
              CheckListItem(
                label: "BE CGPA",
                value: columns["cgpa"],
                onChanged: (val) {
                  if (mounted)
                    setState(() {
                      columns["cgpa"] = val;
                    });
                },
              ),
              CheckListItem(
                label: "BE %",
                value: columns["beMarks"],
                onChanged: (val) {
                  if (mounted)
                    setState(() {
                      columns["beMarks"] = val;
                    });
                },
              ),
              CheckListItem(
                label: "Number of KTs",
                value: columns["numOfKTs"],
                onChanged: (val) {
                  if (mounted)
                    setState(() {
                      columns["numOfKTs"] = val;
                    });
                },
              ),
              CheckListItem(
                label: "Number of gap years",
                value: columns["numOfGapYears"],
                onChanged: (val) {
                  if (mounted)
                    setState(() {
                      columns["numOfGapYears"] = val;
                    });
                },
              ),
              CheckListItem(
                label: "Registration Date",
                value: columns["regDate"],
                onChanged: (val) {
                  if (mounted)
                    setState(() {
                      columns["regDate"] = val;
                    });
                },
              ),
              RaisedButton(
                onPressed: _generating
                    ? null
                    : () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(
                              "Are you sure?",
                              style: Theme.of(context).textTheme.headline3,
                              textAlign: TextAlign.left,
                            ),
                            contentPadding: EdgeInsets.all(20),
                            content: Text(
                              "If you have generated a report before, it will be deleted and replaced with a new report. Continue?",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Ubuntu',
                              ),
                            ),
                            actions: [NoButton(ctx), YesButton(ctx)],
                          ),
                        ).then((res) {
                          if (res) {
                            generateReport();
                          }
                        });
                      },
                disabledColor: Colors.grey,
                child: Text(
                  "Export Data",
                  style: Theme.of(context).textTheme.button,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
