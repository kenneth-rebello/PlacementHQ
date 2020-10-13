import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Profile {
  //Personal
  bool verified;
  String firstName;
  String middleName;
  String lastName;
  DateTime dateOfBirth;
  String gender;
  String nationality;
  String imageUrl;
  //Academic
  String collegeName;
  String collegeId;
  String specialization;
  double secMarks;
  double highSecMarks;
  double cgpi;
  double beMarks;
  int numOfGapYears;
  int numOfKTs;
  //Contact
  int phone;
  String email;
  String address;
  String city;
  String state;
  int pincode;

  Profile({
    this.verified,
    this.firstName,
    this.middleName,
    this.lastName,
    this.dateOfBirth,
    this.gender,
    this.nationality,
    this.imageUrl,
    this.collegeName,
    this.collegeId,
    this.specialization,
    this.secMarks,
    this.highSecMarks,
    this.beMarks,
    this.cgpi,
    this.numOfGapYears,
    this.numOfKTs,
    this.phone,
    this.email,
    this.address,
    this.city,
    this.state,
    this.pincode,
  });
}

class User with ChangeNotifier {
  final String token;
  final String userId;
  final String emailId;
  Profile userProfile;

  User(this.token, this.userId, this.emailId);

  Profile get profile {
    Profile copy;
    if (userProfile != null)
      copy = Profile(
        verified: userProfile.verified,
        firstName: userProfile.firstName,
        middleName: userProfile.middleName,
        lastName: userProfile.lastName,
        dateOfBirth: userProfile.dateOfBirth,
        gender: userProfile.gender,
        nationality: userProfile.nationality,
        imageUrl: userProfile.imageUrl,
        collegeId: userProfile.collegeId,
        collegeName: userProfile.collegeName,
        specialization: userProfile.specialization,
        secMarks: userProfile.secMarks,
        highSecMarks: userProfile.highSecMarks,
        beMarks: userProfile.beMarks,
        cgpi: userProfile.cgpi,
        numOfGapYears: userProfile.numOfGapYears,
        numOfKTs: userProfile.numOfKTs,
        phone: userProfile.phone,
        email: userProfile.email,
        address: userProfile.address,
        city: userProfile.city,
        state: userProfile.state,
        pincode: userProfile.pincode,
      );
    else
      copy = null;
    return copy;
  }

  Future<Profile> loadCurrentUserProfile() async {
    final url =
        "https://placementhq-777.firebaseio.com/users/$userId.json?auth=$token";
    final data = await http.get(url);
    final profile = json.decode(data.body);
    print("Profile Loaded");
    print(profile);

    if (profile != null) {
      userProfile = new Profile(
        verified: profile["verified"],
        firstName: profile["firstName"],
        middleName: profile["middleName"],
        lastName: profile["lastName"],
        dateOfBirth:
            (profile["dateOfBirth"] == null || profile["dateOfBirth"] == "")
                ? null
                : DateTime.parse(profile["dateOfBirth"]),
        gender: profile["gender"],
        nationality: profile["nationality"],
        imageUrl: profile["imageUrl"],
        collegeId: profile["collegeId"],
        collegeName: profile["collegeName"],
        specialization: profile["specialization"],
        secMarks: profile["secMarks"] == null
            ? null
            : profile["secMarks"] is int
                ? profile["secMarks"].toDouble()
                : profile["secMarks"],
        beMarks: profile["beMarks"] == null
            ? null
            : profile["beMarks"] is int
                ? profile["beMarks"].toDouble()
                : profile["beMarks"],
        highSecMarks: profile["highSecMarks"] == null
            ? null
            : profile["highSecMarks"] is int
                ? profile["highSecMarks"].toDouble()
                : profile["highSecMarks"],
        cgpi: profile["cgpi"] == null
            ? null
            : profile["cgpi"] is int
                ? profile["cgpi"].toDouble()
                : profile["cgpi"],
        numOfGapYears: profile["numOfGapYears"],
        numOfKTs: profile["numOfKTs"],
        phone: profile["phone"],
        email: profile["email"],
        address: profile["address"],
        city: profile["city"],
        state: profile["state"],
        pincode: profile["pincode"],
      );
    } else {
      userProfile = null;
    }
    notifyListeners();
    return profile;
  }

  Future<void> editProfile(Map<String, dynamic> profileData) async {
    final db =
        "https://placementhq-777.firebaseio.com/users/$userId.json?auth=$token";
    updateValues(profileData);
    await http.patch(
      db,
      body: json.encode(
        profileData,
      ),
    );
  }

  void updateValues(Map<String, dynamic> profileData) {
    if (userProfile == null) userProfile = new Profile();
    if (profileData["verified"] != null)
      userProfile.verified = profileData["verified"];
    if (profileData["firstName"] != null)
      userProfile.firstName = profileData["firstName"];
    if (profileData["middleName"] != null)
      userProfile.middleName = profileData["middleName"];
    if (profileData["lastName"] != null)
      userProfile.lastName = profileData["lastName"];
    if (profileData["gender"] != null)
      userProfile.gender = profileData["gender"];
    if (profileData["dateOfBirth"] != null)
      userProfile.dateOfBirth = profileData["dateOfBirth"];
    if (profileData["imageUrl"] != null)
      userProfile.imageUrl = profileData["imageUrl"];
    if (profileData["nationality"] != null)
      userProfile.nationality = profileData["nationality"];
    if (profileData["collegeName"] != null)
      userProfile.collegeName = profileData["collegeName"];
    if (profileData["collegeId"] != null)
      userProfile.collegeId = profileData["collegeId"];
    if (profileData["specialization"] != null)
      userProfile.specialization = profileData["specialization"];
    if (profileData["secMarks"] != null)
      userProfile.secMarks = profileData["secMarks"];
    if (profileData["highSecMarks"] != null)
      userProfile.highSecMarks = profileData["highSecMarks"];
    if (profileData["cgpi"] != null) userProfile.cgpi = profileData["cgpi"];
    if (profileData["numOfGapYears"] != null)
      userProfile.numOfGapYears = profileData["numOfGapYears"];
    if (profileData["numOfKTs"] != null)
      userProfile.numOfKTs = profileData["numOfKTs"];
    if (profileData["phone"] != null) userProfile.phone = profileData["phone"];
    if (profileData["email"] != null) userProfile.email = profileData["email"];
    if (profileData["city"] != null) userProfile.city = profileData["city"];
    if (profileData["state"] != null) userProfile.state = profileData["state"];
    if (profileData["address"] != null)
      userProfile.address = profileData["address"];
    if (profileData["pincode"] != null)
      userProfile.pincode = profileData["pincode"];
    notifyListeners();
  }
}
