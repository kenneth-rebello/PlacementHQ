import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:placementhq/models/user_profile.dart';
import 'package:placementhq/providers/user.dart';
import 'package:placementhq/widgets/input/input.dart';
import 'package:provider/provider.dart';

class PersonalDetails extends StatefulWidget {
  final Function nextPage;
  PersonalDetails({this.nextPage});
  @override
  _PersonalDetailsState createState() => _PersonalDetailsState();
}

class _PersonalDetailsState extends State<PersonalDetails> {
  final _form = GlobalKey<FormState>();
  DateFormat formatter = new DateFormat("dd-MM-yyyy");
  Map<String, dynamic> initValues = {
    "firstName": "",
    "middleName": null,
    "lastName": "",
    "dateOfBirth": null,
    "gender": "Prefer Not To Say",
    "nationality": "",
    "imageUrl": "",
    "verified": false,
  };
  String dateToShow = "";

  final _mNode = FocusNode();
  final _lNode = FocusNode();
  final _nNode = FocusNode();
  final _iNode = FocusNode();

  @override
  void dispose() {
    _mNode.dispose();
    _lNode.dispose();
    _nNode.dispose();
    _iNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    Profile profile = Provider.of<User>(context, listen: false).profile;
    if (profile != null) {
      if (profile.firstName != null)
        initValues["firstName"] = profile.firstName;
      if (profile.lastName != null) initValues["lastName"] = profile.lastName;
      if (profile.middleName != null)
        initValues["middleName"] = profile.middleName;
      if (profile.dateOfBirth != null)
        initValues["dateOfBirth"] = profile.dateOfBirth;
      if (profile.dateOfBirth != null) {
        dateToShow = formatter.format(DateTime.parse(profile.dateOfBirth));
      }

      if (profile.gender != null) initValues["gender"] = profile.gender;
      if (profile.imageUrl != null) initValues["imageUrl"] = profile.imageUrl;
      if (profile.nationality != null)
        initValues["nationality"] = profile.nationality;
      if (profile.verified != null) initValues["verified"] = profile.verified;
    }
    super.initState();
  }

  chooseDate() {
    showDatePicker(
      context: context,
      initialDate: initValues["dateOfBirth"] == null
          ? DateTime.now()
          : DateTime.parse(initValues["dateOfBirth"]),
      firstDate: DateTime(1980),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate != null)
        setState(() {
          initValues["dateOfBirth"] = pickedDate.toIso8601String();
          dateToShow = formatter.format(pickedDate);
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Column(
            children: [
              Input(
                initialValue: initValues["firstName"],
                label: "First Name",
                action: TextInputAction.next,
                onSaved: (value) {
                  initValues["firstName"] = value;
                },
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_mNode);
                },
                requiredField: true,
              ),
              Input(
                initialValue: initValues["middleName"],
                label: "Middle Name",
                action: TextInputAction.next,
                onSaved: (value) {
                  initValues["middleName"] = value;
                },
                node: _mNode,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_lNode);
                },
              ),
              Input(
                initialValue: initValues["lastName"],
                label: "Last Name",
                action: TextInputAction.next,
                onSaved: (value) {
                  initValues["lastName"] = value;
                },
                node: _lNode,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_iNode);
                },
                requiredField: true,
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(
                  "Gender:",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                DropdownButton(
                  value: initValues["gender"],
                  items: ["Male", "Female", "Prefer Not To Say", "Other"]
                      .map<DropdownMenuItem>(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      initValues["gender"] = val;
                    });
                  },
                ),
              ]),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Date of Birth:" + (dateToShow == "" ? "" : dateToShow),
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  FlatButton(
                    onPressed: chooseDate,
                    child: Text("Open Calendar"),
                  ),
                ],
              ),
              Row(children: [
                Container(
                  width: 200,
                  child: Input(
                    initialValue: initValues["imageUrl"],
                    label: "Online Image URL",
                    helper:
                        "Tip: Copy and paste image URL of your LinkedIn profile picture",
                    helperLines: 2,
                    action: TextInputAction.next,
                    onChanged: (value) {
                      setState(() {
                        initValues["imageUrl"] = value;
                      });
                    },
                    node: _iNode,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_nNode);
                    },
                  ),
                ),
                Container(
                  height: 100,
                  width: 100,
                  child: Image.network(
                    initValues["imageUrl"],
                    errorBuilder: (_, _2, _3) => Center(
                      child: Icon(Icons.error_outline, color: Colors.red),
                    ),
                  ),
                )
              ]),
              Input(
                initialValue: initValues["nationality"],
                label: "Nationality",
                helper: "Eg: Indian",
                onSaved: (value) {
                  initValues["nationality"] = value;
                },
                node: _nNode,
              ),
              Container(
                padding: EdgeInsets.all(5),
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  RaisedButton(
                    onPressed: () {
                      if (_form.currentState.validate()) {
                        _form.currentState.save();
                        widget.nextPage(initValues);
                      }
                    },
                    child: Text("Submit"),
                    textColor: Colors.white,
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
