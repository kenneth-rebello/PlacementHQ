import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:placementshq/models/drive.dart';
import 'package:http/http.dart' as http;
import 'package:placementshq/providers/companies.dart';

class Drives with ChangeNotifier {
  List<Drive> _drives = [];
  String token;

  Drives(this.token);

  List<Drive> get drives {
    return [..._drives];
  }

  Future<void> loadDrives(String collegeId) async {
    if (collegeId != null && collegeId != "") {
      final url =
          "https://placementhq-777.firebaseio.com/collegeData/${collegeId}/drives.json?auth=$token";
      final res = await http.get(url);
      final drives = json.decode(res.body) as Map<String, dynamic>;
      List<Drive> newDrives = [];
      if (drives != null) {
        drives.forEach((key, drive) {
          newDrives.add(Drive(
            id: key,
            companyId: drive["companyId"],
            companyName: drive["companyName"],
            companyMessage: drive["companyMessage"],
            companyImageUrl: drive["companyImageUrl"],
            expectedDate: drive["expectedDate"],
            externalLink: drive["externalLink"],
            category: drive["category"],
            ctc: drive["ctc"],
            jobDesc: drive["jobDesc"],
            minCGPI: drive["minCGPI"],
            maxGapYears: drive["maxGapYears"],
            maxKTs: drive["maxKTs"],
            location: drive["location"],
          ));
        });
      }
      _drives = newDrives;
      notifyListeners();
    }
  }

  Future<void> createNewDrive(
      Map<String, dynamic> driveData, String collegeId, Company company) async {
    final year = DateTime.now().year;
    if (collegeId != null && collegeId != "") {
      if (company == null) {
        final urlComp =
            "https://placementhq-777.firebaseio.com/companies.json?auth=$token";

        final res = await http.post(urlComp,
            body: json.encode({
              "name": driveData["companyName"],
              "imageUrl": driveData["companyImageUrl"],
            }));
        final drive = json.decode(res.body);
        driveData["companyId"] = drive["name"];
      }

      //Update college historical data about company
      if (company != null) {
        final urlRecord =
            "https://placementhq-777.firebaseio.com/collegeData/${collegeId}/companies/${company.id}.json?auth=$token";
        await http.patch(
          urlRecord,
          body: json.encode({
            "lowestPackage": company.lowestPackage > driveData["ctc"]
                ? driveData["ctc"]
                : company.lowestPackage,
            "highestPackage": company.highestPackage < driveData["ctc"]
                ? driveData["ctc"]
                : company.highestPackage,
            "lastVisitedYear": year,
          }),
        );
      } else {
        final urlRecord =
            "https://placementhq-777.firebaseio.com/collegeData/${collegeId}/companies/${driveData["companyId"]}.json?auth=$token";
        await http.patch(
          urlRecord,
          body: json.encode({
            "name": driveData["companyName"],
            "imageUrl": driveData["companyImageUrl"],
            "lowestPackage": driveData["ctc"],
            "highestPackage": driveData["ctc"],
            "lastVisitedYear": year,
          }),
        );
      }

      final url =
          "https://placementhq-777.firebaseio.com/collegeData/${collegeId}/drives.json?auth=$token";
      await http.post(url, body: json.encode(driveData));
    }
  }
}
