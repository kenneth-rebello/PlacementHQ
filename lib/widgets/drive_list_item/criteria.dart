import 'package:flutter/material.dart';
import 'package:placementhq/models/drive.dart';
import 'package:placementhq/models/user_profile.dart';
import 'package:placementhq/widgets/drive_list_item/one_value.dart';

class CriteriaButton extends StatelessWidget {
  final bool eligibility;
  final Drive drive;
  final Profile profile;

  CriteriaButton({this.eligibility, this.drive, this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      child: RaisedButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (ctx) => SimpleDialog(
              title: Text(
                "Eligibility Criteria",
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
              children: [
                OneValue(
                  padding: 3,
                  label: "Minimum Xth %",
                  value: drive.minSecMarks.toStringAsFixed(1),
                ),
                OneValue(
                  padding: 3,
                  label: "Your Xth %",
                  value: profile.secMarks.toStringAsFixed(1),
                ),
                SizedBox(
                  height: 10,
                ),
                OneValue(
                  padding: 3,
                  label: "Minimum XIIth %",
                  value: drive.minHighSecMarks.toStringAsFixed(1),
                ),
                OneValue(
                  padding: 3,
                  label: "Your XIIth %",
                  value: profile.highSecMarks.toStringAsFixed(1),
                ),
                SizedBox(
                  height: 10,
                ),
                OneValue(
                  padding: 3,
                  label: "Minimum Diploma %",
                  value: drive.minDiplomaMarks.toStringAsFixed(1),
                ),
                OneValue(
                  padding: 3,
                  label: "Your Diploma %",
                  value: profile.diplomaMarks.toStringAsFixed(1),
                ),
                SizedBox(
                  height: 10,
                ),
                OneValue(
                  padding: 3,
                  label: "Minimum CGPA",
                  value: drive.minCGPA.toStringAsFixed(1),
                ),
                OneValue(
                  padding: 3,
                  label: "Your CGPA",
                  value: profile.cgpa.toStringAsFixed(1),
                ),
                SizedBox(
                  height: 10,
                ),
                OneValue(
                  padding: 3,
                  label: "Maximum no. of *live* KTs allowed",
                  value: drive.maxKTs.toString(),
                ),
                OneValue(
                  padding: 3,
                  label: "Your no. *live* KTs",
                  value: profile.numOfKTs.toString(),
                ),
                SizedBox(
                  height: 10,
                ),
                OneValue(
                  padding: 3,
                  label: "Maximum no. of gap years allowed",
                  value: drive.maxGapYears.toString(),
                ),
                OneValue(
                  padding: 3,
                  label: "Your no. of gap years",
                  value: profile.numOfGapYears.toString(),
                ),
              ],
            ),
          );
        },
        color: eligibility ? Colors.green[800] : Colors.red[800],
        child: Text(
          eligibility ? "Eligible" : "Ineligible",
          style: TextStyle(
            color: Colors.white,
            decoration: TextDecoration.underline,
          ),
        ),
        padding: EdgeInsets.all(2),
      ),
    );
  }
}
