import 'package:flutter/material.dart';
import 'package:placementhq/providers/auth.dart';
import 'package:placementhq/res/constants.dart';
import 'package:placementhq/screens/for_officers/account_screen.dart';
import 'package:placementhq/screens/for_students/offers_screen.dart';
import 'package:placementhq/widgets/home/tpo_home_grid.dart';
import 'package:placementhq/widgets/home/home_grid.dart';
import 'package:provider/provider.dart';

enum Options {
  Logout,
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isOfficer = Provider.of<Auth>(context, listen: false).isOfficer;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Constants.title,
          style: Theme.of(context).textTheme.headline1,
        ),
        actions: [
          if (!isOfficer)
            IconButton(
              icon: Icon(Icons.all_inbox),
              onPressed: () {
                Navigator.of(context).pushNamed(OffersScreen.routeName);
              },
              tooltip: "Your Offers",
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
