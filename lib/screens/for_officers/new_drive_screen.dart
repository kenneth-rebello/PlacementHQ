import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:placementhq/providers/companies.dart';
import 'package:placementhq/providers/drives.dart';
import 'package:placementhq/providers/officer.dart';
import 'package:placementhq/res/constants.dart';
import 'package:placementhq/widgets/input/check_list_item.dart';
import 'package:placementhq/widgets/input/input.dart';
import 'package:placementhq/widgets/input/no_button.dart';
import 'package:placementhq/widgets/input/yes_button.dart';
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
  TextEditingController contImage = new TextEditingController();
  DateFormat formatter = new DateFormat("dd-MM-yyyy");
  Map<String, dynamic> values = {
    "companyName": "",
    "companyImageUrl": "",
    "companyId": "",
    "minSecMarks": 0,
    "minHighSecMarks": 0,
    "minDiplomaMarks": 0,
    "minBEMarks": 0.0,
    "minCGPA": 0.0,
    "maxGapYears": 1,
    "maxKTs": 4,
    "externalLink": "",
    "jobDesc": "",
    "location": "N/A",
    "ctc": 0,
    "category": Constants.driveCategories[0],
    "companyMessage": "",
    "expectedDate": DateTime.now().add(Duration(days: 7)).toIso8601String(),
    "createdOn": DateTime.now().toIso8601String(),
    "regDeadline": DateTime.now().add(Duration(days: 3)).toIso8601String(),
    "requirements": {
      "middleName": false,
      "age": false,
      "gender": false,
      "nationality": false,
      "address": false,
      "city": false,
      "state": false,
    }
  };
  bool _loading = false;
  bool newCompany = true;

  chooseDate(String fieldName) {
    showDatePicker(
      context: context,
      initialDate: DateTime.parse(values["expectedDate"]),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    ).then((pickedDate) {
      if (pickedDate != null)
        setState(() {
          values[fieldName] = pickedDate.toIso8601String();
        });
    });
  }

  void _confirm() {
    if (_form.currentState.validate()) {
      _form.currentState.save();
      print(values);
      String collegeId = Provider.of<Officer>(context, listen: false).collegeId;

      Company company;
      if (!newCompany) {
        company = Provider.of<Companies>(context, listen: false)
            .getById(values["companyId"]);
      }
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(
              "Are you sure you want to add new drive for ${values["companyName"]}?"),
          actions: [NoButton(ctx), YesButton(ctx)],
        ),
      ).then((res) {
        if (res) {
          setState(() {
            _loading = true;
          });
          Provider.of<Drives>(context, listen: false)
              .createNewDrive(values, collegeId, company)
              .then((_) {
            setState(() {
              _loading = false;
            });
            Navigator.of(context).pop();
          });
        }
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
        title: Text(
          "Add New Placement Drive",
          style: Theme.of(context).textTheme.headline1,
        ),
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
                        helper:
                            "If company name appears below, kinldy select it to avoid creating unnecessary redundant data",
                        helperLines: 2,
                        enabled: newCompany,
                        requiredField: true,
                        onChanged: (val) {
                          setState(() {
                            values["companyName"] = val;
                            values["companyId"] = "";
                            values["companyImageUrl"] = "";
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
                                contImage.text =
                                    mapCompanyToId[suggestions[idx]]["url"];
                                setState(() {
                                  values["companyName"] = suggestions[idx];
                                  values["companyId"] =
                                      mapCompanyToId[suggestions[idx]]["id"];
                                  values["companyImageUrl"] =
                                      mapCompanyToId[suggestions[idx]]["url"];
                                  newCompany = false;
                                  suggestions = [];
                                });
                              },
                            ),
                          ),
                        ),
                      Input(
                        label: "Image URL for company logo",
                        controller: contImage,
                        onSaved: (val) {
                          setState(() {
                            values["companyImageUrl"] = val;
                          });
                        },
                        enabled: newCompany,
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
                        label: "Minimum required Xth%",
                        helper: "Defaults to 0.0",
                        type: TextInputType.number,
                        onSaved: (val) {
                          if (val != null && val != "")
                            setState(() {
                              values["minSecMarks"] = double.parse(val);
                            });
                        },
                      ),
                      Input(
                        label: "Minimum required XIIth %",
                        helper: "Defaults to 0.0",
                        type: TextInputType.number,
                        onSaved: (val) {
                          if (val != null && val != "")
                            setState(() {
                              values["minHighSecMarks"] = double.parse(val);
                            });
                        },
                      ),
                      Input(
                        label: "Minimum required Diploma %",
                        helper: "Defaults to 0.0",
                        type: TextInputType.number,
                        onSaved: (val) {
                          if (val != null && val != "")
                            setState(() {
                              values["minDiplomaMarks"] = double.parse(val);
                            });
                        },
                      ),
                      Input(
                        label: "Minimum required BE %",
                        helper: "Default adjusts to minimum CGPA",
                        type: TextInputType.number,
                        onSaved: (val) {
                          if (val != null && val != "")
                            setState(() {
                              values["minBEMarks"] = double.parse(val);
                            });
                        },
                      ),
                      Input(
                        label: "Minimum required CGPA",
                        helper: "Defaults to 0.0",
                        type: TextInputType.number,
                        onSaved: (val) {
                          if (val != null && val != "")
                            setState(() {
                              double cgpa = double.parse(val);
                              values["minCGPA"] = cgpa;
                              double multi = 7.1;
                              if (cgpa < 7.0) {
                                multi = 7.1;
                              } else
                                multi = 7.4;
                              values["minBEMarks"] = (multi * cgpa) + 12;
                            });
                        },
                      ),
                      Input(
                        label: "Maximum allowed Gap Years",
                        helper: "Defaults to 1",
                        type: TextInputType.number,
                        onSaved: (val) {
                          if (val != null && val != "")
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
                          if (val != null && val != "")
                            setState(() {
                              values["maxKTs"] = int.parse(val);
                            });
                        },
                      ),
                      Input(
                        label: "Registration Link",
                        helper:
                            "Only if company requires registration on a seperate website",
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
                            if (ctc <= 5.0) values["category"] = "Normal";
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
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                              fontWeight: FontWeight.normal,
                            ),
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
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          FlatButton(
                            onPressed: () => chooseDate("expectedDate"),
                            child: Text(
                              "Open Calendar",
                              style: TextStyle(
                                color: Color.fromRGBO(0, 0, 100, 1),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 200,
                            child: Text(
                              "Registration Deadline:" +
                                  formatter.format(
                                      DateTime.parse(values["regDeadline"])),
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.red,
                                fontWeight: FontWeight.normal,
                              ),
                              softWrap: true,
                            ),
                          ),
                          FlatButton(
                            onPressed: () => chooseDate("regDeadline"),
                            child: Text(
                              "Open Calendar",
                              style: TextStyle(
                                color: Color.fromRGBO(0, 0, 100, 1),
                              ),
                            ),
                          ),
                        ],
                      ),
                      ListTile(
                        title: Text(
                          "Mandatory Fields",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headline3,
                        ),
                        subtitle: Text(
                            "Profile fields students must have to register for this drive"),
                      ),
                      CheckListItem(
                        value: values["requirements"]["middleName"],
                        onChanged: (val) {
                          setState(() {
                            values["requirements"]["middleName"] = val;
                          });
                        },
                        label: "Middle Name",
                      ),
                      CheckListItem(
                        value: values["requirements"]["gender"],
                        onChanged: (val) {
                          setState(() {
                            values["requirements"]["gender"] = val;
                          });
                        },
                        label: "Gender",
                      ),
                      CheckListItem(
                        value: values["requirements"]["age"],
                        onChanged: (val) {
                          setState(() {
                            values["requirements"]["age"] = val;
                          });
                        },
                        label: "Age",
                      ),
                      CheckListItem(
                        value: values["requirements"]["nationality"],
                        onChanged: (val) {
                          setState(() {
                            values["requirements"]["nationality"] = val;
                          });
                        },
                        label: "Nationality",
                      ),
                      CheckListItem(
                        value: values["requirements"]["address"],
                        onChanged: (val) {
                          setState(() {
                            values["requirements"]["address"] = val;
                          });
                        },
                        label: "Address",
                      ),
                      CheckListItem(
                        value: values["requirements"]["city"],
                        onChanged: (val) {
                          setState(() {
                            values["requirements"]["city"] = val;
                          });
                        },
                        label: "City",
                      ),
                      CheckListItem(
                        value: values["requirements"]["state"],
                        onChanged: (val) {
                          setState(() {
                            values["requirements"]["state"] = val;
                          });
                        },
                        label: "State",
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
