import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:placementhq/models/user_profile.dart';
import 'package:placementhq/providers/offers.dart';
import 'package:placementhq/providers/officer.dart';
import 'package:placementhq/res/constants.dart';
import 'package:placementhq/screens/profile_screens/profile_screen.dart';
import 'package:placementhq/widgets/input/check_list_item.dart';
import 'package:placementhq/widgets/input/no_button.dart';
import 'package:placementhq/widgets/input/yes_button.dart';
import 'package:placementhq/widgets/other/error.dart';
import 'package:placementhq/widgets/other/modal.dart';
import 'package:provider/provider.dart';

class StudentsScreen extends StatefulWidget {
  static const routeName = "/students";
  @override
  _StudentsScreenState createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  bool _loading = false;
  bool _error = false;
  bool _generating = false;
  bool _showFilters = false;

  bool _filterByDept = false;
  bool _filterByPlaced = false;

  String sortBy = SortOptions.uidAsc;
  String department = Constants.branches[0];
  String category = Constants.driveCategories[0];

  @override
  void initState() {
    _loading = true;
    Provider.of<Officer>(context, listen: false).loadStudents().then((_) {
      Provider.of<Offers>(context, listen: false).getCollegeOffers().then((_) {
        setState(() {
          _loading = false;
          _error = false;
        });
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
    Provider.of<Officer>(context, listen: false).loadStudents().then((_) {
      Provider.of<Offers>(context, listen: false).getCollegeOffers().then((_) {
        setState(() {
          _loading = false;
          _error = false;
        });
      });
    }).catchError((e) {
      setState(() {
        _loading = false;
        _error = true;
      });
    });
  }

  void _generateReport(List<Profile> students) async {
    if (students.isEmpty) {
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
    List<List<dynamic>> toFile = new List();
    toFile.add([
      "Roll No.",
      "Full Name",
      "Placed in",
    ]);
    students.forEach((student) {
      List<dynamic> row = [];
      row.add(student.rollNo);
      row.add(student.fullNameWMid);
      row.add(student.placedCategory == "None"
          ? "Unplaced"
          : student.placedCategory);
      var offers = Provider.of<Offers>(context, listen: false)
          .getOffersByStudent(student.id);
      offers.forEach((o) {
        row.add(o.companyName);
      });
      toFile.add(row);
    });

    String dir = (await getExternalStorageDirectory()).absolute.path +
        "/Statistics_Documents/";
    Directory directory = Directory(dir);
    if (!(await directory.exists())) {
      directory.createSync();
    }
    String file = "$dir";
    final year = DateTime.now().month <= 5
        ? DateTime.now().year.toString()
        : (DateTime.now().year + 1).toString();
    String info = "";
    if (_filterByDept) info += "_" + department.split(" ").join();
    if (_filterByPlaced) info += "_" + category;
    File f = new File(file + year + "_Statistics" + info + ".csv");
    if (f.existsSync()) {
      f.deleteSync();
    }

// convert rows to String and write as csv file

    String csv = const ListToCsvConverter().convert(toFile);
    File newFile = await f.writeAsString(csv);

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
      );
  }

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;

    List<String> categories = [...Constants.driveCategories];
    categories.add("None");
    final students = Provider.of<Officer>(context).students;
    if (_filterByDept)
      students.retainWhere((a) => a.specialization == department);
    if (_filterByPlaced)
      students.retainWhere((a) => a.placedCategory == category);
    if (sortBy == SortOptions.uidAsc)
      students.sort((a, b) => a.rollNo.compareTo(b.rollNo));
    else if (sortBy == SortOptions.uidDesc)
      students.sort((a, b) => b.rollNo.compareTo(a.rollNo));
    else if (sortBy == SortOptions.nameAsc)
      students.sort((a, b) =>
          a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()));
    else if (sortBy == SortOptions.nameDesc)
      students.sort((a, b) =>
          b.fullName.toLowerCase().compareTo(a.fullName.toLowerCase()));
    else if (sortBy == SortOptions.placedFirst)
      students.sort((a, b) {
        final res = a.placedValue.compareTo(b.placedValue);
        if (res == 0) {
          return a.rollNo.compareTo(b.rollNo);
        }
        return res;
      });
    else if (sortBy == SortOptions.unPlacedFirst)
      students.sort((a, b) {
        final res = b.placedValue.compareTo(a.placedValue);
        if (res == 0) {
          return a.rollNo.compareTo(b.rollNo);
        }
        return res;
      });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Students List",
          style: Theme.of(context).textTheme.headline1,
        ),
        actions: [
          IconButton(
              icon: Icon(
                Icons.filter_alt,
                color: Colors.white,
              ),
              onPressed: () {
                if (mounted)
                  setState(() {
                    _showFilters = !_showFilters;
                  });
              }),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _error
              ? Error(
                  refresher: _refresher,
                )
              : Stack(
                  children: [
                    Container(
                      margin: EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Container(
                            height: 0.07 * deviceHeight,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text("Sort By:"),
                                DropdownButton(
                                  value: sortBy,
                                  items: Constants.studentSortOptions
                                      .map<DropdownMenuItem>(
                                        (value) => DropdownMenuItem(
                                          value: value,
                                          child: Text(value),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (val) {
                                    if (mounted)
                                      setState(() {
                                        sortBy = val;
                                      });
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.save_alt,
                                      color: Theme.of(context).accentColor),
                                  onPressed: _generating
                                      ? null
                                      : () {
                                          showDialog(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: Text(
                                                "Are you sure?",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline3,
                                                textAlign: TextAlign.left,
                                              ),
                                              contentPadding:
                                                  EdgeInsets.all(20),
                                              content: Text(
                                                "If you have generated a report before, it will be deleted and replaced with a new report.\nAll selected filters will be applied\n Continue?",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontFamily: 'Ubuntu',
                                                ),
                                              ),
                                              actions: [
                                                NoButton(ctx),
                                                YesButton(ctx)
                                              ],
                                            ),
                                          ).then((res) {
                                            if (res) {
                                              _generateReport(students);
                                            }
                                          });
                                        },
                                  tooltip: "Export Data",
                                )
                              ],
                            ),
                          ),
                          RefreshIndicator(
                            onRefresh: _refresher,
                            child: Container(
                              height: 0.78 * deviceHeight,
                              child: students.isEmpty
                                  ? Center(
                                      child: Text(
                                        "No students to show",
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline3,
                                      ),
                                    )
                                  : ListView.builder(
                                      itemBuilder: (ctx, idx) => Card(
                                        child: ListTile(
                                          leading: Container(
                                            width: 80,
                                            child: Center(
                                              child: Text(
                                                students[idx].rollNo,
                                                style: TextStyle(
                                                  fontSize: 21,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.indigo[900],
                                                ),
                                              ),
                                            ),
                                          ),
                                          title: Text(
                                            students[idx].isTPC
                                                ? students[idx].fullName +
                                                    "\u2605"
                                                : students[idx].fullName,
                                            style: TextStyle(
                                              color: students[idx].isTPC
                                                  ? Colors.orange[800]
                                                  : Colors.indigo[800],
                                            ),
                                          ),
                                          subtitle: Text(
                                              students[idx].specialization),
                                          trailing:
                                              students[idx].placedCategory !=
                                                      "None"
                                                  ? Icon(
                                                      Icons.verified,
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                    )
                                                  : SizedBox(
                                                      width: 10,
                                                    ),
                                          onTap: () {
                                            Navigator.of(context).pushNamed(
                                              ProfileScreen.routeName,
                                              arguments: students[idx].id,
                                            );
                                          },
                                        ),
                                      ),
                                      itemCount: students.length,
                                    ),
                            ),
                          )
                        ],
                      ),
                    ),
                    if (_showFilters)
                      Modal(
                        controller: _showFilters,
                        close: () {
                          setState(() {
                            _showFilters = false;
                          });
                        },
                        child: SimpleDialog(
                          contentPadding: EdgeInsets.all(20),
                          title: Text(
                            "Filters",
                            style: Theme.of(context).textTheme.headline3,
                          ),
                          children: [
                            CheckListItem(
                              label: "Filter By Dept.",
                              value: _filterByDept,
                              onChanged: (val) {
                                setState(() {
                                  _filterByDept = val;
                                });
                              },
                            ),
                            if (_filterByDept) Text("Select Department:"),
                            if (_filterByDept)
                              DropdownButton(
                                value: department,
                                items: Constants.branches
                                    .map<DropdownMenuItem>(
                                      (value) => DropdownMenuItem(
                                        value: value,
                                        child: Text(value),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) {
                                  if (mounted)
                                    setState(() {
                                      department = val;
                                    });
                                },
                              ),
                            CheckListItem(
                              label: "Filter By Placement Status.",
                              value: _filterByPlaced,
                              onChanged: (val) {
                                setState(() {
                                  _filterByPlaced = val;
                                });
                              },
                            ),
                            if (_filterByPlaced) Text("Select Category:"),
                            if (_filterByPlaced)
                              DropdownButton(
                                value: category,
                                items: categories
                                    .map<DropdownMenuItem>(
                                      (value) => DropdownMenuItem(
                                        value: value,
                                        child: Text(value),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) {
                                  if (mounted)
                                    setState(() {
                                      category = val;
                                    });
                                },
                              ),
                            RaisedButton(
                              onPressed: () {
                                setState(() {
                                  _showFilters = !_showFilters;
                                });
                              },
                              child: Text(
                                "Done",
                                style: Theme.of(context).textTheme.button,
                              ),
                            )
                          ],
                        ),
                      ),
                    if (_generating)
                      Container(
                        color: Colors.white54,
                        height: double.infinity,
                        width: double.infinity,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                  ],
                ),
    );
  }
}
