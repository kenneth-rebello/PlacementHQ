import 'package:flutter/material.dart';
import 'package:placementhq/providers/auth.dart';
import 'package:placementhq/providers/colleges.dart';
import 'package:placementhq/providers/officer.dart';
import 'package:placementhq/widgets/input/input.dart';
import 'package:placementhq/widgets/input/no_button.dart';
import 'package:placementhq/widgets/input/yes_button.dart';
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
              title: Text(
                "Submit Application?",
                style: Theme.of(context).textTheme.headline3,
                textAlign: TextAlign.left,
              ),
              content: Column(
                children: [
                  Text(
                    "College Name:\t${values["collegeName"]}\nFull Name:\t${values["fullName"]}\nDesignation:\t${values["designation"]}\nPhone Number:\t${values["phone"].toString()}\nEmail:\t${values["email"]}",
                  ),
                  if (newCollege)
                    Text(
                      "You are creating a new college entry for ${values["collegeName"]}\nIf another TPO has already create one, you must search and join the same.\nIf not, click yes to continue.",
                      style: TextStyle(
                        color: Theme.of(context).errorColor,
                      ),
                    )
                ],
              ),
              actions: [
                NoButton(ctx),
                YesButton(ctx),
              ],
            )).then((res) {
      if (res) {
        if (_form.currentState.validate()) {
          Provider.of<Officer>(context, listen: false)
              .applyForAccount(values, newCollege)
              .then((_) {
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
      if (mounted)
        setState(() {
          _loading = false;
        });
    });
    super.initState();
  }

  Future<void> _refresher() async {
    setState(() {
      _loading = true;
    });
    email = Provider.of<Auth>(context, listen: false).userEmail;
    values["email"] = email;
    Provider.of<Colleges>(context, listen: false).loadColleges().then((value) {
      if (mounted)
        setState(() {
          _loading = false;
        });
    });
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
        title: Text(
          "Apply for TPO account",
          style: Theme.of(context).textTheme.headline1,
        ),
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _refresher,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: SingleChildScrollView(
                  child: Form(
                    key: _form,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Input(
                          controller: cont,
                          label: "College Name",
                          helperLines: 6,
                          helper:
                              "\u2022Suggested to use full name displayed on official college website.\n\u2022Avoid making acronyms.\nIf your college name shows in the space below this, please click it.",
                          disabled: !newCollege,
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
                          },
                          requiredField: true,
                        ),
                        if (suggestions.length > 0)
                          Container(
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
                                  setState(() {
                                    values["collegeName"] = suggestions[idx];
                                    values["collegeId"] =
                                        mapCollegeToId[suggestions[idx]];
                                    suggestions = [];
                                    newCollege = false;
                                  });
                                },
                              ),
                            ),
                          ),
                        Input(
                          initialValue: values["fullName"],
                          label: "Your Full Name",
                          onSaved: (val) {
                            setState(() {
                              values["fullName"] = val;
                            });
                          },
                          requiredField: true,
                        ),
                        Input(
                          initialValue: values["designation"],
                          label: "Your designation in said college",
                          onSaved: (val) {
                            setState(() {
                              values["designation"] = val;
                            });
                          },
                          requiredField: true,
                        ),
                        Input(
                          initialValue: values["phone"].toString(),
                          type: TextInputType.phone,
                          label: "Your phone number",
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
                            return null;
                          },
                        ),
                        Input(
                          initialValue: values["email"],
                          type: TextInputType.emailAddress,
                          label: "Your email",
                          onSaved: (val) {
                            setState(() {
                              values["email"] = val;
                            });
                          },
                          validator: (val) {
                            if (val != email) {
                              return "You must use your registered email";
                            }
                            return null;
                          },
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
            ),
    );
  }
}
