import 'package:flutter/material.dart';
import 'package:placementhq/providers/officer.dart';
import 'package:placementhq/res/constants.dart';
import 'package:placementhq/screens/profile_screens/profile_screen.dart';
import 'package:provider/provider.dart';

class StudentsScreen extends StatefulWidget {
  static const routeName = "/students";
  @override
  _StudentsScreenState createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  bool _loading = false;
  bool _filterable = false;
  String sortBy = SortOptions.uidAsc;
  String filterBy = Constants.branches[0];
  @override
  void initState() {
    _loading = true;
    Provider.of<Officer>(context, listen: false).loadStudents().then((_) {
      _loading = false;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;

    final students = Provider.of<Officer>(context).students;
    if (_filterable) students.retainWhere((a) => a.specialization == filterBy);
    if (sortBy == SortOptions.uidAsc)
      students.sort((a, b) => a.rollNo.compareTo(b.rollNo));
    else if (sortBy == SortOptions.uidDesc)
      students.sort((a, b) => b.rollNo.compareTo(a.rollNo));
    else if (sortBy == SortOptions.nameAsc)
      students.sort((a, b) => a.fullName.compareTo(b.fullName));
    else if (sortBy == SortOptions.nameDesc)
      students.sort((a, b) => b.fullName.compareTo(a.fullName));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Students List",
          style: Theme.of(context).textTheme.headline1,
        ),
        actions: [
          PopupMenuButton(
            icon: Icon(Icons.more_vert),
            itemBuilder: (ctx) => [
              PopupMenuItem(
                  child: FlatButton(
                child: Text(_filterable ? "Disable Filter" : "Enable Filter"),
                onPressed: () {
                  setState(() {
                    _filterable = !_filterable;
                    Navigator.of(ctx).pop();
                  });
                },
              ))
            ],
          )
        ],
      ),
      body: Container(
        margin: EdgeInsets.all(10),
        child: _loading
            ? Center(child: CircularProgressIndicator())
            : Column(
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
                            setState(() {
                              sortBy = val;
                            });
                          },
                        )
                      ],
                    ),
                  ),
                  if (_filterable)
                    Container(
                      height: 0.07 * deviceHeight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text("Select Department:"),
                          DropdownButton(
                            value: filterBy,
                            items: Constants.branches
                                .map<DropdownMenuItem>(
                                  (value) => DropdownMenuItem(
                                    value: value,
                                    child: Text(value),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              setState(() {
                                filterBy = val;
                              });
                            },
                          )
                        ],
                      ),
                    ),
                  Container(
                    height:
                        _filterable ? 0.7 * deviceHeight : 0.75 * deviceHeight,
                    child: ListView.builder(
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
                            students[idx].fullName,
                            style: TextStyle(
                                // color: students[idx].selected
                                //     ? Colors.white
                                //     : Colors.black,
                                ),
                          ),
                          subtitle: Text(students[idx].specialization),
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
                  )
                ],
              ),
      ),
    );
  }
}
