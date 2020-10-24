import 'package:flutter/material.dart';
import 'package:placementhq/providers/user.dart';
import 'package:placementhq/res/constants.dart';
import 'package:provider/provider.dart';

class HomeGrid extends StatefulWidget {
  @override
  _HomeGridState createState() => _HomeGridState();
}

class _HomeGridState extends State<HomeGrid> {
  bool _loading = false;

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
    });
    Provider.of<User>(context, listen: false)
        .loadCurrentUserProfile()
        .then((profile) {
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
