import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:placementhq/models/registration.dart';
import 'package:placementhq/screens/drive_screens/drive_details.dart';

class RegistrationItem extends StatelessWidget {
  final Registration registration;

  RegistrationItem(this.registration);

  DateFormat formatter = new DateFormat("dd-MM-yy");

  @override
  Widget build(BuildContext context) {
    String registeredOn =
        formatter.format(DateTime.parse(registration.registeredOn));
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(
          DriveDetailsScreen.routeName,
          arguments: registration.driveId,
        );
      },
      child: Card(
        color: Colors.indigo[100],
        margin: EdgeInsets.symmetric(vertical: 5),
        child: ListTile(
          leading: Container(
            height: 80,
            width: 80,
            child: Image.network(
              registration.companyImageUrl,
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
          title: Text(
            registration.company,
            style: Theme.of(context).textTheme.headline3,
            textAlign: TextAlign.center,
          ),
          subtitle: Text(
            "Registered on: " + registeredOn,
            style: Theme.of(context).textTheme.bodyText1,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
