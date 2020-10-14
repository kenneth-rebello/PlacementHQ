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

  Companies(this._token);

  List<Company> get companies {
    return [..._companies];
  }

  Future<void> loadCompaniesForList(String collegeId) async {
    final url =
        "https://placementhq-777.firebaseio.com/companies.json?auth=$_token";
    final res = await http.get(url);
    final companies = json.decode(res.body) as Map<String, dynamic>;
    List<Company> newCompanies = [];
    if (companies != null) {
      companies.forEach((key, company) {
        newCompanies.add(Company(name: company["name"], id: key));
      });
    }
    _companies = newCompanies;
    notifyListeners();
  }

  Company getById(String id) {
    return _companies.firstWhere((company) => company.id == id);
  }
}
