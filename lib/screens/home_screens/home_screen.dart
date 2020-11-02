import 'package:flutter/material.dart';
import 'package:placementhq/providers/auth.dart';
import 'package:placementhq/providers/user.dart';
import 'package:placementhq/res/constants.dart';
import 'package:placementhq/screens/for_officers/account_screen.dart';
import 'package:placementhq/screens/for_students/offers_screen.dart';
import 'package:placementhq/widgets/home/tpo_home_grid.dart';
import 'package:placementhq/widgets/home/home_grid.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isOfficer = Provider.of<Auth>(context, listen: false).isOfficer;
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
            ],
          )
        ],
      ),
      body: isOfficer ? TPOHomeGrid() : HomeGrid(),
    );
  }
}
