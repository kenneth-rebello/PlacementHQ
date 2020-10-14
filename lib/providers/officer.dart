import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:placementshq/models/drive.dart';

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
  List<Drive> _drives;

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
}