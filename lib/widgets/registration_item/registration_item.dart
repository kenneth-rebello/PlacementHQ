import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:placementshq/models/registration.dart';

class RegistrationItem extends StatelessWidget {
  final Registration registration;

  RegistrationItem(this.registration);

  DateFormat formatter = new DateFormat("dd-MM-yy");

  @override
  Widget build(BuildContext context) {
    String registeredOn =
        formatter.format(DateTime.parse(registration.registeredOn));
    return InkWell(
      onTap: () {},
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
            style: TextStyle(color: Colors.black),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
