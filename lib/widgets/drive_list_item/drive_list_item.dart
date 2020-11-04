import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:placementhq/models/drive.dart';
import 'package:placementhq/providers/user.dart';
import 'package:placementhq/models/user_profile.dart';
import 'package:placementhq/screens/drive_screens/drive_details.dart';
import 'package:placementhq/widgets/drive_list_item/criteria.dart';
import 'package:placementhq/widgets/drive_list_item/one_value.dart';
import 'package:placementhq/widgets/drive_list_item/two_values.dart';
import 'package:placementhq/widgets/input/no_button.dart';
import 'package:placementhq/widgets/input/yes_button.dart';
import 'package:placementhq/widgets/other/image_error.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class DriveListItem extends StatefulWidget {
  final Drive drive;
  final Profile profile;
  DriveListItem({this.drive, this.profile});
  @override
  _DriveListItemState createState() => _DriveListItemState();
}

class _DriveListItemState extends State<DriveListItem> {
  bool _expanded = false;
  DateFormat formatter = new DateFormat("dd-MM-yy");

  bool ifEligible(Drive drive, Profile profile) {
    if (drive.minSecMarks > profile.secMarks) return false;
    if (drive.minHighSecMarks > profile.highSecMarks) return false;
    if (drive.minBEMarks > profile.beMarks) return false;
    if (profile.hasDiploma) {
      if (drive.minDiplomaMarks > profile.diplomaMarks) return false;
    }
    if (drive.minCGPA > profile.cgpa) return false;
    if (profile.numOfGapYears > drive.maxGapYears) return false;
    if (profile.numOfKTs > drive.maxKTs) return false;
    return true;
  }

  String detailsCheck(Drive drive, Profile profile) {
    String result = "";
    if (profile.rollNo == null) result += "UID/Roll no.\n";
    if (profile.email == null) result += "Email\n";
    if (profile.phone == null) result += "Phone number\n";
    if (profile.specialization == null) result += "Specialization\n";
    if (profile.secMarks == null) result += "Std Xth Marks\n";
    if (profile.highSecMarks == null) result += "Std XIIth Marks\n";
    if (profile.cgpa == null) result += "CGPA\n";
    if (profile.nationality == null && drive.requirements["nationality"])
      result += "Nationality\n";
    if (profile.dateOfBirth == null && drive.requirements["age"])
      result += "Date of Birth\n";
    if (profile.gender == null && drive.requirements["gender"])
      result += "Gender\n";
    if (profile.address == null &&
        profile.pincode == null &&
        drive.requirements["address"]) result += "Address & Pincode\n";
    if (profile.city == null && drive.requirements["city"]) result += "City\n";
    if (profile.state == null && drive.requirements["state"])
      result += "State\n";

    return result;
  }

  void _confirm(Drive drive, Profile profile) {
    if (profile != null) {
      String eval = detailsCheck(drive, profile);
      if (eval.length > 1) {
        showDialog(
          context: context,
          builder: (ctx) => SimpleDialog(
            title: Text(
              "You are missing some mandatory fields",
              style: Theme.of(context).textTheme.headline3,
              textAlign: TextAlign.left,
            ),
            children: [
              Text(
                "Add these details to your profile to register for this placement drive",
                textAlign: TextAlign.center,
              ),
              Text(
                eval,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ],
          ),
        );
        return;
      }
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(
            "Register for ${drive.companyName}?",
            style: Theme.of(context).textTheme.headline3,
            textAlign: TextAlign.left,
          ),
          content: drive.category == profile.placedCategory
              ? Text(
                  "You already have an offer in a ${drive.category} company.\nConsult with your TPO before proceeding",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.orange[400],
                  ),
                )
              : null,
          actions: [NoButton(ctx), YesButton(ctx)],
        ),
      ).then((res) {
        if (res) {
          Provider.of<User>(context, listen: false)
              .newRegistration(profile, drive)
              .then((_) {
            Scaffold.of(context).showSnackBar(
              SnackBar(
                content: Text("Registration Done"),
              ),
            );
          }).catchError((e) {
            Scaffold.of(context).showSnackBar(
              SnackBar(
                content: Text("Registration Failed"),
              ),
            );
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool eligible = false;
    if (widget.profile != null)
      eligible = ifEligible(widget.drive, widget.profile);
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: GestureDetector(
        onTap: () {
          widget.profile == null
              ? Navigator.of(context).pushNamed(
                  DriveDetailsScreen.routeName,
                  arguments: widget.drive.id,
                )
              : setState(() {
                  _expanded = !_expanded;
                });
        },
        child: Card(
          elevation: 8,
          color: Colors.orange[300],
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                child: ListTile(
                  title: Container(
                    width: 150,
                    padding: EdgeInsets.all(5),
                    child: Text(
                      widget.drive.companyName,
                      style: Theme.of(context).textTheme.headline3,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  leading: Container(
                    height: 80,
                    width: 80,
                    child: Image.network(
                      widget.drive.companyImageUrl,
                      errorBuilder: (context, error, stackTrace) =>
                          ImageError(),
                    ),
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 60,
                        child: Text(
                          widget.drive.category,
                          style: TextStyle(
                            fontFamily: 'Ubuntu',
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      if (widget.profile != null)
                        CriteriaButton(
                          drive: widget.drive,
                          profile: widget.profile,
                          eligibility: eligible,
                        )
                    ],
                  ),
                ),
              ),
              if (!_expanded)
                Text(
                  "Click to know more",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              if (_expanded)
                Container(
                  child: Column(
                    children: [
                      TwoValues(
                        label1: "Expected by",
                        value1: formatter
                            .format(DateTime.parse(widget.drive.expectedDate)),
                        label2: "CTC",
                        value2: widget.drive.ctc.toString() + " lpa",
                      ),
                      OneValue(
                        label: "Job Description",
                        value: (widget.drive.jobDesc == "" ||
                                widget.drive.jobDesc == null)
                            ? "Not Available"
                            : widget.drive.jobDesc,
                      ),
                      OneValue(
                        label: "Location",
                        value: (widget.drive.location == "" ||
                                widget.drive.location == null)
                            ? "Not Available"
                            : widget.drive.location,
                      ),
                      if (widget.drive.externalLink != null &&
                          widget.drive.externalLink != "" &&
                          eligible)
                        Text(
                          "REGISTER HERE FIRST!!",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      if (widget.drive.externalLink != null &&
                          widget.drive.externalLink != "" &&
                          eligible)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: RichText(
                            text: TextSpan(children: [
                              TextSpan(
                                  text: widget.drive.externalLink,
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    color: Colors.blue[900],
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () async {
                                      if (await canLaunch(
                                          widget.drive.externalLink)) {
                                        await launch(widget.drive.externalLink);
                                      }
                                    })
                            ]),
                          ),
                        ),
                      if (eligible &&
                          widget.profile != null &&
                          DateTime.parse(widget.drive.regDeadline)
                              .isAfter(DateTime.now()))
                        RaisedButton(
                          onPressed: () {
                            _confirm(widget.drive, widget.profile);
                          },
                          color: Colors.indigo[400],
                          child: Text(
                            "Register Now",
                            style: Theme.of(context).textTheme.button,
                          ),
                        )
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
