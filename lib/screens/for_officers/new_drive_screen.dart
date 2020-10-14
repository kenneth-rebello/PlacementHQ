import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:placementshq/providers/companies.dart';
import 'package:placementshq/providers/drives.dart';
import 'package:placementshq/providers/officer.dart';
import 'package:placementshq/res/constants.dart';
import 'package:placementshq/widgets/input/input.dart';
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
  DateFormat formatter = new DateFormat("dd-MM-yyyy");
  Map<String, dynamic> values = {
    "companyName": "",
    "companyImageUrl": "",
    "companyId": "",
    "minCGPI": 0.0,
    "maxGapYears": 1,
    "maxKTs": 4,
    "externalLink": "",
    "jobDesc": "",
    "location": "N/A",
    "ctc": 0,
    "category": Constants.driveCategories[0],
    "companyMessage": "",
    "expectedDate": DateTime.now().add(Duration(days: 7)).toIso8601String(),
  };
  bool _loading = false;
  bool newCompany = true;

  chooseDate() {
    showDatePicker(
      context: context,
      initialDate: DateTime.parse(values["expectedDate"]),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    ).then((pickedDate) {
      if (pickedDate != null)
        setState(() {
          values["expectedDate"] = pickedDate.toIso8601String();
        });
    });
  }

  void _confirm() {
    if (_form.currentState.validate()) {
      _form.currentState.save();
      String collegeId = Provider.of<Officer>(context, listen: false).collegeId;
      setState(() {
        _loading = true;
      });
      Company company;
      if (!newCompany) {
        company = Provider.of<Companies>(context).getById(values["companyId"]);
      }
      Provider.of<Drives>(context, listen: false)
          .createNewDrive(values, collegeId, company)
          .then((_) {
        Navigator.of(context).pop();
      });
    }
  }

  @override
  void initState() {
    _loading = true;
    String collegeId = Provider.of<Officer>(context, listen: false).collegeId;
    Provider.of<Companies>(context, listen: false)
        .loadCompaniesForList(collegeId)
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
    Map<String, dynamic> mapCompanyToId = {};
    companies.forEach((c) {
      mapCompanyToId[c.name] = {
        "id": c.id,
        "url": c.imageUrl,
      };
    });

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
                      Input(
                        controller: cont,
                        label: "Company Name",
                        enabled: newCompany,
                        requiredField: true,
                        onChanged: (val) {
                          setState(() {
                            values["companyName"] = val;
                            values["companyId"] = mapCompanyToId[val];
                            if (val.length > 3) {
                              suggestions = [];
                              suggestions = companiesList
                                  .where((company) => company
                                      .toLowerCase()
                                      .contains(val.toLowerCase()))
                                  .toList();
                            }
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
                                    mapCompanyToId[suggestions[idx]]["id"];
                                values["companyImageUrl"] =
                                    mapCompanyToId[suggestions[idx]]["url"];
                                setState(() {
                                  newCompany = false;
                                  suggestions = [];
                                });
                              },
                            ),
                          ),
                        ),
                      if (newCompany)
                        Input(
                          label: "Image URL for company logo",
                          onSaved: (val) {
                            setState(() {
                              values["companyImageUrl"] = val;
                            });
                          },
                        ),
                      Input(
                        initialValue: values["companyMessage"],
                        label: "Message from company",
                        onSaved: (val) {
                          setState(() {
                            values["companyMessage"] = val;
                          });
                        },
                        maxLines: null,
                        minLines: 2,
                      ),
                      Input(
                        label: "Minimum required CGPI",
                        helper: "Defaults to 0.0",
                        type: TextInputType.number,
                        onSaved: (val) {
                          setState(() {
                            values["minCGPI"] = double.parse(val);
                          });
                        },
                      ),
                      Input(
                        label: "Maximum allowed Gap Years",
                        helper: "Defaults to 1",
                        type: TextInputType.number,
                        onSaved: (val) {
                          setState(() {
                            values["maxGapYears"] = int.parse(val);
                          });
                        },
                      ),
                      Input(
                        label: "Maximum allowed live KTs",
                        helper: "Defaults to 4",
                        type: TextInputType.number,
                        onSaved: (val) {
                          setState(() {
                            values["maxKTs"] = int.parse(val);
                          });
                        },
                      ),
                      Input(
                        label: "Registration Link",
                        helper:
                            "Only if company required registration on a seperate website",
                        onSaved: (val) {
                          setState(() {
                            values["externalLink"] = val;
                          });
                        },
                      ),
                      Input(
                        label: "Job Description",
                        onSaved: (val) {
                          setState(() {
                            values["jobDesc"] = val;
                          });
                        },
                      ),
                      Input(
                        label: "Location",
                        helper: "Defaults to N/A",
                        onSaved: (val) {
                          setState(() {
                            values["location"] = val;
                          });
                        },
                      ),
                      Input(
                        label: "CTC",
                        helper: "in Lakhs. Eg: 8.5",
                        type: TextInputType.number,
                        requiredField: true,
                        onChanged: (val) {
                          setState(() {
                            double ctc = double.parse(val);
                            values["ctc"] = ctc;
                            if (ctc > 5.0) values["category"] = "Dream";
                            if (ctc > 10.0) values["category"] = "Super Dream";
                          });
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Category:",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          DropdownButton(
                            value: values["category"],
                            items: Constants.driveCategories
                                .map<DropdownMenuItem>(
                                  (value) => DropdownMenuItem(
                                    value: value,
                                    child: Text(value),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              setState(() {
                                values["category"] = val;
                              });
                            },
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Expected Date:" +
                                formatter.format(
                                    DateTime.parse(values["expectedDate"])),
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          FlatButton(
                            onPressed: chooseDate,
                            child: Text(
                              "Open Calendar",
                              style: TextStyle(
                                color: Color.fromRGBO(0, 0, 100, 1),
                              ),
                            ),
                          ),
                        ],
                      ),
                      RaisedButton(
                        onPressed: _confirm,
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
