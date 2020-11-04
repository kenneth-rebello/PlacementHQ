import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:placementhq/models/notice.dart';
import 'package:placementhq/models/user_profile.dart';

class OfficerProfile {
  String id;
  String fullName;
  String collegeName;
  String collegeId;
  String designation;
  int phone;
  String email;

  OfficerProfile({
    this.id,
    this.collegeName,
    this.collegeId,
    this.fullName,
    this.designation,
    this.phone,
    this.email,
  });
}

class Officer with ChangeNotifier {
  String token;
  String userId;
  String emailId;
  OfficerProfile _profile;
  List<Profile> _students = [];

  void update(token, userId, emailId) {
    this.token = token;
    this.userId = userId;
    this.emailId = emailId;
  }

  OfficerProfile get profile {
    OfficerProfile copy;
    if (_profile != null) {
      copy = new OfficerProfile();
      copy.id = _profile.id;
      copy.collegeName = _profile.collegeName;
      copy.collegeId = _profile.collegeId;
      copy.fullName = _profile.fullName;
      copy.designation = _profile.designation;
      copy.phone = _profile.phone;
      copy.email = _profile.email;
    } else {
      copy = null;
    }
    return copy;
  }

  List<Profile> get students {
    return [..._students];
  }

  String get collegeId {
    if (profile != null) {
      return profile.collegeId;
    }
    return null;
  }

  Future<void> loadCurrentOfficerProfile() async {
    if (userId == null || userId == "") {
      throw HttpException("Invalid Operation");
    }
    final url =
        "https://placementhq-777.firebaseio.com/officers/$userId.json?auth=$token";
    final res = await http.get(url);
    final profile = json.decode(res.body);
    if (profile != null) {
      _profile = new OfficerProfile(
        id: userId,
        collegeName: profile["collegeName"],
        collegeId: profile["collegeId"],
        fullName: profile["fullName"],
        designation: profile["designation"],
        phone: profile["phone"] == null || profile["phone"] == ""
            ? null
            : profile["phone"] is int
                ? profile["phone"]
                : int.parse(profile["phone"]),
        email: profile["email"],
      );
      notifyListeners();
    }
  }

  Future<void> applyForAccount(
      Map<String, dynamic> profileData, bool newCollege) async {
    if (newCollege) {
      final urlCollege =
          "https://placementhq-777.firebaseio.com/colleges.json?auth=$token";
      final resCollege = await http.post(
        urlCollege,
        body: json.encode({"name": profileData["collegeName"]}),
      );
      final college = json.decode(resCollege.body);
      profileData["collegeId"] = college["name"];
    }

    final url =
        "https://placementhq-777.firebaseio.com/officers/$userId.json?auth=$token";
    await http.patch(url, body: json.encode(profileData));
  }

  Future<void> loadStudents({String cId}) async {
    String colId = collegeId;
    if (cId != null && cId != "") {
      colId = cId;
    }
    final url =
        'https://placementhq-777.firebaseio.com/users.json?orderBy="collegeId"&equalTo="$colId"&auth=$token&print=pretty';
    final res = await http.get(url);
    final students = json.decode(res.body) as Map<String, dynamic>;
    List<Profile> newStudents = [];
    if (students != null) {
      students.forEach((key, student) {
        newStudents.add(Profile(
          id: key,
          isTPC: student["isTPC"] == null ? false : student["isTPC"],
          verified: student["verified"],
          firstName: student["firstName"],
          middleName: student["middleName"],
          lastName: student["lastName"],
          dateOfBirth: student["dateOfBirth"],
          gender: student["gender"],
          nationality: student["nationality"],
          imageUrl: student["imageUrl"],
          resumeUrl: student["resumeUrl"],
          collegeId: student["collegeId"],
          collegeName: student["collegeName"],
          specialization: student["specialization"],
          rollNo: student["rollNo"] == null ? "" : student["rollNo"],
          placedCategory: student["placedCategory"] == null
              ? "None"
              : student["placedCategory"],
          secMarks: student["secMarks"] == null
              ? null
              : student["secMarks"] is int
                  ? student["secMarks"].toDouble()
                  : student["secMarks"],
          highSecMarks: student["highSecMarks"] == null
              ? null
              : student["highSecMarks"] is int
                  ? student["highSecMarks"].toDouble()
                  : student["highSecMarks"],
          beMarks: student["beMarks"] == null
              ? null
              : student["beMarks"] is int
                  ? student["beMarks"].toDouble()
                  : student["beMarks"],
          diplomaMarks: student["diplomaMarks"] == null
              ? null
              : student["diplomaMarks"] is int
                  ? student["diplomaMarks"].toDouble()
                  : student["diplomaMarks"],
          hasDiploma:
              student["hasDiploma"] == null ? false : student["hasDiploma"],
          cgpa: student["cgpa"] == null
              ? null
              : student["cgpa"] is int
                  ? student["cgpa"].toDouble()
                  : student["cgpa"],
          numOfGapYears: student["numOfGapYears"],
          numOfKTs: student["numOfKTs"],
          phone: student["phone"],
          email: student["email"],
          address: student["address"],
          city: student["city"],
          state: student["state"],
          pincode: student["pincode"],
          offers: [],
        ));
      });
      _students = newStudents;
      notifyListeners();
    }
  }

