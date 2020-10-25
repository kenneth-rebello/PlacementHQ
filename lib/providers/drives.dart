import 'dart:convert';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:placementhq/models/drive.dart';
import 'package:http/http.dart' as http;
import 'package:placementhq/models/notice.dart';
import 'package:placementhq/models/registration.dart';
import 'package:placementhq/providers/companies.dart';

class Drives with ChangeNotifier {
  List<Drive> _drives = [];
  String token;
  String _collegeId;
  List<Registration> _registrations = [];
  List<Notice> _notices = [];

  Drives(this.token);

  List<Drive> get drives {
    return [..._drives];
  }

  List<Registration> get registrations {
    return [..._registrations];
  }

  List<Notice> get notices {
    return [..._notices];
  }

  Drive getById(String id) {
    return _drives.firstWhere((drive) => drive.id == id, orElse: () => null);
  }

  Future<void> loadDrives(String collegeId) async {
    if (collegeId != null && collegeId != "") {
      final url =
          "https://placementhq-777.firebaseio.com/collegeData/$collegeId/drives.json?auth=$token";
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
    Map<String, dynamic> driveData,
    String collegeId,
    Company company,
    File image,
  ) async {
    final year = DateTime.now().year;
    if (collegeId != null && collegeId != "") {
      //Add image to storage
      final ref = FirebaseStorage.instance
          .ref()
          .child('company_logos')
          .child(driveData["companyName"] + ".jpeg");
      await ref.putFile(image).onComplete;

      final imageUrl = await ref.getDownloadURL();
      driveData["companyImageUrl"] = imageUrl;

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
            "https://placementhq-777.firebaseio.com/collegeData/$collegeId/companies/${company.id}.json?auth=$token";
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
            "https://placementhq-777.firebaseio.com/collegeData/$collegeId/companies/${driveData["companyId"]}.json?auth=$token";
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

  Future<String> getDriveRegistrations(String driveId) async {
    final urlReg =
        'https://placementhq-777.firebaseio.com/collegeData/$_collegeId/registrations.json?orderBy="driveId"&equalTo="$driveId"&auth=$token';
    final res = await http.get(urlReg);
    final registrations = json.decode(res.body) as Map<String, dynamic>;
    List<Registration> newReg = [];
    registrations.forEach((key, reg) {
      newReg.add(Registration(
        id: key,
        company: reg["company"],
        candidate: reg["candidate"],
        companyImageUrl: reg["companyImageUrl"],
        userId: reg["userId"],
        driveId: reg["driveId"],
        rollNo: reg["rollNo"] == null ? "" : reg["rollNo"],
        registeredOn: reg["registeredOn"],
        selected: reg["selected"] == null ? false : reg["selected"],
      ));
    });
    _registrations = newReg;
    notifyListeners();
    return _collegeId;
  }

  Future<void> getDriveNotices(String driveId) async {
    final url =
        'https://placementhq-777.firebaseio.com/collegeData/$_collegeId/notices.json?orderBy="driveId"&equalTo="$driveId"&auth=$token';
    final res = await http.get(url);
    final notices = json.decode(res.body) as Map<String, dynamic>;

    List<Notice> newNotices = [];
    notices.forEach((key, notice) {
      newNotices.add(Notice(
        id: key,
        companyName: notice["companyName"],
        notice: notice["notice"],
        driveId: notice["driveId"],
        issuedBy: notice["issuedBy"],
        issuerId: notice["issuerId"],
        issuedOn: notice["issuedOn"],
      ));
    });
    newNotices.sort((a, b) => b.issuedOn.compareTo(a.issuedOn));
    _notices = newNotices;
    notifyListeners();
  }

  Future<void> getAllNotices(String collegeId) async {
    final url =
        'https://placementhq-777.firebaseio.com/collegeData/$collegeId/notices.json?auth=$token';
    final res = await http.get(url);
    final notices = json.decode(res.body) as Map<String, dynamic>;
    List<Notice> newNotices = [];
    notices.forEach((key, notice) {
      newNotices.add(Notice(
        id: key,
        companyName: notice["companyName"],
        notice: notice["notice"],
        driveId: notice["driveId"],
        issuedBy: notice["issuedBy"],
        issuerId: notice["issuerId"],
        issuedOn: notice["issuedOn"],
      ));
    });
    newNotices.sort((a, b) => b.issuedOn.compareTo(a.issuedOn));
    _notices = newNotices;
    notifyListeners();
  }

  Future<void> confirmSelection(Registration reg) async {
    final url =
        "https://placementhq-777.firebaseio.com/collegeData/$_collegeId/registrations/${reg.id}.json?auth=$token";
    await http.patch(url, body: json.encode({"selected": true}));
    final student = _registrations.firstWhere((r) => r.id == reg.id);
    student.selected = true;
    notifyListeners();
  }
}
