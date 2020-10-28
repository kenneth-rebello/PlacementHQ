import 'package:flutter/material.dart';
import 'package:placementhq/providers/drives.dart';
import 'package:placementhq/providers/user.dart';
import 'package:placementhq/widgets/notice_item/notice_item.dart';
import 'package:provider/provider.dart';

class NoticesScreen extends StatefulWidget {
  static const routeName = "/notices";

  @override
  _NoticesScreenState createState() => _NoticesScreenState();
}

class _NoticesScreenState extends State<NoticesScreen> {
  bool _loading = false;

  @override
  void initState() {
    _loading = true;
    final collegeId = Provider.of<User>(context, listen: false).collegeId;
    Provider.of<Drives>(context, listen: false)
        .getAllNotices(collegeId)
        .then((value) {
      setState(() {
        if (mounted) _loading = false;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final notices = Provider.of<Drives>(context).notices;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Notices",
          style: Theme.of(context).textTheme.headline1,
        ),
      ),
      body: Container(
        margin: EdgeInsets.all(10),
        child: _loading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : notices.length <= 0
                ? Center(child: Text("There are no notices to show"))
                : ListView.builder(
                    itemBuilder: (ctx, idx) => NoticeItem(notices[idx]),
                    itemCount: notices.length,
                  ),
      ),
    );
  }
}
