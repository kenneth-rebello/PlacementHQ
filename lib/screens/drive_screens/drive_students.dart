import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:placementhq/models/arguments.dart';
import 'package:placementhq/models/drive.dart';
import 'package:placementhq/models/registration.dart';
import 'package:placementhq/providers/auth.dart';
import 'package:placementhq/providers/drives.dart';
import 'package:placementhq/providers/officer.dart';
import 'package:placementhq/res/constants.dart';
import 'package:placementhq/screens/drive_screens/drive_report.dart';
import 'package:placementhq/screens/profile_screens/profile_screen.dart';
import 'package:placementhq/widgets/input/no_button.dart';
import 'package:placementhq/widgets/input/yes_button.dart';
import 'package:placementhq/widgets/other/empty_list.dart';
import 'package:placementhq/widgets/other/error.dart';
import 'package:placementhq/widgets/other/list_item.dart';
import 'package:provider/provider.dart';

class DriveStudentsScreen extends StatefulWidget {
  static const routeName = "/drive_students";
  final Arguments args;
  DriveStudentsScreen(this.args);
  @override
  _DriveStudentsScreenState createState() => _DriveStudentsScreenState();
}

class _DriveStudentsScreenState extends State<DriveStudentsScreen> {
  final DateFormat formatter = new DateFormat("dd-MM-yyyy hh:mm");
  bool _loading = false;
  bool _error = false;
  bool _pickable = false;
  bool _selecting = false;
  String sortBy = SortOptions.uidAsc;
  List<bool> picked = List.filled(1000, false);

