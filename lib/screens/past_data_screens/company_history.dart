import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:placementhq/providers/companies.dart';
import 'package:placementhq/providers/offers.dart';
import 'package:placementhq/widgets/drive_list_item/two_values.dart';
import 'package:placementhq/widgets/other/empty_list.dart';
import 'package:placementhq/widgets/other/error.dart';
import 'package:provider/provider.dart';

class CompanyHistory extends StatefulWidget {
  final Company company;
  CompanyHistory(this.company);
  @override
  _CompanyHistoryState createState() => _CompanyHistoryState();
}

class _CompanyHistoryState extends State<CompanyHistory> {
  bool _loading = false;
  bool _error = false;
  final DateFormat formatter = new DateFormat("dd-MM-yyyy");

  @override
  void initState() {
    _loading = true;
    Provider.of<Offers>(context, listen: false)
        .getCompanyOffers(widget.company.id)
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
    Provider.of<Offers>(context, listen: false)
        .getCompanyOffers(widget.company.id)
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

  @override
  Widget build(BuildContext context) {
    final offers = Provider.of<Offers>(context).offers;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.company.name,
          style: Theme.of(context).textTheme.headline1,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresher,
        child: Container(
          child: _loading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : _error
                  ? Error(refresher: _refresher)
                  : offers.isEmpty
                      ? EmptyList()
                      : ListView.builder(
                          itemBuilder: (ctx, idx) => Card(
                            elevation: 4,
                            margin: EdgeInsets.all(5),
                            child: ListTile(
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
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    offers[idx].candidate,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: "Ubuntu",
                                      fontWeight: FontWeight.w800,
                                      fontSize: 17,
                                      color: Colors.indigo[900],
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
                              subtitle: TwoValues(
                                label1: "CTC",
                                value1: offers[idx].ctc.toString(),
                                label2: "Date",
                                value2: formatter.format(
                                    DateTime.parse(offers[idx].selectedOn)),
                              ),
                            ),
                          ),
                          itemCount: offers.length,
                        ),
        ),
      ),
    );
  }
}
