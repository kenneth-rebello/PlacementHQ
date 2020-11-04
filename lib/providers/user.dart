import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:placementhq/models/drive.dart';
import 'package:placementhq/models/notice.dart';
import 'package:placementhq/models/offer.dart';
import 'package:placementhq/models/registration.dart';
import 'package:placementhq/models/user_profile.dart';

class User with ChangeNotifier {
  String token;
  String userId;
  String emailId;
  Profile _userProfile;
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
    if (_userProfile != null)
      copy = Profile(
        id: _userProfile.id,
        verified: _userProfile.verified,
        firstName: _userProfile.firstName,
        middleName: _userProfile.middleName,
        lastName: _userProfile.lastName,
        dateOfBirth: _userProfile.dateOfBirth,
        gender: _userProfile.gender,
        nationality: _userProfile.nationality,
        imageUrl: _userProfile.imageUrl,
        resumeUrl: _userProfile.resumeUrl,
        collegeId: _userProfile.collegeId,
        collegeName: _userProfile.collegeName,
        specialization: _userProfile.specialization,
        rollNo: _userProfile.rollNo,
        secMarks: _userProfile.secMarks,
        highSecMarks: _userProfile.highSecMarks,
        hasDiploma: _userProfile.hasDiploma,
        diplomaMarks: _userProfile.diplomaMarks,
        beMarks: _userProfile.beMarks,
        cgpa: _userProfile.cgpa,
        numOfGapYears: _userProfile.numOfGapYears,
        numOfKTs: _userProfile.numOfKTs,
        phone: _userProfile.phone,
        email: _userProfile.email,
        address: _userProfile.address,
        city: _userProfile.city,
        state: _userProfile.state,
        pincode: _userProfile.pincode,
        registrations: _userProfile.registrations,
        offers: _userProfile.offers,
        placedCategory: _userProfile.placedCategory,
      );
    else
      copy = null;
    return copy;
  }

  String get collegeId {
    if (_userProfile != null) {
      return _userProfile.collegeId;
    } else
      return null;
  }

  List<Registration> get userRegistrations {
    if (_userProfile != null) {
      return [
        ..._userProfile.registrations
          ..sort((a, b) {
            return DateTime.parse(a.registeredOn).compareTo(
              DateTime.parse(b.registeredOn),
            );
          })
      ];
    } else
      return [];
  }

  List<Offer> get userOffers {
    if (_userProfile != null) {
      return [..._userProfile.offers];
    } else
      return [];
  }

  Future<Profile> loadCurrentUserProfile() async {
    if (userId == null || userId == "") {
      throw HttpException("Invalid Operation");
    }
    final url =
        "https://placementhq-777.firebaseio.com/users/$userId.json?auth=$token";
    final data = await http.get(url);
    final profile = json.decode(data.body);

    if (profile != null) {
      _userProfile = new Profile(
        id: userId,
        verified: profile["verified"] == null ? false : profile["verified"],
        isTPC: profile["isTPC"] == null ? false : profile["isTPC"],
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
        _userProfile.offers = [...newOffers];

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
        _userProfile.registrations = [...newReg];
      }
    } else {
      _userProfile = null;
    }
    notifyListeners();

    return _userProfile;
  }

  Future<void> editProfile(Map<String, dynamic> profileData,
      {File image}) async {
    if (userId == null || userId == "") {
      throw HttpException("Invalid Operation");
    }
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

  Future<void> getRegistrations() async {
    if (collegeId == null || collegeId == "") {
      throw HttpException("Invalid Operation");
    }
    final url =
        'https://placementhq-777.firebaseio.com/collegeData/$collegeId/registrations.json?orderBy="userId"&equalTo="$userId"&print=pretty&auth=$token';
    final data = await http.get(url);
    final registrations = json.decode(data.body) as Map<String, dynamic>;
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
    _userProfile.registrations = [...newReg];
    notifyListeners();
  }

  Future<void> newRegistration(Profile user, Drive drive) async {
    if (collegeId == null || collegeId == "") {
      throw HttpException("Invalid Operation");
    }
    final existing = _userProfile.registrations.firstWhere(
      (reg) => reg.userId == user.id && reg.driveId == drive.id,
      orElse: () => null,
    );
    if (collegeId != null && existing == null) {
      final url =
          "https://placementhq-777.firebaseio.com/collegeData/$collegeId/registrations.json?auth=$token";
      final res = await http.post(
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
      final registration = json.decode(res.body) as Map<String, dynamic>;

      _userProfile.registrations.add(Registration(
        id: registration["name"],
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

  Future<void> cancelRegistration(String id) async {
    if (collegeId == null || collegeId == "" || id == null || id == "") {
      throw HttpException("Invalid Operation");
    }
    final url =
        "https://placementhq-777.firebaseio.com/collegeData/$collegeId/registrations/$id.json?auth=$token";
    await http.delete(url);
    _userProfile.registrations.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  Future<void> getOffers() async {
    if (collegeId == null || collegeId == "" || batch == null || batch == "") {
      throw HttpException("Invalid Operation");
    }
    final url =
        'https://placementhq-777.firebaseio.com/collegeData/$collegeId/offers/$batch.json?orderBy="userId"&equalTo="$userId"&auth=$token';
    final data = await http.get(url);
    final offers = json.decode(data.body) as Map<String, dynamic>;
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
    _userProfile.offers = [...newOffers];
    notifyListeners();
  }

  Future<void> respondToOffer(String id, bool value, String category) async {
    if (collegeId == null ||
        collegeId == "" ||
        batch == "" ||
        batch == null ||
        userId == "" ||
        userId == null) {
      throw HttpException("Invalid Operation");
    }
    final url =
        'https://placementhq-777.firebaseio.com/collegeData/$collegeId/offers/$batch/$id.json?auth=$token';
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
    final offer = _userProfile.offers.firstWhere((e) => e.id == id);
    offer.accepted = value;
    _userProfile.placedCategory = category;
    notifyListeners();
  }

  void updateValues(Map<String, dynamic> profileData) {
    if (_userProfile == null) _userProfile = new Profile();
    if (profileData["verified"] != null)
      _userProfile.verified = profileData["verified"];
    if (profileData["firstName"] != null)
      _userProfile.firstName = profileData["firstName"];
    if (profileData["middleName"] != null)
      _userProfile.middleName = profileData["middleName"];
    if (profileData["lastName"] != null)
      _userProfile.lastName = profileData["lastName"];
    if (profileData["gender"] != null)
      _userProfile.gender = profileData["gender"];
    if (profileData["dateOfBirth"] != null)
      _userProfile.dateOfBirth = profileData["dateOfBirth"];
    if (profileData["imageUrl"] != null)
      _userProfile.imageUrl = profileData["imageUrl"];
    if (profileData["resumeUrl"] != null)
      _userProfile.resumeUrl = profileData["resumeUrl"];
    if (profileData["nationality"] != null)
      _userProfile.nationality = profileData["nationality"];
    if (profileData["collegeName"] != null)
      _userProfile.collegeName = profileData["collegeName"];
    if (profileData["collegeId"] != null)
      _userProfile.collegeId = profileData["collegeId"];
    if (profileData["specialization"] != null)
      _userProfile.specialization = profileData["specialization"];
    if (profileData["rollNo"] != null)
      _userProfile.rollNo = profileData["rollNo"];
    if (profileData["secMarks"] != null)
      _userProfile.secMarks = profileData["secMarks"];
    if (profileData["highSecMarks"] != null)
      _userProfile.highSecMarks = profileData["highSecMarks"];
    if (profileData["hasDiploma"] != null)
      _userProfile.hasDiploma = profileData["hasDiploma"];
    if (profileData["cgpa"] != null) _userProfile.cgpa = profileData["cgpa"];
    if (profileData["numOfGapYears"] != null)
      _userProfile.numOfGapYears = profileData["numOfGapYears"];
    if (profileData["numOfKTs"] != null)
      _userProfile.numOfKTs = profileData["numOfKTs"];
    if (profileData["phone"] != null) _userProfile.phone = profileData["phone"];
    if (profileData["email"] != null) _userProfile.email = profileData["email"];
    if (profileData["city"] != null) _userProfile.city = profileData["city"];
    if (profileData["state"] != null) _userProfile.state = profileData["state"];
    if (profileData["address"] != null)
      _userProfile.address = profileData["address"];
    if (profileData["pincode"] != null)
      _userProfile.pincode = profileData["pincode"];
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
      data["issuedBy"] = _userProfile.fullName;
      data["issuerId"] = _userProfile.id;
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
}