  @override
  void initState() {
    _loading = true;
    Provider.of<Drives>(context, listen: false)
        .getDriveRegistrations(widget.args.id)
        .then((collegeId) {
      Provider.of<Officer>(context, listen: false).loadStudents(cId: collegeId);
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
    Provider.of<Drives>(context, listen: false)
        .getDriveRegistrations(widget.args.id)
        .then((collegeId) {
      Provider.of<Officer>(context, listen: false).loadStudents(cId: collegeId);
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

  void _showInfo(Drive drive) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(
          "Stats",
          style: Theme.of(context).textTheme.headline3,
          textAlign: TextAlign.left,
        ),
        contentPadding: EdgeInsets.all(5),
        children: [
          ListItem(
            label: "Registered",
            value: drive.registered.toString(),
            shrink: true,
            ratio: 1 / 2,
          ),
          ListItem(
            label: "Selected",
            value: drive.placed.toString(),
            shrink: true,
            ratio: 1 / 2,
          )
        ],
      ),
    );
  }

  Future<void> _confirm(Registration reg) async {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          "Confirm selection of ${reg.candidate} for placement at ${reg.company}?",
          style: Theme.of(context).textTheme.headline3,
        ),
        content: Text(
          "Only click yes if student will receive an offer from the company. This cannot be undone.",
          style: TextStyle(
            fontFamily: "Ubuntu",
            fontWeight: FontWeight.normal,
            color: Colors.red,
          ),
        ),
        contentPadding: EdgeInsets.all(15),
        actions: [
          NoButton(ctx),
          YesButton(ctx),
        ],
      ),
    ).then((res) {
      if (res) {
        setState(() {
          _selecting = true;
        });
        Provider.of<Drives>(context, listen: false)
            .confirmSelection(reg)
            .then((_) {
          setState(() {
            _selecting = false;
          });
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
    final isOfficer = Provider.of<Auth>(context, listen: false).isOfficer;
    final isTPC = Provider.of<Auth>(context, listen: false).isTPC;

    final deviceHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;

    final registrations = Provider.of<Drives>(context).registrations;
    final drive = Provider.of<Drives>(context).getById(widget.args.id);

    if (sortBy == SortOptions.onlySelected)
      registrations.retainWhere((a) => a.selected);
    else if (sortBy == SortOptions.onlyNonSelected)
      registrations.retainWhere((a) => !a.selected);
    if (sortBy == SortOptions.uidAsc)
      registrations.sort((a, b) => a.rollNo.compareTo(b.rollNo));
    else if (sortBy == SortOptions.uidDesc)
      registrations.sort((a, b) => b.rollNo.compareTo(a.rollNo));
    else if (sortBy == SortOptions.nameAsc)
      registrations.sort((a, b) =>
          a.candidate.toLowerCase().compareTo(b.candidate.toLowerCase()));
    else if (sortBy == SortOptions.nameDesc)
      registrations.sort((a, b) =>
          b.candidate.toLowerCase().compareTo(a.candidate.toLowerCase()));
    else if (sortBy == SortOptions.registrationAsc)
      registrations.sort((a, b) => a.registeredOn.compareTo(b.registeredOn));
    else if (sortBy == SortOptions.registrationDesc)
      registrations.sort((a, b) => b.registeredOn.compareTo(a.registeredOn));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.args.title,
          style: Theme.of(context).textTheme.headline1,
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.info_outline),
              onPressed: () => _showInfo(drive)),
          if (isOfficer || isTPC)
            _pickable
                ? IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(
                            "Are you sure?",
                            style: Theme.of(context).textTheme.headline3,
                          ),
                          content: Text(
                            "These students will be removed from this drive and their candidature for the same will be considered rejected.",
                            style: TextStyle(
                              color: Colors.red,
                              fontFamily: "Ubuntu",
                            ),
                          ),
                          contentPadding: EdgeInsets.all(10),
                          actions: [NoButton(ctx), YesButton(ctx)],
                        ),
                      ).then((res) {
                        if (res) {
                          List<String> idsToRemove = [];
                          for (int i = 0; i < registrations.length; i++) {
                            if (picked[i]) {
                              idsToRemove.add(registrations[i].id);
                            }
                          }
                          Provider.of<Drives>(context, listen: false)
                              .removeRegistrations(idsToRemove)
                              .catchError((e) {
                            setState(() {
                              _loading = false;
                              _error = true;
                              _pickable = false;
                              picked = List.filled(1000, false);
                            });
                          });
                        }
                      });
                    },
                    icon: Icon(Icons.delete_forever),
                  )
                : PopupMenuButton(
                    itemBuilder: (ctx) => [
                      PopupMenuItem(
                        child: FlatButton.icon(
                          icon: Icon(Icons.save_alt),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (ctx) => DriveReport(
                                  Arguments(
                                    id: widget.args.id,
                                    title: widget.args.title,
                                  ),
                                ),
                              ),
                            );
                          },
                          label: Text(
                            "Generate Report",
                          ),
                        ),
                      ),
                    ],
                  ),
        ],
      ),
      body: Container(
        margin: EdgeInsets.all(10),
        child: _loading
            ? Center(child: CircularProgressIndicator())
            : _error
                ? Error(
                    refresher: _refresher,
                  )
                : registrations.isEmpty
                    ? EmptyList(
                        message: "No students have registered yet.",
                      )
                    : Stack(
                        children: [
                          Column(
                            children: [
                              Container(
                                height: 0.1 * deviceHeight,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Text("Sort/Filter By:"),
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
                                        if (mounted)
                                          setState(() {
                                            sortBy = val;
                                          });
                                      },
                                    )
                                  ],
                                ),
                              ),
                              RefreshIndicator(
                                onRefresh: _refresher,
                                child: Container(
                                  height: 0.75 * deviceHeight,
                                  child: ListView.builder(
                                    itemBuilder: (ctx, idx) => Card(
                                      color: registrations[idx].selected
                                          ? Colors.green[400]
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
                                                fontFamily: 'Ubuntu',
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
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            fontFamily: 'Merriweather',
                                          ),
                                        ),
                                        subtitle: Text(
                                          "Registered on: " +
                                              formatter.format(
                                                DateTime.parse(
                                                    registrations[idx]
                                                        .registeredOn),
                                              ),
                                          style: TextStyle(
                                            color: registrations[idx].selected
                                                ? Colors.black
                                                : Colors.grey,
                                            fontFamily: 'Ubuntu',
                                            fontSize: 13,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                        onTap: _pickable
                                            ? () {}
                                            : () {
                                                Navigator.of(context).pushNamed(
                                                  ProfileScreen.routeName,
                                                  arguments:
                                                      registrations[idx].userId,
                                                );
                                              },
                                        onLongPress: () {
                                          if (!registrations[idx].selected &&
                                              mounted)
                                            setState(() {
                                              _pickable = true;
                                              picked[idx] = true;
                                            });
                                        },
                                        trailing: _pickable &&
                                                !registrations[idx].selected
                                            ? Checkbox(
                                                value: picked[idx],
                                                onChanged: (val) {
                                                  if (mounted)
                                                    setState(() {
                                                      picked[idx] = val;
                                                      if (!picked.any(
                                                          (element) =>
                                                              element)) {
                                                        _pickable = false;
                                                      }
                                                    });
                                                })
                                            : (isOfficer == true ||
                                                        isTPC == true) &&
                                                    !registrations[idx].selected
                                                ? Container(
                                                    width: 50,
                                                    child: PopupMenuButton(
                                                      itemBuilder: (ctx1) => [
                                                        PopupMenuItem(
                                                            child: FlatButton(
                                                          onPressed: () async {
                                                            await _confirm(
                                                                registrations[
                                                                    idx]);
                                                            Navigator.of(ctx1)
                                                                .pop();
                                                          },
                                                          child: Text(
                                                              "Confirm Selection"),
                                                        )),
                                                      ],
                                                      icon:
                                                          Icon(Icons.more_vert),
                                                    ),
                                                  )
                                                : null,
                                      ),
                                    ),
                                    itemCount: registrations.length,
                                  ),
                                ),
                              ),
                              Text(
                                "Long press to select and delete regestrations",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 11,
                                ),
                              )
                            ],
                          ),
                          if (_selecting)
                            Container(
                              height: double.infinity,
                              width: double.infinity,
                              color: Colors.white54,
                              child: Center(child: CircularProgressIndicator()),
                            ),
                        ],
                      ),
      ),
    );
  }
}
