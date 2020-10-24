import 'package:flutter/material.dart';
import 'package:placementhq/providers/auth.dart';
import 'package:placementhq/providers/officer.dart';
import 'package:placementhq/res/constants.dart';
import 'package:provider/provider.dart';

class TPOHomeGrid extends StatefulWidget {
  @override
  _TPOHomeGridState createState() => _TPOHomeGridState();
}

class _TPOHomeGridState extends State<TPOHomeGrid> {
  bool _loading = false;

  Future<void> _refresher() async {
    setState(() {
      _loading = true;
    });
    Provider.of<Officer>(context, listen: false)
        .loadCurrentOfficerProfile()
        .then((_) {
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    List<HomeItem> items = Constants.tpoHomeItems;

    bool verified = Provider.of<Auth>(context).isVerified;

    return !verified
        ? Container(
            margin: EdgeInsets.all(10),
            child: Center(
              child: Text(
                "You have not yet been verified by PlacementHQ. We will get in touch with you shortly.\n\n If your verification is complete, logout and login to access your account.",
                textAlign: TextAlign.center,
              ),
            ),
          )
        : _loading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : RefreshIndicator(
                onRefresh: _refresher,
                child: Container(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: items.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      childAspectRatio: 9 / 4,
                      mainAxisSpacing: 15,
                    ),
                    itemBuilder: (ctx, idx) => GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(items[idx].routeName);
                      },
                      child: GridTile(
                        child: Container(
                          color: idx % 2 != 0
                              ? theme.primaryColor
                              : theme.accentColor,
                          child: Container(
                            padding: EdgeInsets.all(10),
                            child: Image.asset(items[idx].imagePath,
                                color: Colors.white70),
                          ),
                        ),
                        footer: GridTileBar(
                          title: Text(
                            items[idx].label,
                            style: Theme.of(context).textTheme.headline4,
                            textAlign: TextAlign.center,
                          ),
                          backgroundColor: Colors.black45,
                        ),
                      ),
                    ),
                  ),
                ),
              );
  }
}
