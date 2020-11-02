import 'package:flutter/material.dart';
import 'package:placementhq/providers/auth.dart';
import 'package:placementhq/providers/drives.dart';
import 'package:placementhq/screens/for_officers/new_notice_screen.dart';
import 'package:placementhq/widgets/notice_item/notice_item.dart';
import 'package:placementhq/widgets/other/empty_list.dart';
import 'package:placementhq/widgets/other/error.dart';
import 'package:provider/provider.dart';

class NoticesScreen extends StatefulWidget {
  static const routeName = "/notices";

  @override
  _NoticesScreenState createState() => _NoticesScreenState();
}

class _NoticesScreenState extends State<NoticesScreen> {
  bool _loading = false;
  bool _error = false;

  @override
  void initState() {
    _loading = true;
    final collegeId = Provider.of<Auth>(context, listen: false).collegeId;
    Provider.of<Drives>(context, listen: false)
        .getAllNotices(collegeId)
        .then((value) {
      if (mounted)
        setState(() {
          _loading = false;
          _error = false;
        });
    }).catchError((e) {
      setState(() {
        _loading = false;
        _error = true;
      });
    });

    super.initState();
  }

  Future<void> _refresher() async {
    setState(() {
      _loading = true;
    });
    final collegeId = Provider.of<Auth>(context, listen: false).collegeId;
    Provider.of<Drives>(context, listen: false)
        .getAllNotices(collegeId)
        .then((value) {
      if (mounted)
        setState(() {
          _loading = false;
          _error = false;
        });
    }).catchError((e) {
      setState(() {
        _loading = false;
        _error = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final notices = Provider.of<Drives>(context).notices;
    final isOfficer = Provider.of<Auth>(context).isOfficer;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Notices",
          style: Theme.of(context).textTheme.headline1,
        ),
        actions: [
          if (isOfficer)
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).pushNamed(NewNoticeScreen.routeName);
              },
              tooltip: "Publish notice",
            ),
        ],
      ),
      body: Container(
        margin: EdgeInsets.all(10),
        child: _loading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : _error
                ? Error(refresher: _refresher)
                : notices.isEmpty
                    ? RefreshIndicator(
                        onRefresh: _refresher,
                        child: EmptyList(
                          message: "There are no notices to show",
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _refresher,
                        child: ListView.builder(
                          itemBuilder: (ctx, idx) => NoticeItem(notices[idx]),
                          itemCount: notices.length,
                        ),
                      ),
      ),
    );
  }
}
