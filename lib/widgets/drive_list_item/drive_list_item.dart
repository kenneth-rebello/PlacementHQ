import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:placementshq/models/drive.dart';
import 'package:placementshq/providers/drives.dart';
import 'package:placementshq/providers/user.dart';
import 'package:placementshq/models/user_profile.dart';
import 'package:placementshq/widgets/drive_list_item/criteria.dart';
import 'package:placementshq/widgets/drive_list_item/one_value.dart';
import 'package:placementshq/widgets/drive_list_item/two_values.dart';
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
    if (drive.minCGPA > profile.cgpa) return false;
    if (profile.numOfGapYears > drive.maxGapYears) return false;
    if (profile.numOfKTs > drive.maxKTs) return false;
    return true;
  }

  String detailsCheck(Drive drive, Profile profile) {
    String result = "";
    if (profile.nationality == null && drive.requirements["nationality"])
      result += "Nationality\n";
    if (profile.dateOfBirth == null && drive.requirements["age"])
      result += "Date of Birth\n";
    if (profile.gender == null && drive.requirements["gender"])
      result += "Gender";
    if (profile.address == null &&
        profile.pincode == null &&
        drive.requirements["address"]) result += "Address & Pincode";
    if (profile.city == null && drive.requirements["city"]) result += "City";
    if (profile.state == null && drive.requirements["state"]) result += "State";
    return result;
  }

  void _confirm(Drive drive, Profile profile) {
    String eval = detailsCheck(drive, profile);
    if (eval.length > 1) {
      showDialog(
        context: context,
        builder: (ctx) => SimpleDialog(
          title: Text(
            "You are missing some mandatory fields",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.indigo[800],
              fontWeight: FontWeight.bold,
            ),
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
        title: Text("Register for ${drive.companyName}?"),
        actions: [
          FlatButton(
            onPressed: () {
              Navigator.of(ctx).pop(false);
            },
            child: Text(
              "No",
              style: TextStyle(color: Colors.red),
            ),
          ),
          FlatButton(
            onPressed: () {
              Navigator.of(ctx).pop(true);
            },
            child: Text(
              "Yes",
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ),
        ],
      ),
    ).then((res) {
      if (res) {
        Provider.of<Drives>(context, listen: false)
            .newRegistration(profile, drive)
            .then((newRegistration) {
          Provider.of<User>(context, listen: false)
              .addNewRegistration(newRegistration);
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text("Registration Done"),
            ),
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool eligible = ifEligible(widget.drive, widget.profile);
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _expanded = !_expanded;
          });
          // Provider.of<Drives>(context, listen: false)
          //     .getDriveRegistrations(widget.drive.id);
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
                      errorBuilder: (context, error, stackTrace) => Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red,
                          ),
                          Text(
                            "No Image",
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
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
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                      ),
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
                      if (eligible)
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
