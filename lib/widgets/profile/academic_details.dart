import 'package:flutter/material.dart';
import 'package:placementshq/providers/user.dart';
import 'package:placementshq/res/constants.dart';
import 'package:placementshq/models/user_profile.dart';
import 'package:placementshq/providers/colleges.dart';
import 'package:placementshq/widgets/input/input.dart';
import 'package:provider/provider.dart';

class AcademicDetails extends StatefulWidget {
  final Function prevPage;
  final Function nextPage;
  AcademicDetails({this.prevPage, this.nextPage});
  @override
  _AcademicDetailsState createState() => _AcademicDetailsState();
}

class _AcademicDetailsState extends State<AcademicDetails> {
  final _form = GlobalKey<FormState>();
  TextEditingController cont = new TextEditingController();

  final _hNode = FocusNode();
  final _pNode = FocusNode();
  final _dNode = FocusNode();
  final _gapNode = FocusNode();
  final _ktNode = FocusNode();

  Map<String, dynamic> initValues = {
    "collegeName": "",
    "collegeId": "",
    "specialization": Constants.branches[0],
    "hasDiploma": false,
    "diplomaMarks": 0,
    "secMarks": 0,
    "highSecMarks": 0,
    "cgpa": 0,
    "beMarks": 0,
    "numOfGapYears": 0,
    "numOfKTs": 0,
    "verified": false,
  };

  List<String> suggestions = [];
  bool _enabled = true;
  bool _showCollege = true;
  bool _hasDiploma = false;

