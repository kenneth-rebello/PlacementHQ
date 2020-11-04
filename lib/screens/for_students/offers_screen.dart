import 'package:flutter/material.dart';
import 'package:placementhq/providers/user.dart';
import 'package:placementhq/widgets/input/no_button.dart';
import 'package:placementhq/widgets/input/yes_button.dart';
import 'package:placementhq/widgets/other/empty_list.dart';
import 'package:placementhq/widgets/other/image_error.dart';
import 'package:provider/provider.dart';

class OffersScreen extends StatelessWidget {
  static const routeName = "/offers";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Your Offers",
          style: Theme.of(context).textTheme.headline1,
        ),
      ),
      body: OffersWidget(),
    );
  }
}

class OffersWidget extends StatefulWidget {
  @override
  _OffersState createState() => _OffersState();
}

class _OffersState extends State<OffersWidget> {
  bool _inProgress = false;

  Future<void> _refresher() async {
    Provider.of<User>(context, listen: false).getOffers();
  }

  void _confirm(String id, bool value, String category) {
    String hint = value ? "Accept" : "Reject";
    String msg = value ? "Offer Accepted" : "Offer Rejected";
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          "Are your sure?",
          style: Theme.of(context).textTheme.headline3,
        ),
        content: Text(
          "Once confirmed, this action cannot be undone!\n You have picked $hint",
          style: TextStyle(
            color: Colors.red,
          ),
          textAlign: TextAlign.center,
        ),
        contentPadding: EdgeInsets.all(15),
        actions: [NoButton(ctx), YesButton(ctx)],
      ),
    ).then((res) {
      if (res) {
        setState(() {
          _inProgress = true;
        });
        Provider.of<User>(context, listen: false)
            .respondToOffer(id, value, category)
            .then((_) {
          Scaffold.of(context).showSnackBar(SnackBar(content: Text(msg)));
          setState(() {
            _inProgress = false;
          });
        }).catchError((c) {
          Scaffold.of(context).showSnackBar(SnackBar(content: Text("Failed")));
          setState(() {
            _inProgress = false;
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final offers = Provider.of<User>(context).userOffers;

    return Container(
      child: offers.isEmpty
          ? EmptyList(
              message: "Keep Trying!",
            )
          : RefreshIndicator(
              onRefresh: _refresher,
              child: ListView.builder(
                itemBuilder: (ctx, idx) => Container(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: Container(
                      height: 100,
                      width: 100,
                      child: Image.network(
                        offers[idx].companyImageUrl,
                        errorBuilder: (c, e, s) => ImageError(),
                      ),
                    ),
                    title: Text(
                      offers[idx].companyName,
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    subtitle: RichText(
                      text: TextSpan(
                        style: TextStyle(color: Colors.black),
                        children: <TextSpan>[
                          TextSpan(
                            text: "Status: ",
                            style: Theme.of(context).textTheme.bodyText2,
                          ),
                          offers[idx].accepted == null
                              ? TextSpan(
                                  text: "Awaiting",
                                )
                              : offers[idx].accepted
                                  ? TextSpan(
                                      text: "Accepted",
                                      style: TextStyle(
                                        color: Colors.green,
                                      ),
                                    )
                                  : TextSpan(
                                      text: "Rejected",
                                      style: TextStyle(
                                        color: Colors.red,
                                      ),
                                    ),
                        ],
                      ),
                    ),
                    trailing: offers[idx].accepted == null
                        ? PopupMenuButton(
                            enabled: !_inProgress,
                            itemBuilder: (pCtx) => [
                              PopupMenuItem(
                                child: FlatButton.icon(
                                  label: Text("Accept"),
                                  icon: Icon(
                                    Icons.check_circle,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  onPressed: () {
                                    _confirm(offers[idx].id, true,
                                        offers[idx].category);
                                  },
                                ),
                              ),
                              PopupMenuItem(
                                child: FlatButton.icon(
                                  label: Text("Reject"),
                                  icon: Icon(
                                    Icons.cancel,
                                    color: Theme.of(context).errorColor,
                                  ),
                                  onPressed: () {
                                    _confirm(offers[idx].id, false,
                                        offers[idx].category);
                                  },
                                ),
                              ),
                            ],
                          )
                        : null,
                  ),
                ),
                itemCount: offers.length,
              ),
            ),
    );
  }
}
