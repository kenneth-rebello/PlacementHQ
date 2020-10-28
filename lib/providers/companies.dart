import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Company {
  String name;
  String id;
  String imageUrl;
  int lastVisitedYear;
  double highestPackage;
  double lowestPackage;
  int numOfStudents;

  Company({
    this.name,
    this.id,
    this.imageUrl,
    this.highestPackage,
    this.lastVisitedYear,
    this.lowestPackage,
    this.numOfStudents,
  });
}

class Companies with ChangeNotifier {
  List<Company> _companies = [];
  String _token;
  String collegeName = "";

  void update(token) {
    this._token = token;
  }

  List<Company> get companies {
    return [..._companies];
  }

  Future<void> loadCompaniesForList(String collegeId) async {
    final url =
        "https://placementhq-777.firebaseio.com/collegeData/$collegeId/companies.json?auth=$_token";
    final res = await http.get(url);
    final companies = json.decode(res.body) as Map<String, dynamic>;
    List<Company> newCompanies = [];
    if (companies != null) {
      companies.forEach((key, company) {
        newCompanies.add(
          Company(
            name: company["name"],
            id: key,
            imageUrl: company["imageUrl"],
            lowestPackage:
                company["lowestPackage"] == null ? 0 : company["lowestPackage"],
            highestPackage: company["highestPackage"] == null
                ? 0
                : company["highestPackage"],
            lastVisitedYear: company["lastVisitedYear"] == null
                ? 0
                : company["lastVisitedYear"],
            numOfStudents:
                company["numOfStudents"] == null ? 0 : company["numOfStudents"],
          ),
        );
      });
    }
    _companies = newCompanies;

    final collegeUrl =
        "https://placementhq-777.firebaseio.com/colleges/$collegeId.json?auth=$_token";
    final collegeRes = await http.get(collegeUrl);
    final collegeData = json.decode(collegeRes.body) as Map<String, dynamic>;
    if (collegeData != null) {
      collegeName = collegeData["name"];
    }

    notifyListeners();
  }

  Company getById(String id) {
    return _companies.firstWhere((company) => company.id == id);
  }
}
