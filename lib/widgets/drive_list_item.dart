import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:placementshq/models/drive.dart';
import 'package:placementshq/providers/user.dart';
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
    if (drive.minCGPI > profile.cgpi) return false;
    if (profile.numOfGapYears > drive.maxGapYears) return false;
    if (profile.numOfKTs > drive.maxKTs) return false;
    return true;
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
                    ),
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 50,
                        child: Text(
                          widget.drive.category,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      eligible
                          ? Container(
                              color: Colors.green[800],
                              padding: EdgeInsets.all(5),
                              margin: EdgeInsets.all(5),
                              child: Text(
                                "Eligible",
                                style: TextStyle(color: Colors.white),
                              ))
                          : Container(
                              color: Colors.red[800],
                              padding: EdgeInsets.all(5),
                              margin: EdgeInsets.all(5),
                              child: Text(
                                "Ineligible",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
              if (_expanded)
                Container(
                  child: Column(
                    children: [
                      TwoValues(
                        label1: "Expected by: ",
                        value1: formatter
                            .format(DateTime.parse(widget.drive.expectedDate)),
                        label2: "CTC: ",
                        value2: widget.drive.ctc.toString() + " lpa",
                      ),
                      OneValue(
                        label: "Job Description: ",
                        value: (widget.drive.jobDesc == "" ||
                                widget.drive.jobDesc == null)
                            ? "Not Available"
                            : widget.drive.jobDesc,
                      ),
                      OneValue(
                        label: "Location: ",
                        value: widget.drive.location,
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
                          onPressed: () {},
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

class TwoValues extends StatelessWidget {
  final String label1;
  final String label2;
  final String value1;
  final String value2;

  TwoValues({this.label1, this.label2, this.value1, this.value2});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black),
              children: <TextSpan>[
                TextSpan(
                  text: label1,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: value1),
              ],
            ),
          ),
          RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black),
              children: <TextSpan>[
                TextSpan(
                  text: label2,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: value2,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class OneValue extends StatelessWidget {
  final String label;
  final String value;

  OneValue({this.label, this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black),
              children: <TextSpan>[
                TextSpan(
                  text: label,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
