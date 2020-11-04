import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:placementhq/models/arguments.dart';
import 'package:placementhq/models/offer.dart';
import 'package:placementhq/providers/auth.dart';
import 'package:placementhq/providers/drives.dart';
import 'package:placementhq/res/constants.dart';
import 'package:placementhq/widgets/drive_list_item/one_value.dart';
import 'package:placementhq/widgets/input/no_button.dart';
import 'package:placementhq/widgets/input/yes_button.dart';
import 'package:placementhq/widgets/offer_editor/offer_editor.dart';
import 'package:placementhq/widgets/other/error.dart';
import 'package:placementhq/widgets/other/modal.dart';
import 'package:provider/provider.dart';

class DriveOffersScreen extends StatefulWidget {
  static const routeName = '/drive_offers';
  final Arguments args;
  DriveOffersScreen(this.args);
  @override
  _DriveOffersState createState() => _DriveOffersState();
}

class _DriveOffersState extends State<DriveOffersScreen> {
  bool _loading = true;
  bool _error = false;
  bool _editing = false;
  String sortBy = SortOptions.uidAsc;
  Offer _offerToEdit;
  final DateFormat formatter = new DateFormat("dd-MM-yyyy");

  @override
  void initState() {
    _loading = true;
    Provider.of<Drives>(context, listen: false)
        .getDriveOffers(
      widget.args.id,
      widget.args.data1,
    )
        .then((_) {
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
        .getDriveOffers(
      widget.args.id,
      widget.args.data1,
    )
        .then((_) {
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

  void _generateReport(List<Offer> offers) async {
    if (offers.isEmpty) {
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

    List<dynamic> row = [
      "Roll No.",
      "Name",
      "CTC",
      "Department",
      "Status",
    ];
    toFile.add(row);

    offers.forEach((offer) {
      List<dynamic> row = new List();
      row.add(offer.rollNo);
      row.add(offer.candidate);
      row.add(offer.ctc);
      row.add(offer.department);
      row.add(offer.accepted == true ? "Yes" : "No");
      toFile.add(row);
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
    File f = new File(file + "${widget.args.title}_Offers" + ".csv");
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

    final offers = Provider.of<Drives>(context).offers;
    final isOfficer = Provider.of<Auth>(context).isOfficer;

    if (sortBy == SortOptions.uidAsc)
      offers.sort((a, b) => a.rollNo.compareTo(b.rollNo));
    else if (sortBy == SortOptions.uidDesc)
      offers.sort((a, b) => b.rollNo.compareTo(a.rollNo));
    if (sortBy == SortOptions.ctcAsc)
      offers.sort((a, b) => a.ctc.compareTo(b.ctc));
    else if (sortBy == SortOptions.ctcDesc)
      offers.sort((a, b) => b.ctc.compareTo(a.ctc));
    if (sortBy == SortOptions.acceptedFirst)
      offers.sort((a, b) => a.acceptedValue.compareTo(b.acceptedValue));
    else if (sortBy == SortOptions.rejectedFirst)
      offers.sort((a, b) => b.acceptedValue.compareTo(a.acceptedValue));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Offers",
          style: Theme.of(context).textTheme.headline1,
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.save_alt),
              onPressed: () {
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
                    _generateReport(offers);
                  }
                });
              })
        ],
      ),
      body: Container(
        child: _loading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : _error
                ? Error(
                    refresher: _refresher,
                  )
                : Stack(
                    children: [
                      Column(
                        children: [
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text("Sort By: "),
                                DropdownButton(
                                  value: sortBy,
                                  items: Constants.offersSortOptions2
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
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 0.7 * deviceHeight,
                            child: ListView.builder(
                              itemBuilder: (ctx, idx) => Card(
                                elevation: 4,
                                margin: EdgeInsets.all(5),
                                child: ListTile(
                                  tileColor: offers[idx].accepted == null
                                      ? Colors.white
                                      : offers[idx].accepted == true
                                          ? Colors.green[300]
                                          : Colors.red[300],
                                  leading: Container(
                                    height: 80,
                                    width: 80,
                                    alignment: Alignment.center,
                                    child: Text(
                                      offers[idx].rollNo,
                                      style: TextStyle(
                                        fontSize: 21,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.indigo[900],
                                      ),
                                    ),
                                  ),
                                  title: Container(
                                    height: 40,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          fit: FlexFit.loose,
                                          child: Text(
                                            offers[idx].candidate,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily: "Ubuntu",
                                              fontWeight: FontWeight.w800,
                                              fontSize: 17,
                                              color: Colors.indigo[900],
                                            ),
                                          ),
                                        ),
                                        Flexible(
                                          fit: FlexFit.loose,
                                          child: Text(
                                            offers[idx].department,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.indigo[400],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  subtitle: OneValue(
                                    label: "CTC",
                                    value: offers[idx].ctc.toString(),
                                    padding: 1,
                                  ),
                                  trailing: isOfficer
                                      ? PopupMenuButton(
                                          padding: EdgeInsets.all(0.2),
                                          itemBuilder: (ctx) => [
                                            PopupMenuItem(
                                                child: FlatButton.icon(
                                              onPressed: () {
                                                setState(() {
                                                  _editing = true;
                                                  _offerToEdit = offers[idx];
                                                });
                                                Navigator.of(ctx).pop();
                                              },
                                              icon: Icon(Icons.edit),
                                              label: Text("Edit Offer"),
                                            ))
                                          ],
                                        )
                                      : SizedBox(width: 2),
                                ),
                              ),
                              itemCount: offers.length,
                            ),
                          ),
                        ],
                      ),
                      if (_editing && isOfficer)
                        Modal(
                          controller: _editing,
                          close: () {
                            setState(() {
                              _editing = false;
                            });
                          },
                          child: OfferEditor(
                            _offerToEdit,
                            () {
                              setState(() {
                                _editing = false;
                                _offerToEdit = null;
                              });
                            },
                            widget.args.data1,
                          ),
                        ),
                    ],
                  ),
      ),
    );
  }
}
