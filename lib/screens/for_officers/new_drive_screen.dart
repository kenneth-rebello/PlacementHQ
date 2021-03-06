import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:placementhq/providers/companies.dart';
import 'package:placementhq/providers/drives.dart';
import 'package:placementhq/providers/auth.dart';
import 'package:placementhq/providers/user.dart';
import 'package:placementhq/providers/officer.dart';
import 'package:placementhq/res/constants.dart';
import 'package:placementhq/widgets/input/check_list_item.dart';
import 'package:placementhq/widgets/input/input.dart';
import 'package:placementhq/widgets/input/no_button.dart';
import 'package:placementhq/widgets/input/yes_button.dart';
import 'package:placementhq/widgets/other/error.dart';
import 'package:placementhq/widgets/other/image_error.dart';
import 'package:provider/provider.dart';

class NewDriveScreen extends StatefulWidget {
  static const routeName = "/new_drive";
  @override
  _NewDriveScreenState createState() => _NewDriveScreenState();
}

class _NewDriveScreenState extends State<NewDriveScreen> {
  final _form = GlobalKey<FormState>();
  bool _error = false;
  List<String> suggestions = [];
  TextEditingController cont = new TextEditingController();
  TextEditingController contImage = new TextEditingController();
  DateFormat formatter = new DateFormat("dd-MM-yyyy");
  Map<String, dynamic> values = {
    "batch": "",
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
    },
    "registered": 0,
    "placed": 0,
  };
  bool _loading = false;
  bool newCompany = true;
  File _pickedImage;

  chooseDate(String fieldName) {
    showDatePicker(
      context: context,
      initialDate: DateTime.parse(values["expectedDate"]),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    ).then((pickedDate) {
      if (pickedDate != null && mounted)
        setState(() {
          values[fieldName] = pickedDate.toIso8601String();
        });
    });
  }

  void _confirm() {
    if (_form.currentState.validate()) {
      _form.currentState.save();
      String collegeId;
      final isTPC = Provider.of<Auth>(context, listen: false).isTPC;
      if (isTPC) {
        collegeId = Provider.of<User>(context, listen: false).collegeId;
      } else {
        collegeId = Provider.of<Officer>(context, listen: false).collegeId;
      }

      Company company;
      if (!newCompany) {
        company = Provider.of<Companies>(context, listen: false)
            .getById(values["companyId"]);
      }
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(
            "Are you sure you want to add new drive for ${values["companyName"]}?",
            style: Theme.of(context).textTheme.headline3,
            textAlign: TextAlign.left,
          ),
          actions: [NoButton(ctx), YesButton(ctx)],
        ),
      ).then((res) {
        if (res && mounted) {
          setState(() {
            _loading = true;
          });
          Provider.of<Drives>(context, listen: false)
              .createNewDrive(values, collegeId, company, _pickedImage)
              .then((_) {
            setState(() {
              _loading = false;
            });
            Navigator.of(context).pop();
          }).catchError((e) {
            setState(() {
              _loading = false;
              _error = true;
            });
            showDialog(
              context: context,
              builder: (ctx) => SimpleDialog(
                title: Text(
                  "Error adding drive",
                  style: TextStyle(
                    fontFamily: "Ubuntu",
                    color: Colors.red,
                  ),
                ),
                children: [
                  Text(
                    "${e.message}",
                    style: TextStyle(
                        fontFamily: "Ubuntu", color: Colors.indigo[800]),
                  ),
                  RaisedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: Text("OK"),
                  ),
                ],
                contentPadding: EdgeInsets.all(25),
              ),
            );
          });
        }
      });
    }
  }

  @override
  void initState() {
    _loading = true;
    String collegeId;
    final isTPC = Provider.of<Auth>(context, listen: false).isTPC;
    if (isTPC == true) {
      collegeId = Provider.of<User>(context, listen: false).collegeId;
    } else {
      collegeId = Provider.of<Officer>(context, listen: false).collegeId;
    }

    Provider.of<Companies>(context, listen: false)
        .loadCompaniesForList(collegeId)
        .then((value) {
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
    String collegeId = Provider.of<Officer>(context, listen: false).collegeId;
    Provider.of<Companies>(context, listen: false)
        .loadCompaniesForList(collegeId)
        .then((value) {
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

  void _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(
        source: ImageSource.gallery, imageQuality: 20, maxWidth: 100);
    final pickedImageFile = File(pickedImage.path);
    if (mounted)
      setState(() {
        _pickedImage = pickedImageFile;
      });
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
          : _error
              ? Error(refresher: _refresher)
              : RefreshIndicator(
                  onRefresh: _refresher,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    child: SingleChildScrollView(
                      child: Form(
                        key: _form,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
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
                                if (mounted)
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
                              Card(
                                elevation: 2,
                                margin: EdgeInsets.only(bottom: 15),
                                child: Container(
                                  height: 100,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.orange[600],
                                      width: 1.5,
                                    ),
                                  ),
                                  child: ListView.builder(
                                    itemCount: suggestions.length,
                                    itemBuilder: (ctx, idx) => ListTile(
                                      tileColor: Colors.indigo[400],
                                      title: Text(
                                        suggestions[idx],
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: "Ubuntu",
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      onTap: () {
                                        cont.text = suggestions[idx];
                                        contImage.text =
                                            mapCompanyToId[suggestions[idx]]
                                                ["url"];
                                        if (mounted)
                                          setState(() {
                                            values["companyName"] =
                                                suggestions[idx];
                                            values["companyId"] =
                                                mapCompanyToId[suggestions[idx]]
                                                    ["id"];
                                            values["companyImageUrl"] =
                                                mapCompanyToId[suggestions[idx]]
                                                    ["url"];
                                            newCompany = false;
                                            suggestions = [];
                                          });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            (values["companyImageUrl"] == null ||
                                    values["companyImageUrl"] == "")
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      RaisedButton.icon(
                                        onPressed: () {
                                          _pickImage();
                                        },
                                        icon: Icon(
                                          Icons.camera_alt_rounded,
                                          color: Colors.white,
                                        ),
                                        label: Text(
                                          "Add Image",
                                          style: Theme.of(context)
                                              .textTheme
                                              .button,
                                        ),
                                      ),
                                      CircleAvatar(
                                        radius: 50,
                                        backgroundColor: Colors.indigo[200],
                                        backgroundImage: _pickedImage == null
                                            ? null
                                            : FileImage(_pickedImage),
                                      ),
                                    ],
                                  )
                                : Center(
                                    child: Image.network(
                                      values["companyImageUrl"],
                                      errorBuilder: (ctx, e, s) => ImageError(),
                                    ),
                                  ),
                            Input(
                              initialValue: values["batch"],
                              label: "Batch",
                              type: TextInputType.number,
                              onSaved: (val) {
                                if (mounted)
                                  setState(() {
                                    values["batch"] = val;
                                  });
                              },
                              helper:
                                  "For batch graduating in 2021, enter 2021.",
                              requiredField: true,
                              validator: (val) {
                                if (val.length < 4) {
                                  return "Invalid";
                                }
                                return null;
                              },
                            ),
                            Input(
                              initialValue: values["companyMessage"],
                              label: "Message from company",
                              onSaved: (val) {
                                if (mounted)
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
                                if (val != null && val != "" && mounted)
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
                                if (val != null && val != "" && mounted)
                                  setState(() {
                                    values["minHighSecMarks"] =
                                        double.parse(val);
                                  });
                              },
                            ),
                            Input(
                              label: "Minimum required Diploma %",
                              helper: "Defaults to 0.0",
                              type: TextInputType.number,
                              onSaved: (val) {
                                if (val != null && val != "" && mounted)
                                  setState(() {
                                    values["minDiplomaMarks"] =
                                        double.parse(val);
                                  });
                              },
                            ),
                            Input(
                              label: "Minimum required BE %",
                              helper: "Default adjusts to minimum CGPA",
                              type: TextInputType.number,
                              onSaved: (val) {
                                if (val != null && val != "" && mounted)
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
                                if (val != null && val != "" && mounted)
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
                                if (val != null && val != "" && mounted)
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
                                if (val != null && val != "" && mounted)
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
                                if (mounted)
                                  setState(() {
                                    values["externalLink"] = val;
                                  });
                              },
                            ),
                            Input(
                              label: "Job Description",
                              onSaved: (val) {
                                if (mounted)
                                  setState(() {
                                    values["jobDesc"] = val;
                                  });
                              },
                            ),
                            Input(
                              label: "Location",
                              onSaved: (val) {
                                if (mounted)
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
                                if (val != "" && val != null && mounted)
                                  setState(() {
                                    double ctc = double.parse(val);
                                    values["ctc"] = ctc;
                                    if (ctc <= 5.0)
                                      values["category"] = "Normal";
                                    if (ctc > 5.0) values["category"] = "Dream";
                                    if (ctc > 10.0)
                                      values["category"] = "Super Dream";
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
                                    if (mounted)
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
                                      formatter.format(DateTime.parse(
                                          values["expectedDate"])),
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
                                        formatter.format(DateTime.parse(
                                            values["regDeadline"])),
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
                                if (mounted)
                                  setState(() {
                                    values["requirements"]["middleName"] = val;
                                  });
                              },
                              label: "Middle Name",
                            ),
                            CheckListItem(
                              value: values["requirements"]["gender"],
                              onChanged: (val) {
                                if (mounted)
                                  setState(() {
                                    values["requirements"]["gender"] = val;
                                  });
                              },
                              label: "Gender",
                            ),
                            CheckListItem(
                              value: values["requirements"]["age"],
                              onChanged: (val) {
                                if (mounted)
                                  setState(() {
                                    values["requirements"]["age"] = val;
                                  });
                              },
                              label: "Age",
                            ),
                            CheckListItem(
                              value: values["requirements"]["nationality"],
                              onChanged: (val) {
                                if (mounted)
                                  setState(() {
                                    values["requirements"]["nationality"] = val;
                                  });
                              },
                              label: "Nationality",
                            ),
                            CheckListItem(
                              value: values["requirements"]["address"],
                              onChanged: (val) {
                                if (mounted)
                                  setState(() {
                                    values["requirements"]["address"] = val;
                                  });
                              },
                              label: "Address",
                            ),
                            CheckListItem(
                              value: values["requirements"]["city"],
                              onChanged: (val) {
                                if (mounted)
                                  setState(() {
                                    values["requirements"]["city"] = val;
                                  });
                              },
                              label: "City",
                            ),
                            CheckListItem(
                              value: values["requirements"]["state"],
                              onChanged: (val) {
                                if (mounted)
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
                ),
    );
  }
}
