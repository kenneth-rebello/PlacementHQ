import 'dart:io';
import 'dart:ui';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:placementhq/models/offer.dart';
import 'package:placementhq/providers/auth.dart';
import 'package:placementhq/providers/offers.dart';
import 'package:placementhq/res/constants.dart';
import 'package:placementhq/widgets/input/check_list_item.dart';
import 'package:placementhq/widgets/input/no_button.dart';
import 'package:placementhq/widgets/input/yes_button.dart';
import 'package:placementhq/widgets/other/error.dart';
import 'package:provider/provider.dart';

class OffersHistoryScreen extends StatefulWidget {
  static const routeName = '/offers-history';

  @override
  _OffersHistoryScreenState createState() => _OffersHistoryScreenState();
}

class _OffersHistoryScreenState extends State<OffersHistoryScreen> {
  bool _loading = false;
  bool _error = false;
  bool _generating = false;
  bool _showFilters = false;
  bool _filterByDept = false;
  bool _filterByCompany = false;
  String department = Constants.branches[0];
  String company = "None";
  String sortBy = SortOptions.uidAsc;
  String _year = DateTime.now().month <= 5
      ? DateTime.now().year.toString()
      : (DateTime.now().year + 1).toString();
  final DateFormat formatter = new DateFormat("dd-MM-yyyy");

