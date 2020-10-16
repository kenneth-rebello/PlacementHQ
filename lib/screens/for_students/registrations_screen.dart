import 'package:flutter/material.dart';
import 'package:placementshq/providers/drives.dart';
import 'package:placementshq/providers/user.dart';
import 'package:placementshq/widgets/registration_item/registration_item.dart';
import 'package:provider/provider.dart';

class RegistrationsScreen extends StatefulWidget {
  static const routeName = "/registrations";

  @override
  _RegistrationsScreenState createState() => _RegistrationsScreenState();
}

class _RegistrationsScreenState extends State<RegistrationsScreen> {
  bool _loading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final registrations = Provider.of<User>(context).userRegistrations;

    return Scaffold(
      appBar: AppBar(
        title: Text("Registered Companies"),
      ),
      body: Container(
        margin: EdgeInsets.all(10),
        child: ListView.builder(
          itemBuilder: (ctx, idx) => RegistrationItem(registrations[idx]),
          itemCount: registrations.length,
        ),
      ),
    );
  }
}
