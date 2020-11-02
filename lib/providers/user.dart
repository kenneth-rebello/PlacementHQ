import 'dart:convert';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:placementhq/models/drive.dart';
import 'package:placementhq/models/offer.dart';
import 'package:placementhq/models/registration.dart';
import 'package:placementhq/models/user_profile.dart';

class User with ChangeNotifier {
  String token;
  String userId;
  String emailId;
  Profile userProfile;
  final batch = DateTime.now().month <= 5
      ? DateTime.now().year.toString()
      : (DateTime.now().year + 1).toString();

  User();

  void update(token, userId, emailId) {
    this.token = token;
    this.userId = userId;
    this.emailId = emailId;
  }

  Profile get profile {
    Profile copy;
    if (userProfile != null)
      copy = Profile(
        id: userProfile.id,
        verified: userProfile.verified,
        firstName: userProfile.firstName,
        middleName: userProfile.middleName,
        lastName: userProfile.lastName,
        dateOfBirth: userProfile.dateOfBirth,
        gender: userProfile.gender,
        nationality: userProfile.nationality,
        imageUrl: userProfile.imageUrl,
        resumeUrl: userProfile.resumeUrl,
        collegeId: userProfile.collegeId,
        collegeName: userProfile.collegeName,
        specialization: userProfile.specialization,
        rollNo: userProfile.rollNo,
        secMarks: userProfile.secMarks,
        highSecMarks: userProfile.highSecMarks,
        hasDiploma: userProfile.hasDiploma,
        diplomaMarks: userProfile.diplomaMarks,
        beMarks: userProfile.beMarks,
        cgpa: userProfile.cgpa,
        numOfGapYears: userProfile.numOfGapYears,
        numOfKTs: userProfile.numOfKTs,
        phone: userProfile.phone,
        email: userProfile.email,
        address: userProfile.address,
        city: userProfile.city,
        state: userProfile.state,
        pincode: userProfile.pincode,
        registrations: userProfile.registrations,
        offers: userProfile.offers,
        placedCategory: userProfile.placedCategory,
      );
    else
      copy = null;
    return copy;
  }

  String get collegeId {
    if (userProfile != null) {
      return userProfile.collegeId;
    } else
      return null;
  }

  List<Registration> get userRegistrations {
    if (userProfile != null) {
      return userProfile.registrations
        ..sort((a, b) {
          return DateTime.parse(a.registeredOn).compareTo(
            DateTime.parse(b.registeredOn),
          );
        });
    } else
      return [];
  }

  List<Offer> get userOffers {
    if (userProfile != null) {
      return [...userProfile.offers];
    } else
      return [];
  }

  Future<Profile> loadCurrentUserProfile() async {
    final url =
        "https://placementhq-777.firebaseio.com/users/$userId.json?auth=$token";
    final data = await http.get(url);
    final profile = json.decode(data.body);

    if (profile != null) {
      userProfile = new Profile(
        id: userId,
        verified: profile["verified"],
        firstName: profile["firstName"],
        middleName: profile["middleName"],
        lastName: profile["lastName"],
        dateOfBirth: profile["dateOfBirth"],
        gender: profile["gender"],
        nationality: profile["nationality"],
        imageUrl: profile["imageUrl"],
        resumeUrl: profile["resumeUrl"],
        collegeId: profile["collegeId"],
        collegeName: profile["collegeName"],
        specialization: profile["specialization"],
        rollNo: profile["rollNo"] == null ? "" : profile["rollNo"],
        placedCategory: profile["placedCategory"] == null
            ? "None"
            : profile["placedCategory"],
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
        hasDiploma:
            profile["hasDiploma"] == null ? false : profile["hasDiploma"],
        diplomaMarks: profile["diplomaMarks"] == null
            ? null
            : profile["diplomaMarks"] is int
                ? profile["diplomaMarks"].toDouble()
                : profile["diplomaMarks"],
        cgpa: profile["cgpa"] == null
            ? null
            : profile["cgpa"] is int
                ? profile["cgpa"].toDouble()
                : profile["cgpa"],
        numOfGapYears: profile["numOfGapYears"],
        numOfKTs: profile["numOfKTs"],
        phone: profile["phone"],
        email: profile["email"],
        address: profile["address"],
        city: profile["city"],
        state: profile["state"],
        pincode: profile["pincode"],
        registrations: [],
        offers: [],
      );
      notifyListeners();

      if (profile["collegeId"] != null && profile["collegeId"] != "") {
        final urlOffer =
            'https://placementhq-777.firebaseio.com/collegeData/${profile["collegeId"]}/offers/$batch.json?orderBy="userId"&equalTo="$userId"&auth=$token';
        final dataOffer = await http.get(urlOffer);
        final offers = json.decode(dataOffer.body) as Map<String, dynamic>;
        List<Offer> newOffers = [];
        if (offers != null)
          offers.forEach((key, offer) {
            newOffers.add(
              new Offer(
                id: key,
                userId: offer["userId"],
                candidate: offer["candidate"],
                rollNo: offer["rollNo"],
                department: offer["department"],
                driveId: offer["driveId"],
                companyId: offer["companyId"],
                companyName: offer["companyName"],
                companyImageUrl: offer["companyImageUrl"],
                ctc: offer["ctc"],
                selectedOn: offer["selectedOn"],
                accepted: offer["accepted"],
                category: offer["category"],
              ),
            );
          });
        userProfile.offers = [...newOffers];

        final urlReg =
            'https://placementhq-777.firebaseio.com/collegeData/${profile["collegeId"]}/registrations.json?orderBy="userId"&equalTo="$userId"&print=pretty&auth=$token';
        final dataReg = await http.get(urlReg);
        final registrations = json.decode(dataReg.body) as Map<String, dynamic>;
        final List<Registration> newReg = [];
        if (registrations != null)
          registrations.forEach((key, reg) {
            newReg.add(Registration(
              id: key,
              company: reg["company"],
              candidate: reg["candidate"],
              department: reg["deprtment"],
              companyId: reg["companyId"],
              companyImageUrl: reg["companyImageUrl"],
              userId: reg["userId"],
              driveId: reg["driveId"],
              registeredOn: reg["registeredOn"],
              rollNo: reg["rollNo"] == null ? "" : reg["rollNo"],
              selected: reg["selected"] == null ? false : reg["selected"],
            ));
          });
        userProfile.registrations = [...newReg];
      }
    } else {
      userProfile = null;
    }
    notifyListeners();

    return userProfile;
  }