  @override
  void initState() {
    _loading = true;
    Provider.of<Offers>(context, listen: false).getCollegeOffers().then((_) {
      if (mounted)
        setState(() {
          _loading = false;
          _error = false;
        });
    }).catchError((e) {
      if (mounted)
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
    Provider.of<Offers>(context, listen: false).getCollegeOffers().then((_) {
      if (mounted)
        setState(() {
          _loading = false;
          _error = false;
        });
    }).catchError((e) {
      if (mounted)
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

    if (mounted)
      setState(() {
        _generating = true;
      });

    List<List<dynamic>> toFile = new List();

    List<dynamic> row = [
      "Roll No.",
      "Name",
      "Department",
      "Company",
      "CTC",
      "Category",
      "Selection Date"
    ];
    toFile.add(row);

    offers.forEach((offer) {
      List<dynamic> row = new List();
      row.add(offer.rollNo);
      row.add(offer.candidate);
      row.add(offer.department);
      row.add(offer.companyName);
      row.add(offer.ctc);
      row.add(offer.category);
      row.add(formatter.format(DateTime.parse(offer.selectedOn)));
      toFile.add(row);
    });

    //   await SimplePermissions.requestPermission(Permission. WriteExternalStorage);
    // bool checkPermission=await SimplePermissions.checkPermission(Permission.WriteExternalStorage);
    // if(checkPermission)

    String dir = (await getExternalStorageDirectory()).absolute.path +
        "/Archive_Documents/";
    Directory directory = Directory(dir);
    if (!(await directory.exists())) {
      new Directory(dir).createSync();
    }
    String file = "$dir";
    String filters = "";
    if (_filterByDept) filters += "_${department.split(" ").join()}";
    if (_filterByCompany) filters += "_${company.split(" ").join()}";
    File f = new File(file + _year + "_Offers" + filters + ".csv");
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
            style: TextStyle(fontFamily: 'Ubuntu', color: Colors.indigo[800]),
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
    final List<String> years =
        Provider.of<Offers>(context).archives.map((a) => a.year).toList();
    if (!years.contains(_year)) years.insert(0, _year);
    final offers = Provider.of<Offers>(context).getOffersByYear(_year);
    List<String> companies = ["None"];
    offers.forEach((o) {
      if (!companies.contains(o.companyName)) companies.add(o.companyName);
    });
    if (_filterByDept) offers.retainWhere((a) => a.department == department);
    if (_filterByCompany) offers.retainWhere((b) => b.companyName == company);
    if (sortBy == SortOptions.uidAsc)
      offers.sort((a, b) => a.rollNo.compareTo(b.rollNo));
    else if (sortBy == SortOptions.uidDesc)
      offers.sort((a, b) => b.rollNo.compareTo(a.rollNo));
    if (sortBy == SortOptions.ctcAsc)
      offers.sort((a, b) => a.ctc.compareTo(b.ctc));
    else if (sortBy == SortOptions.ctcDesc)
      offers.sort((a, b) => b.ctc.compareTo(a.ctc));

    final isOfficer = Provider.of<Auth>(context, listen: false).isOfficer;

    final deviceHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Placement History",
          style: Theme.of(context).textTheme.headline1,
        ),
        actions: [
          if (isOfficer)
            IconButton(
              icon: Icon(Icons.save_alt, color: Colors.white),
              onPressed: _generating
                  ? null
                  : () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(
                            "Are you sure?",
                            style: TextStyle(
                              fontFamily: 'Ubuntu',
                              color: Colors.indigo[800],
                            ),
                          ),
                          contentPadding: EdgeInsets.all(20),
                          content: Text(
                            "If you have generated a report before, it will be deleted and replaced with a new report.\n\n All filters will be applied.\n Continue?",
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
                    },
              tooltip: "Export Data",
            ),
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
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              children: [
                _error
                    ? Error()
                    : RefreshIndicator(
                        onRefresh: _refresher,
                        child: Column(
                          children: [
                            Container(
                              height: 0.07 * deviceHeight,
                              margin: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 15),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                    "Select Year: ",
                                    style: TextStyle(
                                      color: Colors.indigo[800],
                                      fontFamily: "Ubuntu",
                                    ),
                                  ),
                                  DropdownButton(
                                    value: _year,
                                    items: years
                                        .map<DropdownMenuItem>(
                                          (value) => DropdownMenuItem(
                                            value: value,
                                            child: Container(
                                              width: 100,
                                              alignment: Alignment.center,
                                              child: Text(value),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (val) {
                                      if (mounted)
                                        setState(() {
                                          _year = val;
                                        });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 0.07 * deviceHeight,
                              margin: EdgeInsets.all(5),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text("Sort By:"),
                                  DropdownButton(
                                    value: sortBy,
                                    items: Constants.offersSortOptions
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
                                ],
                              ),
                            ),
                            Container(
                              height: 0.7 * deviceHeight,
                              margin: EdgeInsets.all(5),
                              child: ListView.builder(
                                itemBuilder: (ctx, idx) => Card(
                                  elevation: 3,
                                  child: ListTile(
                                    leading: Container(
                                      height: 50,
                                      width: 50,
                                      child: Image.network(
                                          offers[idx].companyImageUrl),
                                    ),
                                    title: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        RichText(
                                          text: TextSpan(
                                            children: <TextSpan>[
                                              TextSpan(
                                                text: offers[idx].rollNo + " ",
                                                style: TextStyle(
                                                  color: Colors.indigo[800],
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 17,
                                                ),
                                              ),
                                              TextSpan(
                                                text: offers[idx].candidate,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.normal,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.all(3),
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
                                    subtitle: Text(
                                        "${offers[idx].companyName}:\t ${offers[idx].ctc.toString()} lpa"),
                                    trailing: Icon(
                                      offers[idx].accepted == true
                                          ? Icons.verified
                                          : null,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                                itemCount: offers.length,
                              ),
                            )
                          ],
                        ),
                      ),
                if (_showFilters)
                  Container(
                    height: double.infinity,
                    width: double.infinity,
                    child: SimpleDialog(
                      title: Text(
                        "Filters",
                        style: Theme.of(context).textTheme.headline3,
                      ),
                      contentPadding: EdgeInsets.all(25),
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
                          label: "Filter By Company",
                          value: _filterByCompany,
                          onChanged: (val) {
                            setState(() {
                              _filterByCompany = val;
                            });
                          },
                        ),
                        if (_filterByCompany) Text("Select Company:"),
                        if (_filterByCompany)
                          DropdownButton(
                            value: company,
                            items: companies
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
                                  company = val;
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
                  )
              ],
            ),
    );
  }
}
