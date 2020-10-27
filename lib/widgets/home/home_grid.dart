import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:placementhq/providers/auth.dart';
import 'package:placementhq/providers/user.dart';
import 'package:placementhq/res/constants.dart';
import 'package:placementhq/screens/for_students/notices_screen.dart';
import 'package:provider/provider.dart';

class HomeGrid extends StatefulWidget {
  @override
  _HomeGridState createState() => _HomeGridState();
}

class _HomeGridState extends State<HomeGrid> {
  bool _loading = false;

  void initState() {
    final fbm = FirebaseMessaging();
    fbm.configure(
      onMessage: (msg) {
        print(msg);
        if (msg["notification"] != null)
          showDialog(
            context: context,
            builder: (ctx) => SimpleDialog(
              contentPadding: EdgeInsets.all(16),
              backgroundColor: Colors.orange[200],
              title: Text(
                msg["notification"]["title"],
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
        print(msg);
        return;
      },
      onResume: (msg) {
        print(msg);
        return;
      },
    );
    Provider.of<User>(context, listen: false)
        .loadCurrentUserProfile()
        .then((_) {
      String collegeId = Provider.of<User>(context, listen: false).collegeId;
      String userId = Provider.of<Auth>(context, listen: false).userId;
      final topic1 = "user" + userId;
      fbm.subscribeToTopic(topic1);
      if (collegeId != null) {
        Provider.of<Auth>(context, listen: false).setCollegeId(collegeId);
        final topic2 = "college_" + collegeId;
        fbm.subscribeToTopic(topic2);
      }
      setState(() {
        _loading = false;
      });
    });
    super.initState();
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
    });
    Provider.of<User>(context, listen: false)
        .loadCurrentUserProfile()
        .then((_) {
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    List<HomeItem> items = Constants.homeItems;

    final profile = Provider.of<User>(context).profile;
    if (profile == null) {
      items = items.where((item) => !item.protected).toList();
    }
    return _loading
        ? Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _refresh,
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
                      color:
                          idx % 2 != 0 ? theme.primaryColor : theme.accentColor,
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
