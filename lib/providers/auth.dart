import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
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

  String get token {
    if (_token != null &&
        _expiryDate != null &&
        _expiryDate.isAfter(DateTime.now())) {
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
      _expiryDate = DateTime.now().add(
        Duration(seconds: int.parse(data['expiresIn'])),
      );
      autoLogout();

      //Check if user is a TPO (and whether verified or not)
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

      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate.toIso8601String(),
        'email': email,
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
    if (expiryDate.isBefore(DateTime.now())) return false;
    isVerified = userData["isVerified"];
    isOfficer = userData["isOfficer"];
    _token = userData['token'];
    _userId = userData['userId'];
    _expiryDate = expiryDate;
    userEmail = userData["email"];
    autoLogout();
    notifyListeners();
    return true;
  }

  void logout() async {
    if (authTimer != null) {
      authTimer.cancel();
      authTimer = null;
    }
    _token = null;
    _userId = null;
    _expiryDate = null;
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('pHQuserData');
    notifyListeners();
  }

  void autoLogout() {
    if (authTimer != null) {
      authTimer.cancel();
    }
    DateFormat formatter = new DateFormat("dd-MM-yyyy hh:mm");
    print(formatter.format(_expiryDate));
    final timeToExpire = _expiryDate.difference(DateTime.now()).inSeconds;
    authTimer = Timer(Duration(seconds: timeToExpire), logout);
  }

  void markAsTPO() {
    isOfficer = true;
  }
}
