import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class College {
  String id;
  String name;
  String city;
  String state;

  College({
    @required this.name,
    this.city,
    this.state,
    this.id,
  });
}

class Colleges with ChangeNotifier {
  String _token;
  List<College> _colleges = [];

  Colleges();

  void update(token){
    this._token = token;
  }

  List<College> get colleges {
    return [..._colleges];
  }

  Future<void> loadColleges() async {
    final url =
        "https://placementhq-777.firebaseio.com/colleges.json?auth=$_token";
    final res = await http.get(url);
    final colleges = json.decode(res.body) as Map<String, dynamic>;
    final List<College> newColleges = [];

    colleges.forEach((key, college) {
      newColleges.add(College(name: college["name"], id: key));
    });
    _colleges = newColleges;
    notifyListeners();
  }
}
