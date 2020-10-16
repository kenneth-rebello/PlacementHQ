import 'package:flutter/material.dart';
import 'package:placementshq/models/user_profile.dart';
import 'package:placementshq/providers/auth.dart';
import 'package:placementshq/providers/user.dart';
import 'package:placementshq/widgets/input/input.dart';
import 'package:provider/provider.dart';

class ContactDetails extends StatefulWidget {
  final Function prevPage;
  final Function nextPage;
  ContactDetails({this.prevPage, this.nextPage});
  @override
  _ContactDetailsState createState() => _ContactDetailsState();
}

class _ContactDetailsState extends State<ContactDetails> {
  final _form = GlobalKey<FormState>();
  Map<String, dynamic> initValues = {
    "phone": 0,
    "email": "",
    "address": "",
    "pincode": 0,
    "city": "",
    "state": "",
    "verified": false,
  };
  String email;

  final _eNode = FocusNode();
  final _aNode = FocusNode();
  final _cNode = FocusNode();
  final _sNode = FocusNode();
  final _pNode = FocusNode();

  @override
  void initState() {
    Profile profile = Provider.of<User>(context, listen: false).profile;
    email = Provider.of<Auth>(context, listen: false).userEmail;
    initValues["email"] = email;
    if (profile != null) {
      if (profile.phone != null) initValues["phone"] = profile.phone;
      if (email != null && email != "") {
        initValues["email"] = email;
      }
      if (profile.email != null) initValues["email"] = profile.email;
      if (profile.address != null) initValues["address"] = profile.address;
      if (profile.city != null) initValues["city"] = profile.city;
      if (profile.state != null) initValues["state"] = profile.state;
      if (profile.pincode != null) initValues["pincode"] = profile.pincode;
      if (profile.verified != null) initValues["verified"] = profile.verified;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        child: Form(
          key: _form,
          autovalidate: true,
          child: Column(
            children: [
              Input(
                initialValue: initValues["phone"].toString(),
                type: TextInputType.phone,
                label: "Phone Number",
                action: TextInputAction.next,
                onSaved: (value) {
                  initValues["phone"] = int.parse(value);
                },
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_eNode);
                },
                validator: (val) {
                  if (val.length < 10) {
                    return "Phone number should have 10 digits";
                  }
                },
              ),
              Input(
                initialValue: initValues["email"],
                type: TextInputType.emailAddress,
                label: "Email Address",
                action: TextInputAction.next,
                onSaved: (value) {
                  initValues["email"] = value;
                },
                validator: (val) {
                  if (val != email) {
                    return "You must use your registered email";
                  }
                },
                node: _eNode,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_aNode);
                },
              ),
              Input(
                initialValue: initValues["address"],
                label: "Residence Address",
                action: TextInputAction.next,
                onSaved: (value) {
                  initValues["address"] = value;
                },
                node: _aNode,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_cNode);
                },
              ),
              Input(
                initialValue: initValues["city"],
                label: "City",
                action: TextInputAction.next,
                onSaved: (value) {
                  initValues["city"] = value;
                },
                node: _cNode,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_sNode);
                },
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Container(
                  width: 130,
                  child: Input(
                    initialValue: initValues["state"],
                    label: "State",
                    action: TextInputAction.next,
                    onSaved: (value) {
                      initValues["state"] = value;
                    },
                    node: _sNode,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_pNode);
                    },
                  ),
                ),
                Container(
                  width: 100,
                  child: Input(
                    initialValue: initValues["pincode"].toString(),
                    type: TextInputType.number,
                    label: "Pincode",
                    onSaved: (value) {
                      initValues["pincode"] = int.parse(value);
                    },
                    requiredField: true,
                    node: _pNode,
                  ),
                ),
              ]),
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
