import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:placementhq/models/user_profile.dart';
import 'package:placementhq/providers/user.dart';
import 'package:placementhq/widgets/input/input.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // at beginning of file

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
    "resumeUrl": "",
    "verified": false,
  };
  String dateToShow = "";
  File _pickedImage;

  final _mNode = FocusNode();
  final _lNode = FocusNode();
  final _nNode = FocusNode();
  final _rNode = FocusNode();
  final _iNode = FocusNode();

  @override
  void dispose() {
    _mNode.dispose();
    _lNode.dispose();
    _nNode.dispose();
    _rNode.dispose();
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
      if (profile.resumeUrl != null)
        initValues["resumeUrl"] = profile.resumeUrl;
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

  void _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(
        source: ImageSource.gallery, imageQuality: 40, maxWidth: 360);
    final pickedImageFile = File(pickedImage.path);
    setState(() {
      _pickedImage = pickedImageFile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Column(
            children: [
              Text(
                "Personal Details",
                style: Theme.of(context).textTheme.headline3,
                textAlign: TextAlign.center,
              ),
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
                  FocusScope.of(context).requestFocus(_rNode);
                },
                requiredField: true,
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(
                  "Gender:",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.normal,
                  ),
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
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  FlatButton(
                    onPressed: chooseDate,
                    child: Text("Open Calendar"),
                  ),
                ],
              ),
              Input(
                initialValue: initValues["resumeUrl"],
                label: "Online Resume URL",
                helper: "Tip: Use Google drive shareable link",
                action: TextInputAction.next,
                onChanged: (value) {
                  setState(() {
                    initValues["resumeUrl"] = value;
                  });
                },
                node: _rNode,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_iNode);
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                      style: Theme.of(context).textTheme.button,
                    ),
                  ),
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.indigo[200],
                    backgroundImage:
                        _pickedImage == null ? null : FileImage(_pickedImage),
                  ),
                ],
              ),
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
                        widget.nextPage(initValues, image: _pickedImage);
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
