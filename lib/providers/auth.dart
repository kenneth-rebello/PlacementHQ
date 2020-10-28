import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _refreshToken;
  String _userId;
  String _collegeId;
  bool isOfficer = false;
  bool isVerified = false;
  Timer authTimer;
  String userEmail;
  String userPassword;

  bool get isAuth {
    return token != null;
  }

  String get userId {
    return _userId;
  }

  String get collegeId {
    return _collegeId;
  }

  void setCollegeId(String id) {
    _collegeId = id;
    notifyListeners();
  }

  String get token {
    if (_token != null) {
      return _token;
    } else
      return null;
  }

  Future<void> signUp(String email, String password) async {
    const url =
        "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyB0UuBOWbFOR5nTFaLRq2TSTk0F7VS6wMU";
    final res = await http.post(
      url,
      body: json.encode({
        "email": email,
        "password": password,
        "returnSecureToken": true,
      }),
    );
    var data = json.decode(res.body);
    if (data['error'] != null) {
      throw HttpException(data['error']['message']);
    }

    final urlVerify =
        "https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=AIzaSyB0UuBOWbFOR5nTFaLRq2TSTk0F7VS6wMU";
    final resVerify = await http.post(
      urlVerify,
      body: json
          .encode({"requestType": "VERIFY_EMAIL", "idToken": data["idToken"]}),
    );

    var dataVerify = json.decode(resVerify.body);
    if (dataVerify['error'] != null) {
      throw HttpException(data['error']['message']);
    }

    throw HttpException("VERIFY_EMAIL");
  }

  Future<void> signIn(String email, String password) async {
    this.userEmail = email;
    this.userPassword = password;

    const url =
        "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyB0UuBOWbFOR5nTFaLRq2TSTk0F7VS6wMU";
    final res = await http.post(
      url,
      body: json.encode({
        "email": email,
        "password": password,
        "returnSecureToken": true,
      }),
    );
    var data = json.decode(res.body);

    final urlUser =
        "https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=AIzaSyB0UuBOWbFOR5nTFaLRq2TSTk0F7VS6wMU";
    final resUser = await http.post(urlUser,
        body: json.encode({"idToken": data["idToken"]}));
    final accountDetails = json.decode(resUser.body)["users"][0];
    if (!accountDetails["emailVerified"]) {
      throw HttpException("NOT_VERIFIED");
    }

    if (data['error'] != null) {
      throw HttpException(data['error']['message']);
    } else {
      _token = data['idToken'];
      _userId = data['localId'];
      _refreshToken = data['refreshToken'];
      _expiryDate = DateTime.now().add(
        Duration(seconds: int.parse(data['expiresIn'])),
      );
      autoRefreshToken();

      //Check if user is a TPO (and whether verified or not)
      try {
        final res = await http.get(
            "https://placementhq-777.firebaseio.com/officers/${data['localId']}.json?auth=${data['idToken']}");
        final officer = json.decode(res.body);
        if (officer != null) {
          isOfficer = true;
          isVerified = officer["verified"];
        } else {
          isOfficer = false;
          isVerified = false;
        }
      } catch (e) {
        print(e);
      }

      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'refreshToken': _refreshToken,
        'expiryDate': _expiryDate.toIso8601String(),
        'email': email,
        "collegeId": _collegeId,
        "isOfficer": isOfficer,
        "isVerified": isVerified,
      });
      prefs.setString('pHQuserData', userData);
    }
  }

  Future<void> resendVerificationEmail() async {
    const url =
        "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyB0UuBOWbFOR5nTFaLRq2TSTk0F7VS6wMU";
    final res = await http.post(
      url,
      body: json.encode({
        "email": userEmail,
        "password": userPassword,
        "returnSecureToken": true,
      }),
    );
    var data = json.decode(res.body);

    final urlVerify =
        "https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=AIzaSyB0UuBOWbFOR5nTFaLRq2TSTk0F7VS6wMU";
    await http.post(
      urlVerify,
      body: json
          .encode({"requestType": "VERIFY_EMAIL", "idToken": data["idToken"]}),
    );
  }

  Future<bool> autoLogIn() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('pHQuserData')) return false;
    final userData =
        json.decode(prefs.getString('pHQuserData')) as Map<String, dynamic>;
    final expiryDate = DateTime.parse(userData['expiryDate']);
    isVerified = userData["isVerified"];
    isOfficer = userData["isOfficer"];
    _token = userData['token'];
    _userId = userData['userId'];
    _collegeId = userData["collegeId"];
    _refreshToken = userData["refreshToken"];
    _expiryDate = expiryDate;
    userEmail = userData["email"];
    notifyListeners();
    autoRefreshToken();
    return true;
  }

  void logout() async {
    if (authTimer != null) {
      authTimer.cancel();
      authTimer = null;
    }

    if (_collegeId != null) {
      final fbm = FirebaseMessaging();
      fbm.unsubscribeFromTopic("college" + _collegeId);
      fbm.unsubscribeFromTopic("user" + userId);
    }
    _token = null;
    _userId = null;
    _expiryDate = null;
    _collegeId = null;
    _refreshToken = null;

    final prefs = await SharedPreferences.getInstance();
    prefs.remove('pHQuserData');

    notifyListeners();
  }

  void refreshToken() async {
    if (_refreshToken == null) return;
    final url =
        "https://securetoken.googleapis.com/v1/token?key=AIzaSyB0UuBOWbFOR5nTFaLRq2TSTk0F7VS6wMU";
    final res = await http.post(
      url,
      body: json.encode({
        "grant_type": "refresh_token",
        "refresh_token": _refreshToken,
      }),
    );
    final data = json.decode(res.body);
    _token = data["id_token"];
    _expiryDate = DateTime.now().add(
      Duration(seconds: int.parse(data['expires_in'])),
    );
    _refreshToken = data["refresh_token"];
    autoRefreshToken();
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('pHQuserData')) return;
    final cachedData =
        json.decode(prefs.getString('pHQuserData')) as Map<String, dynamic>;
    final userData = json.encode({
      'token': _token,
      'userId': cachedData["userId"],
      'refreshToken': _refreshToken,
      'expiryDate': _expiryDate.toIso8601String(),
      'email': cachedData["email"],
      "collegeId": cachedData["collegeId"],
      "isOfficer": cachedData["isOfficer"],
      "isVerified": cachedData["isVerified"],
    });
    prefs.setString('pHQuserData', userData);
  }

  void autoRefreshToken() {
    if (authTimer != null) {
      authTimer.cancel();
    }

    if (_expiryDate.isBefore(DateTime.now())) {
      refreshToken();
      return;
    }

    DateFormat formatter = new DateFormat("dd-MM-yyyy hh:mm");
    print(formatter.format(_expiryDate));
    final timeToExpire = _expiryDate.difference(DateTime.now()).inSeconds;
    authTimer = Timer(Duration(seconds: timeToExpire - 300), refreshToken);
  }

  void markAsTPO() {
    isOfficer = true;
  }
}
