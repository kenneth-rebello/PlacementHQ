import 'package:flutter/material.dart';
import 'package:placementshq/providers/auth.dart';
import 'package:placementshq/providers/user.dart';
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
              TextFormField(
                initialValue: initValues["phone"].toString(),
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: "Phone Number"),
                textInputAction: TextInputAction.next,
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
              TextFormField(
                initialValue: initValues["email"],
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: "Email Address"),
                textInputAction: TextInputAction.next,
                onSaved: (value) {
                  initValues["email"] = value;
                },
                validator: (val) {
                  if (val != email) {
                    return "You must use your registered email";
                  }
                },
                focusNode: _eNode,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_aNode);
                },
              ),
              TextFormField(
                initialValue: initValues["address"],
                decoration: InputDecoration(labelText: "Residence Address"),
                textInputAction: TextInputAction.next,
                onSaved: (value) {
                  initValues["address"] = value;
                },
                focusNode: _aNode,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_cNode);
                },
              ),
              TextFormField(
                initialValue: initValues["city"],
                decoration: InputDecoration(labelText: "City"),
                textInputAction: TextInputAction.next,
                onSaved: (value) {
                  initValues["city"] = value;
                },
                focusNode: _cNode,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_sNode);
                },
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Container(
                  width: 130,
                  child: TextFormField(
                    initialValue: initValues["state"],
                    decoration: InputDecoration(labelText: "State"),
                    textInputAction: TextInputAction.next,
                    onSaved: (value) {
                      initValues["state"] = value;
                    },
                    focusNode: _sNode,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_pNode);
                    },
                  ),
                ),
                Container(
                  width: 100,
                  child: TextFormField(
                    initialValue: initValues["pincode"].toString(),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: "Pincode"),
                    onSaved: (value) {
                      initValues["pincode"] = int.parse(value);
                    },
                    validator: (val) {
                      if (val.length < 2) {
                        return "**Required**";
                      }
                    },
                    focusNode: _pNode,
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
