import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
  final String token;
  final String userId;
  final String emailId;
  OfficerProfile _profile;
  List<Profile> _students = [];

  Officer(this.token, this.userId, this.emailId);

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
        phone: profile["phone"],
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
        print(key + ": " + student["firstName"] + "\n");
        newStudents.add(Profile(
          id: key,
          verified: student["verified"],
          firstName: student["firstName"],
          middleName: student["middleName"],
          lastName: student["lastName"],
          dateOfBirth: student["dateOfBirth"],
          gender: student["gender"],
          nationality: student["nationality"],
          imageUrl: student["imageUrl"],
          collegeId: student["collegeId"],
          collegeName: student["collegeName"],
          specialization: student["specialization"],
          rollNo: student["rollNo"] == null ? "" : student["rollNo"],
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
        ));
      });
      print(newStudents);
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

  Future<void> addNewNotice(Map<String, dynamic> data) async {
    if (collegeId != null) {
      data["issuedBy"] = _profile.fullName;
      data["issuerId"] = _profile.id;
      final url =
          'https://placementhq-777.firebaseio.com/collegeData/$collegeId/notices.json?auth=$token';
      await http.post(url, body: json.encode(data));
    }
  }
}
