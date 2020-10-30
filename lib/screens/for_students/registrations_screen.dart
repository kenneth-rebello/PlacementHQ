import 'package:flutter/material.dart';
import 'package:placementhq/providers/drives.dart';
import 'package:placementhq/providers/user.dart';
import 'package:placementhq/screens/for_students/drives_screen.dart';
import 'package:placementhq/widgets/other/empty_list.dart';
import 'package:placementhq/widgets/other/error.dart';
import 'package:placementhq/widgets/registration_item/registration_item.dart';
import 'package:provider/provider.dart';

class RegistrationsScreen extends StatefulWidget {
  static const routeName = "/registrations";

  @override
  _RegistrationsScreenState createState() => _RegistrationsScreenState();
}

class _RegistrationsScreenState extends State<RegistrationsScreen> {
  bool _loading = false;
  bool _error = false;

  @override
  void initState() {
    _loading = true;
    final collegeId = Provider.of<User>(context, listen: false).collegeId;
    Provider.of<Drives>(context, listen: false).loadDrives(collegeId).then((_) {
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
    final collegeId = Provider.of<User>(context, listen: false).collegeId;
    Provider.of<Drives>(context, listen: false).loadDrives(collegeId).then((_) {
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

  @override
  Widget build(BuildContext context) {
    final registrations = Provider.of<User>(context).userRegistrations;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Registered Companies",
          style: Theme.of(context).textTheme.headline1,
        ),
      ),
      body: Container(
        margin: EdgeInsets.all(10),
        child: _loading
            ? Center(child: CircularProgressIndicator())
            : _error
                ? Error(
                    refresher: _refresher,
                  )
                : registrations.length <= 0
                    ? EmptyList(
                        message:
                            "You have not yet registered for a placement drive.",
                        action: RaisedButton(
                          child: Text(
                            "See Latest Drives",
                            style: Theme.of(context).textTheme.button,
                          ),
                          onPressed: () {
                            Navigator.of(context)
                                .pushNamed(DrivesScreen.routeName);
                          },
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _refresher,
                        child: ListView.builder(
                          itemBuilder: (ctx, idx) =>
                              RegistrationItem(registrations[idx]),
                          itemCount: registrations.length,
                        ),
                      ),
      ),
    );
  }
}
