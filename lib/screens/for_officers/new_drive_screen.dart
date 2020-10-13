import 'package:flutter/material.dart';
import 'package:placementshq/providers/colleges.dart';
import 'package:placementshq/providers/companies.dart';
import 'package:provider/provider.dart';

class NewDriveScreen extends StatefulWidget {
  static const routeName = "/new_drive";
  @override
  _NewDriveScreenState createState() => _NewDriveScreenState();
}

class _NewDriveScreenState extends State<NewDriveScreen> {
  final _form = GlobalKey<FormState>();
  List<String> suggestions = [];
  TextEditingController cont = new TextEditingController();
  Map<String, dynamic> values = {
    "companyName": "",
    "companyId": "",
    "minCGPI": "",
    "maxGapYears": "",
    "minKTs": "",
    "externalLink": "",
    "jobDesc": "",
    "location": "",
    "CTC": "",
    "category": "",
    "companyMessage": "",
    "expectedDate": null
  };
  bool _loading = false;
  bool newCompany = true;

  @override
  void initState() {
    _loading = true;
    Provider.of<Companies>(context, listen: false)
        .loadCompanies()
        .then((value) {
      setState(() {
        _loading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final companies = Provider.of<Companies>(context).companies;
    final companiesList = companies.map((c) => c.name).toList();
    Map<String, String> mapCompanyToId = {};
    companies.forEach((c) {
      mapCompanyToId[c.name] = c.id;
    });
    print(companiesList);
    return Scaffold(
      appBar: AppBar(
        title: Text("Add New Placement Drive"),
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              margin: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              child: SingleChildScrollView(
                child: Form(
                  key: _form,
                  autovalidate: true,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: cont,
                        decoration: InputDecoration(
                          hintText: "Company Name",
                        ),
                        onChanged: (val) {
                          setState(() {
                            values["companyName"] = val;
                            values["companyId"] = mapCompanyToId[val];
                            suggestions = [];
                            suggestions = companiesList
                                .where((company) => company
                                    .toLowerCase()
                                    .contains(val.toLowerCase()))
                                .toList();
                          });
                        },
                      ),
                      if (suggestions.length > 0)
                        Container(
                          height: 100,
                          child: ListView.builder(
                            itemCount: suggestions.length,
                            itemBuilder: (ctx, idx) => ListTile(
                              title: Text(
                                suggestions[idx],
                                style: TextStyle(color: Colors.blue[900]),
                              ),
                              onTap: () {
                                cont.text = suggestions[idx];
                                values["companyName"] = suggestions[idx];
                                values["companyId"] =
                                    mapCompanyToId[suggestions[idx]];
                              },
                            ),
                          ),
                        ),
                      RaisedButton(
                        onPressed: () {
                          print(values);
                        },
                        child: Text(
                          "Submit",
                          style: Theme.of(context).textTheme.button,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
