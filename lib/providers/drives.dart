import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:placementhq/models/drive.dart';
import 'package:http/http.dart' as http;
import 'package:placementhq/models/notice.dart';
import 'package:placementhq/models/offer.dart';
import 'package:placementhq/models/registration.dart';
import 'package:placementhq/providers/companies.dart';

class Drives with ChangeNotifier {
  List<Drive> _drives = [];
  String token;
  String _collegeId;
  List<Registration> _registrations = [];
  List<Notice> _notices = [];
  List<Offer> _offers = [];

  Drives();

  void update(token, collegeId) {
    this.token = token;
    this._collegeId = collegeId;
  }

  List<Drive> get drives {
    return [..._drives];
  }

  List<Registration> get registrations {
    return [..._registrations];
  }

  List<Notice> get notices {
    return [..._notices];
  }

  List<Offer> get offers {
    return [..._offers];
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
            batch: drive["batch"],
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
      //Check that company does not have an existing active drive in college
      if (company != null) {
        final urlDrive =
            'https://placementhq-777.firebaseio.com/collegeData/$collegeId/drives.json?orderBy="companyId"&equalTo="${company.id}"&auth=$token';
        final resDrive = await http.get(urlDrive);
        final objDrive = json.decode(resDrive.body) as Map<String, dynamic>;
        if (objDrive.isNotEmpty &&
            objDrive.values.toList()[0]["companyId"] == company.id) {
          throw HttpException("Company already exists");
        }
      }

      if (image != null) {
        //Add image to storage
        final ref = FirebaseStorage.instance
            .ref()
            .child('company_logos')
            .child(driveData["companyName"] + ".jpeg");
        await ref.putFile(image).onComplete;

        final imageUrl = await ref.getDownloadURL();
        driveData["companyImageUrl"] = imageUrl;
      }

      if (company == null) {
        final urlComp =
            "https://placementhq-777.firebaseio.com/companies.json?auth=$token";

        final res = await http.post(urlComp,
            body: json.encode({
              "name": driveData["companyName"],
              "imageUrl": driveData["companyImageUrl"],
            }));
        final companyData = json.decode(res.body);
        driveData["companyId"] = companyData["name"];
      }

      //Update or Create College historical data about company
      if (company != null) {
        final urlRecord =
            "https://placementhq-777.firebaseio.com/collegeData/$collegeId/companies/${company.id}.json?auth=$token";
        http.patch(
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
        http.patch(
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
      final res = await http.post(url, body: json.encode(driveData));
      final result = json.decode(res.body);

      final newDrive = new Drive(
        id: result["name"],
        batch: result["batch"],
        companyId: driveData["companyId"],
        companyName: driveData["companyName"],
        companyMessage: driveData["companyMessage"],
        companyImageUrl: driveData["companyImageUrl"],
        expectedDate: driveData["expectedDate"],
        regDeadline: driveData["regDeadline"],
        externalLink: driveData["externalLink"],
        category: driveData["category"],
        ctc: driveData["ctc"],
        jobDesc: driveData["jobDesc"],
        minSecMarks: driveData["minSecMarks"] is int
            ? driveData["minSecMarks"].toDouble()
            : driveData["minSecMarks"],
        minHighSecMarks: driveData["minHighSecMarks"] is int
            ? driveData["minHighSecMarks"].toDouble()
            : driveData["minHighSecMarks"],
        minDiplomaMarks: driveData["minDiplomaMarks"] is int
            ? driveData["minDiplomaMarks"].toDouble()
            : driveData["minDiplomaMarks"],
        minBEMarks: driveData["minBEMarks"] is int
            ? driveData["minBEMarks"].toDouble()
            : driveData["minBEMarks"],
        minCGPA: driveData["minCGPA"] is int
            ? driveData["minCGPA"].toDouble()
            : driveData["minCGPA"],
        maxGapYears: driveData["maxGapYears"],
        maxKTs: driveData["maxKTs"],
        location: driveData["location"],
        requirements: driveData["requirements"],
      );
      _drives.add(newDrive);
      notifyListeners();
    }
  }

  Future<void> closeDrive(String driveId, String batch) async {
    await getDriveRegistrations(driveId);
    await getDriveNotices(driveId);
    await getDriveOffers(driveId, batch);

    _registrations.forEach((reg) async {
      var url =
          "https://placementhq-777.firebaseio.com/collegeData/$_collegeId/registrations/${reg.id}.json?auth=$token";
      await http.delete(url);
    });

    _notices.forEach((notice) async {
      var url2 =
          "https://placementhq-777.firebaseio.com/collegeData/$_collegeId/notices/${notice.id}.json?auth=$token";
      await http.delete(url2);
      if (notice.fileName != null && notice.fileName != "") {
        final ref = FirebaseStorage.instance
            .ref()
            .child('notice_documents')
            .child(notice.fileName);
        await ref.delete();
      }
    });

    Drive currentDrive = _drives.firstWhere((e) => e.id == driveId);
    final companyUrl =
        "https://placementhq-777.firebaseio.com/collegeData/$_collegeId/companies/${currentDrive.companyId}.json?auth=$token";
    final companyData = await http.get(companyUrl);
    final company = json.decode(companyData.body);
    final int numOfStudents = company["numOfStudents"] == null
        ? 0
        : company["numOfStudents"] is int
            ? company["numOfStudents"]
            : int.parse(company["numOfStudents"]);
    await http.patch(
      companyUrl,
      body: json.encode({
        "numOfStudents": numOfStudents + currentDrive.placed,
      }),
    );

    final chats = Firestore.instance.document("chats/$driveId");
    chats.delete().catchError((e) => print(e));

    final url =
        "https://placementhq-777.firebaseio.com/collegeData/$_collegeId/drives/$driveId.json?auth=$token";
    await http.delete(url);

    _offers.forEach((offer) async {
      var url3 =
          "https://placementhq-777.firebaseio.com/collegeData/$_collegeId/offers/$batch/${offer.id}.json?auth=$token";

      if (offer.accepted == null) {
        await http.patch(url3, body: json.encode({"accepted": false}));
      }
    });
    _drives.removeWhere((drive) => drive.id == driveId);
    notifyListeners();
  }

  Future<String> getDriveRegistrations(String driveId) async {
    final urlReg =
        'https://placementhq-777.firebaseio.com/collegeData/$_collegeId/registrations.json?orderBy="driveId"&equalTo="$driveId"&auth=$token';
    final res = await http.get(urlReg);
    final registrations = json.decode(res.body) as Map<String, dynamic>;
    List<Registration> newReg = [];
    int count = 0;
    int count2 = 0;
    registrations.forEach((key, reg) {
      count++;
      if (reg["selected"] == true) {
        count2++;
      }
      newReg.add(Registration(
        id: key,
        company: reg["company"],
        candidate: reg["candidate"],
        department: reg["department"],
        companyImageUrl: reg["companyImageUrl"],
        companyId: reg["companyId"],
        userId: reg["userId"],
        driveId: reg["driveId"],
        rollNo: reg["rollNo"] == null ? "" : reg["rollNo"],
        registeredOn: reg["registeredOn"],
        selected: reg["selected"] == null ? false : reg["selected"],
      ));
    });
    _registrations = newReg;
    Drive currentDrive = _drives.firstWhere((e) => e.id == driveId);
    currentDrive.registered = count;
    currentDrive.placed = count2;
    notifyListeners();
    return _collegeId;
  }

  Future<void> removeRegistrations(List<String> ids) async {
    ids.forEach((id) async {
      var url =
          "https://placementhq-777.firebaseio.com/collegeData/$_collegeId/registrations/$id.json?auth=$token";
      await http.delete(url);
    });
    _registrations.removeWhere((reg) => ids.contains(reg.id));
    notifyListeners();
  }

  void addNotice(Notice notice) {
    if (notice != null) _notices.insert(0, notice);
  }

  Future<void> getDriveNotices(String driveId) async {
    final url =
        'https://placementhq-777.firebaseio.com/collegeData/$_collegeId/notices.json?orderBy="driveId"&equalTo="$driveId"&auth=$token';
    final res = await http.get(url);
    final notices = json.decode(res.body) as Map<String, dynamic>;
    List<Notice> newNotices = [];
    if (notices != null)
      notices.forEach((key, notice) {
        newNotices.add(Notice(
          id: key,
          companyName: notice["companyName"],
          notice: notice["notice"],
          url: notice["url"],
          driveId: notice["driveId"],
          issuedBy: notice["issuedBy"],
          issuerId: notice["issuerId"],
          issuedOn: notice["issuedOn"],
          fileUrl: notice["fileUrl"],
          fileName: notice["fileName"],
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
    if (notices != null)
      notices.forEach((key, notice) {
        newNotices.add(Notice(
          id: key,
          companyName: notice["companyName"],
          notice: notice["notice"],
          url: notice["url"],
          driveId: notice["driveId"],
          issuedBy: notice["issuedBy"],
          issuerId: notice["issuerId"],
          issuedOn: notice["issuedOn"],
          fileUrl: notice["fileUrl"],
          fileName: notice["fileName"],
        ));
      });
    newNotices.sort((a, b) => b.issuedOn.compareTo(a.issuedOn));
    _notices = newNotices;
    notifyListeners();
  }

  Future<void> deleteNotice(String id, String fileName) async {
    var url =
        "https://placementhq-777.firebaseio.com/collegeData/$_collegeId/notices/$id.json?auth=$token";
    await http.delete(url);
    if (fileName != null && fileName != "") {
      final ref = FirebaseStorage.instance
          .ref()
          .child('notice_documents')
          .child(fileName);
      await ref.delete();
    }
    _notices.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  Future<void> getDriveOffers(String driveId, String batch) async {
    final url =
        'https://placementhq-777.firebaseio.com/collegeData/$_collegeId/offers/$batch.json?orderBy="driveId"&equalTo="$driveId"&auth=$token';
    final res = await http.get(url);
    final offers = json.decode(res.body) as Map<String, dynamic>;
    List<Offer> newOffers = [];
    offers.forEach((key, offer) {
      newOffers.add(Offer(
        id: key,
        userId: offer["userId"],
        candidate: offer["candidate"],
        driveId: offer["driveId"],
        rollNo: offer["rollNo"],
        department: offer["department"],
        companyId: offer["companyId"],
        companyName: offer["companyName"],
        companyImageUrl: offer["companyImageUrl"],
        ctc: offer["ctc"],
        selectedOn: offer["selectedOn"],
        accepted: offer["accepted"],
        category: offer["category"],
      ));
    });
    // newOffers.sort((a, b) => b.issuedOn.compareTo(a.issuedOn));
    _offers = newOffers;
    notifyListeners();
  }

  Future<void> confirmSelection(Registration reg) async {
    final url =
        "https://placementhq-777.firebaseio.com/collegeData/$_collegeId/registrations/${reg.id}.json?auth=$token";
    await http.patch(url, body: json.encode({"selected": true}));

    final urlDrive =
        "https://placementhq-777.firebaseio.com/collegeData/$_collegeId/drives/${reg.driveId}.json?auth=$token";
    final res = await http.get(urlDrive);
    final driveData = json.decode(res.body);
    final int placed = driveData["placed"] == null ? 0 : driveData["placed"];
    await http.patch(
      urlDrive,
      body: json.encode({
        "placed": placed + 1,
      }),
    );

    final urlOffer =
        "https://placementhq-777.firebaseio.com/collegeData/$_collegeId/offers/${driveData["batch"]}.json?auth=$token";
    await http.post(
      urlOffer,
      body: json.encode({
        "userId": reg.userId,
        "candidate": reg.candidate,
        "rollNo": reg.rollNo,
        "driveId": reg.driveId,
        "companyId": reg.companyId,
        "companyName": reg.company,
        "companyImageUrl": reg.companyImageUrl,
        "selectedOn": DateTime.now().toIso8601String(),
        "ctc": driveData["ctc"],
        "category": driveData["category"],
        "specialization": reg.department,
      }),
    );

    final student = _registrations.firstWhere((r) => r.id == reg.id);
    student.selected = true;
    notifyListeners();
  }
}
