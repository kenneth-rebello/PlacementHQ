import 'package:flutter/material.dart';
import 'package:placementshq/providers/auth.dart';
import 'package:placementshq/providers/colleges.dart';
import 'package:placementshq/providers/officer.dart';
import 'package:provider/provider.dart';

class TPOApplication extends StatefulWidget {
  static const routeName = "/application";

  @override
  _TPOApplicationState createState() => _TPOApplicationState();
}

class _TPOApplicationState extends State<TPOApplication> {
  final _form = GlobalKey<FormState>();
  TextEditingController cont = new TextEditingController();
  String email;
  List<String> suggestions = [];
  bool _loading = false;
  bool newCollege = true;

  Map<String, dynamic> values = {
    "collegeName": "",
    "collegeId": "",
    "fullName": "",
    "designation": "",
    "phone": "",
    "email": "",
    "verified": false
  };

  confirmDialog() {
    _form.currentState.save();
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text("Submit Application?"),
              content: Text(
                  "College Name:\t${values["collegeName"]}\nFull Name:\t${values["fullName"]}\nDesignation:\t${values["designation"]}\nPhone Number:\t${values["phone"].toString()}\nEmail:\t${values["email"]}"),
              actions: [
                FlatButton(
                  onPressed: () {
                    Navigator.of(ctx).pop(false);
                  },
                  child: Text(
                    "No",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                FlatButton(
                  onPressed: () {
                    Navigator.of(ctx).pop(true);
                  },
                  child: Text(
                    "Yes",
                  ),
                ),
              ],
            )).then((res) {
      if (res) {
        if (_form.currentState.validate()) {
          Provider.of<Officer>(context, listen: false)
              .applyForAccount(values, newCollege)
              .then((_) {
            Provider.of<Auth>(context, listen: false).logout();
            Navigator.of(context).pop();
          });
        }
      }
    });
  }

  @override
  void initState() {
    _loading = true;
    email = Provider.of<Auth>(context, listen: false).userEmail;
    values["email"] = email;
    Provider.of<Colleges>(context, listen: false).loadColleges().then((value) {
      setState(() {
        _loading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final colleges = Provider.of<Colleges>(context).colleges;
    final List<String> collegesList =
        colleges.length > 0 ? colleges.map((c) => c.name).toList() : [];
    Map<String, String> mapCollegeToId = {};
    colleges.forEach((c) {
      mapCollegeToId[c.name] = c.id;
    });
    return Scaffold(
      appBar: AppBar(
        title: Text("Apply for TPO account"),
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
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
                          filled: true,
                          helperMaxLines: 6,
                          helperText:
                              "\u2022Suggested to use full name displayed on official college website.\n\u2022Avoid making acronyms.\nIf your college name shows in the space below this, please click it.",
                        ),
                        readOnly: !newCollege,
                        onChanged: (val) {
                          setState(() {
                            values["collegeName"] = val;
                            values["collegeId"] = mapCollegeToId[val];
                            suggestions = [];
                            suggestions = collegesList
                                .where((college) => college
                                    .toLowerCase()
                                    .contains(val.toLowerCase()))
                                .toList();
                          });
                          print(values);
                        },
                        validator: (val) {
                          if (val.length < 2) {
                            return "***Required field***";
                          }
                        },
                      ),
                      if (suggestions.length > 0)
                        Container(
                          height: 100,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Theme.of(context).primaryColor),
                          ),
                          child: ListView.builder(
                            itemCount: suggestions.length,
                            itemBuilder: (ctx, idx) => ListTile(
                              title: Text(
                                suggestions[idx],
                                style: TextStyle(color: Colors.blue[900]),
                              ),
                              onTap: () {
                                cont.text = suggestions[idx];
                                values["collegeName"] = suggestions[idx];
                                values["collegeId"] =
                                    mapCollegeToId[suggestions[idx]];
                                setState(() {
                                  newCollege = false;
                                });
                              },
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: TextFormField(
                          initialValue: values["fullName"],
                          decoration: InputDecoration(
                            hintText: "Your Full Name",
                            filled: true,
                          ),
                          onSaved: (val) {
                            setState(() {
                              values["fullName"] = val;
                            });
                          },
                          validator: (val) {
                            if (val.length < 2) {
                              return "***Required field***";
                            }
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: TextFormField(
                          initialValue: values["designation"],
                          decoration: InputDecoration(
                            hintText: "Your designation in said college",
                            filled: true,
                          ),
                          onSaved: (val) {
                            setState(() {
                              values["designation"] = val;
                            });
                          },
                          validator: (val) {
                            if (val.length < 2) {
                              return "***Required field***";
                            }
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: TextFormField(
                          initialValue: values["phone"].toString(),
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: "Your phone number",
                            filled: true,
                          ),
                          onSaved: (val) {
                            setState(() {
                              values["phone"] = int.parse(val);
                            });
                          },
                          validator: (val) {
                            if (val.length < 10) {
                              return "Too short";
                            }
                            if (val.length > 10) {
                              return "Too long";
                            }
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: TextFormField(
                          initialValue: values["email"],
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: "Your email",
                            filled: true,
                          ),
                          onSaved: (val) {
                            setState(() {
                              values["email"] = val;
                            });
                          },
                          validator: (val) {
                            if (val != email) {
                              return "You must use your registered email";
                            }
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: RaisedButton(
                          onPressed: () {
                            confirmDialog();
                          },
                          child: Text(
                            "Submit",
                            style: Theme.of(context).textTheme.button,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
