import 'package:flutter/material.dart';
import 'package:placementshq/providers/user.dart';
import 'package:placementshq/res/constants.dart';
import 'package:placementshq/providers/colleges.dart';
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
  List<String> suggestions = [];
  TextEditingController cont = new TextEditingController();
  Map<String, dynamic> initValues = {
    "collegeName": "",
    "specialization": Constants.branches[0],
    "secMarks": 0,
    "highSecMarks": 0,
    "cgpi": 0,
    "beMarks": 0,
    "numOfGapYears": 0,
    "numOfKTs": 0,
    "verified": false,
  };

  final _hNode = FocusNode();
  final _pNode = FocusNode();
  final _gapNode = FocusNode();
  final _ktNode = FocusNode();

  @override
  void dispose() {
    _hNode.dispose();
    _pNode.dispose();
    _gapNode.dispose();
    _ktNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    Profile profile = Provider.of<User>(context, listen: false).profile;
    if (profile != null) {
      if (profile.collegeName != null && profile.collegeName != "")
        initValues["collegeName"] = profile.collegeName;
      if (profile.specialization != null && profile.specialization != "")
        initValues["specialization"] = profile.specialization;
      if (profile.secMarks != null) initValues["secMarks"] = profile.secMarks;
      if (profile.highSecMarks != null)
        initValues["highSecMarks"] = profile.highSecMarks;
      if (profile.cgpi != null) {
        initValues["cgpi"] = profile.cgpi;
        initValues["beMarks"] = profile.cgpi > 7.0
            ? (7.4 * profile.cgpi) + 12
            : (7.1 * profile.cgpi) + 12;
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

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: SingleChildScrollView(
        child: Form(
          key: _form,
          autovalidate: true,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextFormField(
                controller: cont,
                decoration: InputDecoration(
                  hintText: "College Name",
                ),
                onChanged: (val) {
                  setState(() {
                    initValues["collegeName"] = val;
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
                        initValues["collegeName"] = suggestions[idx];
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
              TextFormField(
                initialValue: initValues["secMarks"].toStringAsFixed(1),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: "Std. Xth marks"),
                textInputAction: TextInputAction.next,
                onSaved: (value) {
                  initValues["secMarks"] = double.parse(value);
                },
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_hNode);
                },
                validator: (val) {
                  if (val.length < 2) {
                    return "**Required**";
                  }
                  if (double.parse(val) / 10 > 10.0) {
                    return "Invalid entry";
                  }
                },
              ),
              TextFormField(
                initialValue: initValues["highSecMarks"].toStringAsFixed(1),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: "Std. XIIth marks"),
                textInputAction: TextInputAction.next,
                onSaved: (value) {
                  initValues["highSecMarks"] = double.parse(value);
                },
                focusNode: _hNode,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_pNode);
                },
                validator: (val) {
                  if (val.length < 2) {
                    return "**Required**";
                  }
                  if (double.parse(val) / 10 > 10.0) {
                    return "Invalid entry";
                  }
                },
              ),
              TextFormField(
                initialValue: initValues["cgpi"].toStringAsFixed(2),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: "B.E. CGPI"),
                textInputAction: TextInputAction.next,
                onSaved: (value) {
                  double val = double.parse(value);
                  initValues["cgpi"] = val;
                  initValues["beMarks"] =
                      val > 7.0 ? (7.4 * val) + 12 : (7.1 * val) + 12;
                },
                focusNode: _pNode,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_gapNode);
                },
                validator: (val) {
                  if (val.length < 2) {
                    return "**Required**";
                  }
                  if (double.parse(val) / 10 > 10.0) {
                    return "Invalid entry";
                  }
                },
              ),
              TextFormField(
                initialValue: initValues["numOfGapYears"].toString(),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: "No. of gap years in eductaion."),
                textInputAction: TextInputAction.next,
                onSaved: (value) {
                  initValues["numOfGapYears"] = int.parse(value);
                },
                focusNode: _gapNode,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_ktNode);
                },
                validator: (val) {
                  if (val.isEmpty) {
                    return "**Required**";
                  }
                },
              ),
              TextFormField(
                initialValue: initValues["numOfKTs"].toString(),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "No. of live KTs."),
                onSaved: (value) {
                  initValues["numOfKTs"] = int.parse(value);
                },
                focusNode: _ktNode,
                validator: (val) {
                  if (val.isEmpty) {
                    return "**Required**";
                  }
                },
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
