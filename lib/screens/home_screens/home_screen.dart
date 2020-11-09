import 'package:flutter/material.dart';
import 'package:placementhq/providers/auth.dart';
import 'package:placementhq/providers/officer.dart';
import 'package:placementhq/providers/user.dart';
import 'package:placementhq/res/constants.dart';
import 'package:placementhq/screens/for_officers/account_screen.dart';
import 'package:placementhq/screens/for_students/offers_screen.dart';
import 'package:placementhq/widgets/home/about.dart';
import 'package:placementhq/widgets/home/tpo_home_grid.dart';
import 'package:placementhq/widgets/home/home_grid.dart';
import 'package:placementhq/widgets/other/modal.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = "/home";

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showAbout = false;

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<Auth>(context).userId;
    final isOfficer = Provider.of<Auth>(context, listen: false).isOfficer;
    var profile;
    if (isOfficer == true) {
      profile = Provider.of<Officer>(context).profile;
    } else {
      profile = Provider.of<User>(context).profile;
    }

    final offers =
        Provider.of<User>(context).userOffers.where((o) => o.accepted == null);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Constants.title,
          style: Theme.of(context).textTheme.headline1,
        ),
        actions: [
          if (!isOfficer)
            FlatButton.icon(
              padding: EdgeInsets.symmetric(horizontal: 2),
              icon: Icon(
                Icons.all_inbox,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(OffersScreen.routeName);
              },
              label: Text(
                offers.length.toString(),
                style: Theme.of(context).textTheme.button,
              ),
            ),
          if (isOfficer)
            IconButton(
              icon: Icon(Icons.person),
              onPressed: () {
                Navigator.of(context).pushNamed(AccountScreen.routeName);
              },
              tooltip: "My Account",
            ),
          PopupMenuButton(
            itemBuilder: (ctx) => [
              PopupMenuItem(
                child: FlatButton.icon(
                  icon: Icon(Icons.logout),
                  label: Text("Logout"),
                  onPressed: () {
                    final auth = Provider.of<Auth>(context, listen: false);
                    auth.logout();
                    Navigator.of(ctx).pop();
                  },
                ),
              ),
              PopupMenuItem(
                child: FlatButton.icon(
                  icon: Icon(Icons.info_outline),
                  label: Text("About pHQ"),
                  onPressed: () {
                    setState(() {
                      _showAbout = !_showAbout;
                    });
                    Navigator.of(ctx).pop();
                  },
                ),
              ),
            ],
          )
        ],
        bottom: PreferredSize(
          preferredSize: Size(double.infinity, 30),
          child: Container(
            color: profile == null
                ? Theme.of(context).primaryColor
                : (profile.fullName == null || profile.fullName == "")
                    ? Colors.red
                    : Theme.of(context).primaryColor,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Text(
                profile == null
                    ? "Welcome to Placement HQ!"
                    : (profile.fullName == null || profile.fullName == "")
                        ? "Sorry, we are having trouble connecting with you..."
                        : "Welcome back, ${profile.fullName}!",
                style: Theme.of(context).textTheme.headline4,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          isOfficer ? TPOHomeGrid() : HomeGrid(),
          if (_showAbout)
            Modal(
              controller: _showAbout,
              close: () {
                setState(() {
                  _showAbout = false;
                });
              },
              child: SimpleDialog(
                backgroundColor: Colors.indigo[900],
                title: Text(
                  Constants.title,
                  style: Theme.of(context).textTheme.headline1,
                  textAlign: TextAlign.center,
                ),
                contentPadding: EdgeInsets.all(15),
                children: [
                  AboutText(
                    "Helping colleges streamline the daunting process of placements",
                  ),
                  SizedBox(height: 5),
                  AboutText("Created by:"),
                  AboutText("Kenneth Rebello"),
                  AboutText("Nitesh Prasad"),
                  AboutText("Isaac Sancits"),
                  AboutText("as students of Fr. CRCE (IT)"),
                  AboutText("Nov 2020"),
                  SizedBox(height: 10),
                  RaisedButton(
                    onPressed: () {
                      setState(() {
                        _showAbout = false;
                      });
                    },
                    child: Text(
                      "Close",
                      style: Theme.of(context).textTheme.button,
                    ),
                  ),
                  AboutText("Version 1.0.0"),
                  if (userId != null && userId != "")
                    Container(
                      margin: EdgeInsets.all(3),
                      child: Text(
                        "User ID: $userId",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
