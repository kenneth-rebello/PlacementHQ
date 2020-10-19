import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:placementhq/models/user_profile.dart';

class OfficerProfile {
  String fullName;
  String collegeName;
  String collegeId;
  String designation;
  int phone;
  String email;

  OfficerProfile({
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
    final colId = cId == null || cId == "" ? collegeId : cId;
    final url =
        'https://placementhq-777.firebaseio.com/users.json?orderBy="collegeId"&equalTo="$colId"&auth=$token&print=pretty';
    final res = await http.get(url);
    final students = json.decode(res.body) as Map<String, dynamic>;
    List<Profile> newStudents = [];
    if (students != null) {
      students.forEach((key, student) {
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
          beMarks: student["beMarks"] == null
              ? null
              : student["beMarks"] is int
                  ? student["beMarks"].toDouble()
                  : student["beMarks"],
          highSecMarks: student["highSecMarks"] == null
              ? null
              : student["highSecMarks"] is int
                  ? student["highSecMarks"].toDouble()
                  : student["highSecMarks"],
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
}
