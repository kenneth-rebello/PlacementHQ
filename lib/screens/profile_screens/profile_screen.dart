import 'package:flutter/material.dart';
import 'package:placementshq/providers/user.dart';
import 'package:placementshq/screens/profile_screens/edit_profile.dart';
import 'package:placementshq/screens/profile_screens/tpo_application.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  static const routeName = "/profile";
  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<User>(context).profile;
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).pushNamed(EditProfile.routeName);
            },
          )
        ],
      ),
      body: profile == null
          ? Container(
              alignment: Alignment.center,
              child: Container(
                height: 200,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text("You have not yet created a profile."),
                    RaisedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(EditProfile.routeName);
                      },
                      child: Text(
                        "Create Now",
                        style: Theme.of(context).textTheme.button,
                      ),
                    ),
                    Text(
                      "--------OR--------",
                      style: TextStyle(color: Colors.grey[350], fontSize: 20),
                    ),
                    Text('Apply for a TPO account?'),
                    RaisedButton(
                      child: Text(
                        "Apply Now",
                        style: Theme.of(context).textTheme.button,
                      ),
                      onPressed: () {
                        Navigator.of(context)
                            .pushNamed(TPOApplication.routeName);
                      },
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                      profile.firstName + profile.middleName + profile.lastName)
                ],
              ),
            ),
    );
  }
}
