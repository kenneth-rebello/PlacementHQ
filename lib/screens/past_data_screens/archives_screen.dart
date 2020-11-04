import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:placementhq/providers/auth.dart';
import 'package:placementhq/providers/companies.dart';
import 'package:placementhq/screens/past_data_screens/offers_history.dart';
import 'package:placementhq/widgets/company_item/company_item.dart';
import 'package:placementhq/widgets/input/no_button.dart';
import 'package:placementhq/widgets/input/yes_button.dart';
import 'package:placementhq/widgets/other/empty_list.dart';
import 'package:placementhq/widgets/other/error.dart';
import 'package:provider/provider.dart';

class ArchivesScreen extends StatefulWidget {
  static const routeName = "/archives";
  @override
  _ArchivesScreenState createState() => _ArchivesScreenState();
}

class _ArchivesScreenState extends State<ArchivesScreen> {
  bool _loading = false;
  bool _error = false;

  @override
  void initState() {
    _loading = true;
    String collegeId = Provider.of<Auth>(context, listen: false).collegeId;
    Provider.of<Companies>(context, listen: false)
        .loadCompaniesForList(collegeId)
        .then((_) {
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
    String collegeId = Provider.of<Auth>(context, listen: false).collegeId;
    Provider.of<Companies>(context, listen: false)
        .loadCompaniesForList(collegeId)
        .then((_) {
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

  void _generateReport(List<Company> companies) async {
    if (companies.isEmpty) {
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
      "Company Name",
      "Last Visited",
      "No. of Offers",
      "Highest Package",
      "Lowest Package",
    ];
    toFile.add(row);

    companies.forEach((company) {
      List<dynamic> row = new List();
      row.add(company.name);
      row.add(company.lastVisitedYear);
      row.add(company.numOfStudents);
      row.add(company.highestPackage);
      row.add(company.lowestPackage);
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
    File f = new File(file + "Companies_History" + ".csv");
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
    final collegeName = Provider.of<Companies>(context).collegeName;
    final companies = Provider.of<Companies>(context).companies;
    companies.sort((a, b) => a.name.compareTo(b.name));

    final isOfficer = Provider.of<Auth>(context).isOfficer;

    return _loading
        ? Scaffold(
            appBar: AppBar(
              title: Text(
                "Placement Archives",
                style: Theme.of(context).textTheme.headline1,
              ),
            ),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              title: Text(
                "Placement Archives",
                style: Theme.of(context).textTheme.headline1,
              ),
              actions: [
                if (isOfficer)
                  PopupMenuButton(
                    itemBuilder: (menuCtx) => [
                      PopupMenuItem(
                        child: FlatButton.icon(
                          icon: Icon(Icons.save_alt),
                          label: Text("Export Data"),
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
                                _generateReport(companies);
                              }
                              Navigator.of(menuCtx).pop();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
              ],
              bottom: _error
                  ? null
                  : AppBar(
                      automaticallyImplyLeading: false,
                      backgroundColor: Theme.of(context).accentColor,
                      title: Text(
                        collegeName,
                        style: Theme.of(context).textTheme.headline5,
                      ),
                      centerTitle: true,
                      actions: [
                        IconButton(
                            icon: Icon(Icons.watch_later_outlined),
                            onPressed: () {
                              Navigator.of(context)
                                  .pushNamed(OffersHistoryScreen.routeName);
                            }),
                      ],
                    ),
            ),
            body: RefreshIndicator(
              onRefresh: _refresher,
              child: Container(
                child: _error
                    ? Error()
                    : companies.isEmpty
                        ? EmptyList()
                        : ListView.builder(
                            itemBuilder: (ctx, idx) =>
                                CompanyItem(companies[idx]),
                            itemCount: companies.length,
                          ),
              ),
            ),
          );
  }
}
