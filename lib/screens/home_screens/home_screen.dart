import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:placementhq/providers/auth.dart';
import 'package:placementhq/providers/officer.dart';
import 'package:placementhq/providers/user.dart';
import 'package:placementhq/res/constants.dart';
import 'package:placementhq/screens/for_students/notices_screen.dart';
import 'package:placementhq/widgets/home/tpo_home_grid.dart';
import 'package:placementhq/widgets/home/home_grid.dart';
import 'package:provider/provider.dart';

enum Options {
  Logout,
}

class HomeScreen extends StatefulWidget {
  static const routeName = "/";

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading;
  bool isOfficer = false;

  @override
  void initState() {
    _loading = true;

    final fbm = FirebaseMessaging();
    fbm.configure(
      onMessage: (msg) {
        if (msg["notification"] != null)
          showDialog(
            context: context,
            builder: (ctx) => SimpleDialog(
              contentPadding: EdgeInsets.all(16),
              backgroundColor: Colors.orange[200],
              title: Text(
                "Notice for " + msg["notification"]["title"] + " candidates",
                style: TextStyle(
                  fontFamily: 'Ubuntu',
                  color: Colors.indigo[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
              children: [
                Text(
                  msg["notification"]["body"],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Ubuntu',
                    fontWeight: FontWeight.normal,
                  ),
                ),
                RaisedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop(true);
                  },
                  child: Text(
                    "Open Notices",
                    style: TextStyle(
                      fontFamily: 'Ubuntu',
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          ).then((value) {
            if (value != null) {
              if (value)
                Navigator.of(context).pushNamed(NoticesScreen.routeName);
            }
          });
        return;
      },
      onLaunch: (msg) {
        return;
      },
      onResume: (msg) {
        return;
      },
    );
    isOfficer = Provider.of<Auth>(context, listen: false).isOfficer;
    if (isOfficer) {
      Provider.of<Officer>(context, listen: false)
          .loadCurrentOfficerProfile()
          .then((_) {
        setState(() {
          _loading = false;
        });
      });
    } else {
      Provider.of<User>(context, listen: false)
          .loadCurrentUserProfile()
          .then((profile) {
        setState(() {
          String collegeId =
              Provider.of<User>(context, listen: false).collegeId;
          if (collegeId != null) {
            Provider.of<Auth>(context, listen: false).setCollegeId(collegeId);
            fbm.subscribeToTopic('notices_' + collegeId);
          } else {
            Provider.of<Auth>(context, listen: false).setCollegeId(null);
          }

          _loading = false;
        });
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Constants.title,
          style: Theme.of(context).textTheme.headline1,
        ),
        actions: [
          PopupMenuButton(
            onSelected: (Options value) {
              if (value == Options.Logout) {
                final auth = Provider.of<Auth>(context, listen: false);
                auth.logout();
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text(
                  "Logout",
                ),
                value: Options.Logout,
              ),
            ],
          )
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : isOfficer
              ? TPOHomeGrid()
              : HomeGrid(),
    );
  }
}
