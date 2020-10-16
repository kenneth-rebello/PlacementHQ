import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:placementshq/models/drive.dart';
import 'package:http/http.dart' as http;
import 'package:placementshq/models/registration.dart';
import 'package:placementshq/providers/companies.dart';
import 'package:placementshq/models/user_profile.dart';

class Drives with ChangeNotifier {
  List<Drive> _drives = [];
  String token;
  String _collegeId;

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
            regDeadline: drive["regDeadline"],
            externalLink: drive["externalLink"],
            category: drive["category"],
            ctc: drive["ctc"],
            jobDesc: drive["jobDesc"],
            minSecMarks: drive["minSecMarks"] is int
                ? drive["minSecMarks"].toDouble()
                : drive["minSecMarks"],
            minHighSecMarks: drive["minHighSecMarks"] is int
                ? drive["minHighSecMarks"].toDouble()
                : drive["minHighSecMarks"],
            minDiplomaMarks: drive["minDiplomaMarks"] is int
                ? drive["minDiplomaMarks"].toDouble()
                : drive["minDiplomaMarks"],
            minBEMarks: drive["minBEMarks"] is int
                ? drive["minBEMarks"].toDouble()
                : drive["minBEMarks"],
            minCGPA: drive["minCGPA"] is int
                ? drive["minCGPA"].toDouble()
                : drive["minCGPA"],
            maxGapYears: drive["maxGapYears"],
            maxKTs: drive["maxKTs"],
            location: drive["location"],
            requirements: drive["requirements"],
            registered: [],
          ));
        });
      }
      _drives = newDrives;
      _collegeId = collegeId;
      notifyListeners();
    }
  }

  Future<void> createNewDrive(
      Map<String, dynamic> driveData, String collegeId, Company company) async {
    final year = DateTime.now().year;
    if (collegeId != null && collegeId != "") {
      //Add Company to PlacementHQ database
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

      //Update or Create College historical data about company
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
          "https://placementhq-777.firebaseio.com/collegeData/$collegeId/drives.json?auth=$token";
      await http.post(url, body: json.encode(driveData));
    }
  }

  Future<Registration> newRegistration(Profile user, Drive drive) async {
    final url =
        "https://placementhq-777.firebaseio.com/collegeData/$_collegeId/registrations.json?auth=$token";
    await http.post(
      url,
      body: json.encode({
        "userId": user.id,
        "driveId": drive.id,
        "candidate": user.fullNameWMid,
        "company": drive.companyName,
        "companyImageUrl": drive.companyImageUrl,
        "registeredOn": DateTime.now().toIso8601String(),
      }),
    );

    return Registration(
      candidate: user.fullNameWMid,
      company: drive.companyName,
      companyImageUrl: drive.companyImageUrl,
      userId: user.id,
      driveId: drive.id,
    );
  }

  Future<void> getDriveRegistrations(String driveId) async {
    final urlReg =
        'https://placementhq-777.firebaseio.com/collegeData/${_collegeId}/registrations.json?orderBy="driveId"&equalTo="$driveId"&auth=$token';
    final res = await http.get(urlReg);
    final registrations = json.decode(res.body);
  }
}