  Profile getProfileById(String id) {
    return _students.firstWhere(
      (student) => student.id == id,
      orElse: () => null,
    );
  }

  Future<void> appointAsTPC(String id) async {
    if (id == null || id == "") {
      throw HttpException("Invalid Operation");
    }
    final url =
        "https://placementhq-777.firebaseio.com/users/$id.json?auth=$token";
    await http.patch(url, body: json.encode({"isTPC": true}));
    var student = _students.firstWhere((s) => s.id == id);
    student.isTPC = true;
    notifyListeners();
  }

  Future<void> dismissAsTPC(String id) async {
    if (id == null || id == "") {
      throw HttpException("Invalid Operation");
    }
    final url =
        "https://placementhq-777.firebaseio.com/users/$id.json?auth=$token";
    await http.patch(url, body: json.encode({"isTPC": false}));
    var student = _students.firstWhere((s) => s.id == id);
    student.isTPC = false;
    notifyListeners();
  }

  Future<Notice> addNewNotice(
      Map<String, dynamic> data, FilePickerResult file) async {
    if (collegeId == null || collegeId == "") {
      throw HttpException("Invalid Operation");
    }
    if (collegeId != null) {
      if (file != null) {
        File upload = File(file.files.single.path);
        final ref = FirebaseStorage.instance
            .ref()
            .child('notice_documents')
            .child(file.files.single.name);
        await ref.putFile(upload).onComplete;

        final downloadLink = await ref.getDownloadURL();
        data["fileUrl"] = downloadLink;
        data["fileName"] = file.files.single.name;
      }
      data["issuedBy"] = _profile.fullName;
      data["issuerId"] = _profile.id;
      final url =
          'https://placementhq-777.firebaseio.com/collegeData/$collegeId/notices.json?auth=$token';
      final res = await http.post(url, body: json.encode(data));
      final notice = json.decode(res.body) as Map<String, dynamic>;
      return Notice(
        id: notice["name"],
        driveId: data["driveId"],
        companyName: data["companyName"],
        notice: data["notice"],
        url: data["url"],
        issuedBy: data["issuedBy"],
        issuerId: data["issuerId"],
        issuedOn: data["issuedOn"],
        fileUrl: data["fileUrl"],
        fileName: data["fileName"],
      );
    }
    return null;
  }

  Future<void> editProfile(Map<String, dynamic> profileData) async {
    if (userId == null || userId == "") {
      throw HttpException("Invalid Operation");
    }
    final db =
        "https://placementhq-777.firebaseio.com/officers/$userId.json?auth=$token";

    await http.patch(
      db,
      body: json.encode(
        profileData,
      ),
    );

    if (profileData["email"] != null && profileData["email"] != "")
      _profile.email = profileData["email"];
    if (profileData["phone"] != null && profileData["phone"] != "") {
      _profile.phone = profileData["phone"] is int
          ? profileData["phone"]
          : int.parse(profileData["phone"]);
    }
    notifyListeners();
  }
}
