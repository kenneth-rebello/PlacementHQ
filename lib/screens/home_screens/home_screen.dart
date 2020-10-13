import 'package:flutter/material.dart';
import 'package:placementshq/providers/auth.dart';
import 'package:placementshq/res/constants.dart';
import 'package:placementshq/widgets/home/tpo_home_grid.dart';
import 'package:placementshq/widgets/home/home_grid.dart';
import 'package:provider/provider.dart';

enum Options {
  Logout,
}

class HomeScreen extends StatelessWidget {
  static const routeName = "/";
  @override
  Widget build(BuildContext context) {
    bool isOfficer = Provider.of<Auth>(context).isOfficer;
    return Scaffold(
      appBar: AppBar(
        title: Text(Constants.title),
        actions: [
          PopupMenuButton(
            onSelected: (Options value) {
              if (value == Options.Logout) {
                Provider.of<Auth>(context, listen: false).logout();
              }
            },
            icon: Icon(
              Icons.more_vert,
            ),
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