  @override
  void dispose() {
    _hNode.dispose();
    _dNode.dispose();
    _pNode.dispose();
    _gapNode.dispose();
    _ktNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    Provider.of<Colleges>(context, listen: false).loadColleges();
    Profile profile = Provider.of<User>(context, listen: false).profile;
    if (profile != null) {
      if (profile.collegeName != null && profile.collegeName != "") {
        initValues["collegeName"] = profile.collegeName;
        initValues["collegeId"] = profile.collegeId;
        _showCollege = false;
      }
      if (profile.specialization != null && profile.specialization != "")
        initValues["specialization"] = profile.specialization;
      if (profile.secMarks != null) initValues["secMarks"] = profile.secMarks;
      if (profile.hasDiploma != null) {
        initValues["hasDiploma"] = profile.hasDiploma;
        _hasDiploma = profile.hasDiploma;
      }
      if (profile.diplomaMarks != null)
        initValues["diplomaMarks"] = profile.diplomaMarks;
      if (profile.highSecMarks != null)
        initValues["highSecMarks"] = profile.highSecMarks;
      if (profile.cgpa != null) {
        initValues["cgpa"] = profile.cgpa;
        initValues["beMarks"] = profile.cgpa > 7.0
            ? (7.4 * profile.cgpa) + 12
            : (7.1 * profile.cgpa) + 12;
      }
      if (profile.numOfGapYears != null)
        initValues["numOfGapYears"] = profile.numOfGapYears;
      if (profile.numOfGapYears != null)
        initValues["numOfKTs"] = profile.numOfKTs;
      if (profile.verified != null) initValues["verified"] = profile.verified;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final colleges = Provider.of<Colleges>(context).colleges;
    final List<String> collegesList =
        colleges.length > 0 ? colleges.map((c) => c.name).toList() : [];
    final mapCollegeToId = {};
    colleges.forEach((c) {
      mapCollegeToId[c.name] = c.id;
    });
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: SingleChildScrollView(
        child: Form(
          key: _form,
          autovalidate: true,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              if (_showCollege)
                Input(
                  controller: cont,
                  label: "College Name",
                  enabled: _enabled,
                  onChanged: (val) {
                    setState(() {
                      initValues["collegeName"] = val;
                      initValues["collegeId"] = mapCollegeToId[val];
                      suggestions = [];
                      suggestions = collegesList
                          .where((college) =>
                              college.toLowerCase().contains(val.toLowerCase()))
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
                        setState(() {
                          initValues["collegeName"] = suggestions[idx];
                          initValues["collegeId"] =
                              mapCollegeToId[suggestions[idx]];
                          _enabled = false;
                        });
                      },
                    ),
                  ),
                ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(
                  "Specialization:",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                DropdownButton(
                  value: initValues["specialization"],
                  items: Constants.branches
                      .map<DropdownMenuItem>(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      initValues["specialization"] = val;
                    });
                  },
                ),
              ]),
              Input(
                initialValue: initValues["secMarks"].toStringAsFixed(1),
                type: TextInputType.numberWithOptions(decimal: true),
                label: "Std. Xth %",
                action: TextInputAction.next,
                onSaved: (value) {
                  initValues["secMarks"] = double.parse(value);
                },
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_hNode);
                },
                requiredField: true,
                validator: (val) {
                  if (val != null && val != "") if (double.parse(val) / 10 >
                      10.0) {
                    return "Invalid entry";
                  }
                },
              ),
              Input(
                initialValue: initValues["highSecMarks"].toStringAsFixed(1),
                type: TextInputType.numberWithOptions(decimal: true),
                label: "Std. XIIth %",
                action: TextInputAction.next,
                onSaved: (value) {
                  initValues["highSecMarks"] = double.parse(value);
                },
                node: _hNode,
                onFieldSubmitted: (_) {
                  FocusScope.of(context)
                      .requestFocus(_hasDiploma ? _dNode : _pNode);
                },
                validator: (val) {
                  if (val != null && val != "") if (double.parse(val) / 10 >
                      10.0) {
                    return "Invalid entry";
                  }
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Checkbox(
                      value: _hasDiploma,
                      onChanged: (val) {
                        setState(() {
                          _hasDiploma = val;
                          initValues["hasDiploma"] = val;
                        });
                      }),
                  Input(
                    initialValue: initValues["diplomaMarks"].toStringAsFixed(1),
                    type: TextInputType.numberWithOptions(decimal: true),
                    label: "Diploma %",
                    action: TextInputAction.next,
                    onSaved: (value) {
                      if (value != null && value != "")
                        initValues["diplomaMarks"] = double.parse(value);
                    },
                    fixedWidth: 250,
                    node: _dNode,
                    enabled: _hasDiploma,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_pNode);
                    },
                    validator: (val) {
                      if (val != null && val != "") if (double.parse(val) / 10 >
                          10.0) {
                        return "Invalid entry";
                      }
                    },
                  ),
                ],
              ),
              Input(
                initialValue: initValues["cgpa"].toStringAsFixed(2),
                type: TextInputType.numberWithOptions(decimal: true),
                label: "B.E. CGPA",
                action: TextInputAction.next,
                onSaved: (value) {
                  double val = double.parse(value);
                  initValues["cgpa"] = val;
                  initValues["beMarks"] =
                      val > 7.0 ? (7.4 * val) + 12 : (7.1 * val) + 12;
                },
                node: _pNode,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_gapNode);
                },
                requiredField: true,
                validator: (val) {
                  if (val != null && val != "") if (double.parse(val) / 10 >
                      10.0) {
                    return "Invalid entry";
                  }
                },
              ),
              Input(
                initialValue: initValues["numOfGapYears"].toString(),
                type: TextInputType.number,
                label: "No. of gap years in eductaion.",
                action: TextInputAction.next,
                onSaved: (value) {
                  initValues["numOfGapYears"] = int.parse(value);
                },
                node: _gapNode,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_ktNode);
                },
              ),
              Input(
                initialValue: initValues["numOfKTs"].toString(),
                type: TextInputType.number,
                label: "No. of live KTs.",
                onSaved: (val) {
                  if (val != null && val != "")
                    initValues["numOfKTs"] = int.parse(val);
                },
                node: _ktNode,
              ),
              Container(
                padding: EdgeInsets.all(5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RaisedButton(
                      onPressed: () {
                        widget.prevPage();
                      },
                      color: Colors.grey[400],
                      child: Text("Back"),
                    ),
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
