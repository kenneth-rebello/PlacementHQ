import 'package:flutter/material.dart';
import 'package:placementhq/providers/user.dart';
import 'package:placementhq/widgets/profile/academic_details.dart';
import 'package:placementhq/widgets/profile/contact_details.dart';
import 'package:placementhq/widgets/profile/personal_details.dart';
import 'package:provider/provider.dart';

class EditProfile extends StatefulWidget {
  static const routeName = "/edit_profile";

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  int _tabIndex;
  bool _loading = false;

  @override
  initState() {
    _tabController = new TabController(length: 3, vsync: this);
    _tabIndex = 0;
    super.initState();
  }

  void nextPage(Map<String, dynamic> profileData) {
    setState(() {
      _loading = true;
    });
    Provider.of<User>(context, listen: false)
        .editProfile(profileData)
        .then((_) {
      setState(() {
        _loading = false;
        _tabIndex = (_tabIndex + 1) % 3;
      });
    });
  }

  void prevPage() {
    setState(() {
      _tabIndex = _tabIndex - 1 == -1 ? 2 : (_tabIndex - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    _tabController.animateTo(_tabIndex);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Edit Profile"),
          bottom: TabBar(controller: _tabController, tabs: [
            Tab(
              icon: Icon(Icons.account_circle),
            ),
            Tab(
              icon: Icon(Icons.school),
            ),
            Tab(
              icon: Icon(Icons.email),
            ),
          ]),
        ),
        body: _loading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Container(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    PersonalDetails(nextPage: nextPage),
                    AcademicDetails(prevPage: prevPage, nextPage: nextPage),
                    ContactDetails(prevPage: prevPage, nextPage: nextPage),
                  ],
                ),
              ),
      ),
    );
  }
}
