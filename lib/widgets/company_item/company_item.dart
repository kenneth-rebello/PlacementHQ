import 'package:flutter/material.dart';
import 'package:placementhq/providers/companies.dart';
import 'package:placementhq/screens/past_data_screens/company_history.dart';
import 'package:placementhq/widgets/drive_list_item/two_values.dart';

class CompanyItem extends StatelessWidget {
  final Company company;

  CompanyItem(this.company);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (ctx) => CompanyHistory(company)));
      },
      child: Card(
        margin: EdgeInsets.all(10),
        elevation: 3,
        shadowColor: Colors.indigo[100],
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          child: Column(
            children: [
              Text(
                company.name,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontFamily: "Ubuntu",
                  fontSize: 19,
                ),
              ),
              Divider(),
              TwoValues(
                label1: "Highest",
                value1: company.highestPackage.toString() + " lpa",
                label2: "Lowest",
                value2: company.lowestPackage.toString() + " lpa",
              ),
              TwoValues(
                label1: "No. of offers",
                value1: company.numOfStudents.toString(),
                label2: "Last Visited",
                value2: company.lastVisitedYear.toString(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
