import 'package:flutter/material.dart';
import 'package:placementhq/providers/auth.dart';
import 'package:placementhq/res/constants.dart';
import 'package:placementhq/widgets/home/tpo_home_grid.dart';
import 'package:placementhq/widgets/home/home_grid.dart';
import 'package:provider/provider.dart';

enum Options {
  Logout,
}

class HomeScreen extends StatelessWidget {
  static const routeName = "/";
  @override
  Widget build(BuildContext context) {
    bool isOfficer = Provider.of<Auth>(context, listen: false).isOfficer;
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
      body: isOfficer ? TPOHomeGrid() : HomeGrid(),
    );
  }
}