  Future<void> editProfile(Map<String, dynamic> profileData,
      {File image}) async {
    if (image != null) {
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child(userId + ".jpeg");
      await ref.putFile(image).onComplete;

      final imageUrl = await ref.getDownloadURL();
      profileData["imageUrl"] = imageUrl;
    }
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

  Future<void> newRegistration(Profile user, Drive drive) async {
    final existing = userProfile.registrations.firstWhere(
      (reg) => reg.userId == user.id && reg.driveId == drive.id,
      orElse: () => null,
    );
    if (collegeId != null && existing == null) {
      final url =
          "https://placementhq-777.firebaseio.com/collegeData/$collegeId/registrations.json?auth=$token";
      await http.post(
        url,
        body: json.encode({
          "userId": user.id,
          "driveId": drive.id,
          "rollNo": user.rollNo,
          "candidate": user.fullNameWMid,
          "department": user.specialization,
          "company": drive.companyName,
          "companyId": drive.companyId,
          "companyImageUrl": drive.companyImageUrl,
          "registeredOn": DateTime.now().toIso8601String(),
        }),
      );

      userProfile.registrations.add(Registration(
        candidate: user.fullName,
        company: drive.companyName,
        companyId: drive.companyId,
        department: user.specialization,
        rollNo: user.rollNo,
        companyImageUrl: drive.companyImageUrl,
        userId: user.id,
        driveId: drive.id,
        registeredOn: DateTime.now().toIso8601String(),
      ));
      notifyListeners();
    } else {
      throw HttpException("Registration Failed");
    }
  }

  Future<void> respondToOffer(String id, bool value, String category) async {
    final url =
        'https://placementhq-777.firebaseio.com/collegeData/${profile.collegeId}/offers/$batch/$id.json?auth=$token';
    final res = await http.get(url);
    final offerData = json.decode(res.body) as Map<String, dynamic>;
    if (offerData["accepted"] == false) {
      throw HttpException("This drive is closed");
    }
    await http.patch(
      url,
      body: json.encode({
        "accepted": value,
      }),
    );
    final urlProfile =
        "https://placementhq-777.firebaseio.com/users/$userId.json?auth=$token";
    await http.patch(urlProfile,
        body: json.encode({"placedCategory": category}));
    final offer = userProfile.offers.firstWhere((e) => e.id == id);
    offer.accepted = value;
    userProfile.placedCategory = category;
    notifyListeners();
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
    if (profileData["resumeUrl"] != null)
      userProfile.resumeUrl = profileData["resumeUrl"];
    if (profileData["nationality"] != null)
      userProfile.nationality = profileData["nationality"];
    if (profileData["collegeName"] != null)
      userProfile.collegeName = profileData["collegeName"];
    if (profileData["collegeId"] != null)
      userProfile.collegeId = profileData["collegeId"];
    if (profileData["specialization"] != null)
      userProfile.specialization = profileData["specialization"];
    if (profileData["rollNo"] != null)
      userProfile.rollNo = profileData["rollNo"];
    if (profileData["secMarks"] != null)
      userProfile.secMarks = profileData["secMarks"];
    if (profileData["highSecMarks"] != null)
      userProfile.highSecMarks = profileData["highSecMarks"];
    if (profileData["hasDiploma"] != null)
      userProfile.hasDiploma = profileData["hasDiploma"];
    if (profileData["cgpa"] != null) userProfile.cgpa = profileData["cgpa"];
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
