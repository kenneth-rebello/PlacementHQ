import 'package:flutter/material.dart';
import 'package:placementhq/providers/officer.dart';
import 'package:placementhq/widgets/input/input.dart';
import 'package:placementhq/widgets/other/list_item.dart';
import 'package:provider/provider.dart';

class AccountScreen extends StatefulWidget {
  static const routeName = "/account";

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _form = GlobalKey<FormState>();
  bool editable = false;
  bool _loading = false;
  Map<String, dynamic> values = {
    "email": "",
    "phone": "",
  };

  @override
  void initState() {
    final account = Provider.of<Officer>(context, listen: false).profile;
    values = {
      "email": account.email,
      "phone": account.phone,
    };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final account = Provider.of<Officer>(context).profile;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My Account",
          style: Theme.of(context).textTheme.headline1,
        ),
        actions: [
          IconButton(
            icon: Icon(editable ? Icons.save : Icons.edit),
            onPressed: editable
                ? () {
                    if (_form.currentState.validate()) {
                      setState(() {
                        _loading = true;
                      });
                      Provider.of<Officer>(context, listen: false)
                          .editProfile(values)
                          .then((_) {
                        setState(() {
                          editable = false;
                          _loading = false;
                        });
                      });
                    }
                  }
                : () {
                    setState(() {
                      editable = true;
                    });
                  },
          )
        ],
      ),
      body: Form(
        key: _form,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Container(
          margin: EdgeInsets.all(10),
          child: _loading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      ListItem(label: "Name", value: account.fullName),
                      ListItem(
                          label: "Designation", value: account.designation),
                      ListItem(
                        label: "College",
                        value: account.collegeName,
                        flexibleHeight: true,
                      ),
                      editable
                          ? Input(
                              initialValue: values["email"],
                              onChanged: (val) {
                                setState(() {
                                  values["email"] = val;
                                });
                              },
                              label: "Email",
                              type: TextInputType.emailAddress,
                              requiredField: true,
                              validator: (val) {
                                if (!val.contains("@")) {
                                  return "Should be a valid email address";
                                }
                                return null;
                              },
                            )
                          : ListItem(
                              label: "Email",
                              value: account.email,
                              flexibleHeight: true,
                            ),
                      editable
                          ? Input(
                              initialValue: values["phone"].toString(),
                              onChanged: (val) {
                                setState(() {
                                  values["phone"] = int.parse(val);
                                });
                              },
                              label: "Phone Number",
                              type: TextInputType.phone,
                              requiredField: true,
                              validator: (val) {
                                if (val.length != 10) {
                                  return "Should be 10 digits";
                                }
                                return null;
                              },
                            )
                          : ListItem(
                              label: "Phone No",
                              value: account.phone.toString())
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
