import 'package:flutter/material.dart';
import 'package:placementhq/providers/auth.dart';
import 'package:placementhq/providers/companies.dart';
import 'package:placementhq/widgets/company_item/company_item.dart';
import 'package:provider/provider.dart';

class ArchivesScreen extends StatefulWidget {
  static const routeName = "/archives";
  @override
  _ArchivesScreenState createState() => _ArchivesScreenState();
}

class _ArchivesScreenState extends State<ArchivesScreen> {
  bool _loading;

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
        });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final collegeName = Provider.of<Companies>(context).collegeName;
    final companies = Provider.of<Companies>(context).companies;
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
              bottom: AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: Theme.of(context).accentColor,
                title: Text(
                  collegeName,
                  style: Theme.of(context).textTheme.headline5,
                ),
                centerTitle: true,
              ),
            ),
            body: Container(
              child: companies.isEmpty
                  ? Center(
                      child: Text("There is no data to show"),
                    )
                  : ListView.builder(
                      itemBuilder: (ctx, idx) => CompanyItem(companies[idx]),
                      itemCount: companies.length,
                    ),
            ),
          );
  }
}
