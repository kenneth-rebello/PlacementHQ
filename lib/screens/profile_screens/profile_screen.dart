import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:placementhq/models/user_profile.dart';
import 'package:placementhq/providers/officer.dart';
import 'package:placementhq/providers/user.dart';
import 'package:placementhq/screens/profile_screens/edit_profile.dart';
import 'package:placementhq/screens/profile_screens/tpo_application.dart';
import 'package:placementhq/widgets/other/image_error.dart';
import 'package:placementhq/widgets/other/list_item.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = "/profile";

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DateFormat formatter = new DateFormat("dd-MM-yyyy");
  void _showMarks(Profile profile) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        contentPadding: EdgeInsets.all(10),
        title: Text(
          "Academic Details",
          style: TextStyle(
            color: Theme.of(context).primaryColor,
          ),
        ),
        children: [
          ListItem(
            label: "Std Xth %",
            value: profile.secMarks.toStringAsFixed(1),
            shrink: true,
            ratio: 1 / 2,
          ),
          ListItem(
            label: "Std XIIth %",
            value: profile.highSecMarks.toStringAsFixed(1),
            shrink: true,
            ratio: 1 / 2,
          ),
          if (profile.hasDiploma)
            ListItem(
              label: "Diploma %",
              value: profile.diplomaMarks.toStringAsFixed(1),
              shrink: true,
              ratio: 1 / 2,
            ),
          ListItem(
            label: "BE CGPA",
            value: profile.cgpa.toStringAsFixed(1),
            shrink: true,
            ratio: 1 / 2,
          ),
          ListItem(
            label: "BE %",
            value: profile.beMarks.toStringAsFixed(1),
            shrink: true,
            ratio: 1 / 2,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Profile profile;
    bool isNotOwnProfile = false;
    final profileId = ModalRoute.of(context).settings.arguments;
    if (profileId == null) {
      profile = Provider.of<User>(context).profile;
    } else {
      isNotOwnProfile = true;
      profile = Provider.of<Officer>(context).getProfileById(profileId);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          profile == null ? "Could not find profile" : profile.fullName,
          style: Theme.of(context).textTheme.headline1,
        ),
        actions: [
          if (!isNotOwnProfile)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                Navigator.of(context).pushNamed(EditProfile.routeName);
              },
            )
        ],
      ),
      body: profile == null
          ? Container(
              alignment: Alignment.center,
              margin: EdgeInsets.all(10),
              child: isNotOwnProfile
                  ? Center(
                      child: Column(children: [
                        Text("Could not load profile, please try again"),
                        RaisedButton(
                          onPressed: () {},
                          child: Text(
                            "Retry",
                            style: Theme.of(context).textTheme.button,
                          ),
                        )
                      ]),
                    )
                  : Container(
                      height: 200,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text("You have not yet created a profile."),
                          Text(
                            "For students, click the below button to create your profile now in 3 quick and easy steps.",
                            textAlign: TextAlign.center,
                          ),
                          RaisedButton(
                            onPressed: () {
                              Navigator.of(context)
                                  .pushNamed(EditProfile.routeName);
                            },
                            child: Text(
                              "Create Now",
                              style: Theme.of(context).textTheme.button,
                            ),
                          ),
                          Text(
                            "--------OR--------",
                            style: TextStyle(
                                color: Colors.grey[350], fontSize: 20),
                          ),
                          Text('Apply for a TPO account?'),
                          RaisedButton(
                            child: Text(
                              "Apply Now",
                              style: Theme.of(context).textTheme.button,
                            ),
                            onPressed: () {
                              Navigator.of(context)
                                  .pushNamed(TPOApplication.routeName);
                            },
                          ),
                        ],
                      ),
                    ),
            )
          : Container(
              margin: EdgeInsets.all(10),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (profile.imageUrl != "" && profile.imageUrl != null)
                      Container(
                        height: 120,
                        child: Image.network(profile.imageUrl,
                            errorBuilder: (context, error, stackTrace) =>
                                ImageError()),
                        margin: EdgeInsets.all(10),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        NameItem(
                          label: "First Name",
                          value: profile.firstName,
                        ),
                        NameItem(
                          label: "Middle Name",
                          value: profile.middleName,
                        ),
                        NameItem(
                          label: "Last Name",
                          value: profile.lastName,
                        ),
                      ],
                    ),
                    ListItem(
                      label: "College UID",
                      value: profile.rollNo,
                    ),
                    ListItem(
                      label: "College",
                      value: profile.collegeName,
                      flexibleHeight: true,
                    ),
                    ListItem(
                      label: "Specialization",
                      value: profile.specialization,
                    ),
                    Divider(),
                    Center(
                      child: FlatButton(
                        child: Text(
                          "Academic Details",
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        onPressed: () => _showMarks(profile),
                      ),
                    ),
                    ListItem(
                      label: "Email",
                      value: profile.email,
                    ),
                    ListItem(
                      label: "Phone No.",
                      value: profile.phone.toString(),
                    ),
                    if (profile.dateOfBirth != null &&
                        profile.dateOfBirth != "")
                      ListItem(
                        label: "Date Of Birth",
                        value: formatter
                            .format(DateTime.parse(profile.dateOfBirth)),
                      ),
                    if (profile.resumeUrl != null && profile.resumeUrl != "")
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RichText(
                          text: TextSpan(children: [
                            TextSpan(
                                text: "Resume URL",
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: Colors.blue[900],
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () async {
                                    if (await canLaunch(profile.resumeUrl)) {
                                      await launch(profile.resumeUrl);
                                    }
                                  })
                          ]),
                        ),
                      ),
                    ListItem(
                      label: "Address",
                      value: profile.address,
                      flexibleHeight: true,
                    ),
                    ListItem(
                      label: "City",
                      value: profile.city,
                    ),
                    ListItem(
                      label: "State",
                      value: profile.state,
                    ),
                    ListItem(
                      label: "Pincode",
                      value: profile.pincode.toString(),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class NameItem extends StatelessWidget {
  final String label;
  final String value;

  NameItem({this.label, this.value});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: EdgeInsets.all(10),
      child: Column(children: [
        Text(
          value,
          style: Theme.of(context).textTheme.bodyText1,
        ),
        Container(
          color: Colors.grey[500],
          child: SizedBox(
            height: 1,
            width: 50,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyText2,
        ),
      ]),
    );
  }
}
