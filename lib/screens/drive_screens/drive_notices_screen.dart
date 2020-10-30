import 'package:flutter/material.dart';
import 'package:placementhq/providers/drives.dart';
import 'package:placementhq/widgets/notice_item/notice_item.dart';
import 'package:placementhq/widgets/other/empty_list.dart';
import 'package:placementhq/widgets/other/error.dart';
import 'package:provider/provider.dart';

class DriveNoticesScreen extends StatefulWidget {
  final String driveId;
  DriveNoticesScreen(this.driveId);
  @override
  _DriveNoticesScreenState createState() => _DriveNoticesScreenState();
}

class _DriveNoticesScreenState extends State<DriveNoticesScreen> {
  bool _loading = false;
  bool _error = false;

  @override
  void initState() {
    _loading = true;
    if (widget.driveId != null) {
      Provider.of<Drives>(context, listen: false)
          .getDriveNotices(widget.driveId)
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
    super.initState();
  }

  Future<void> _refresher() async {
    setState(() {
      _loading = true;
    });
    if (widget.driveId != null) {
      Provider.of<Drives>(context, listen: false)
          .getDriveNotices(widget.driveId)
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
            : _error
                ? Error(
                    refresher: _refresher,
                  )
                : notices.isEmpty
                    ? EmptyList()
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
