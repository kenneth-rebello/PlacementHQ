import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:placementhq/models/offer.dart';

class Offers with ChangeNotifier {
  List<Data> _archives = [];
  List<Offer> _offers = [];
  String token;
  String _collegeId;

  void update(String token, String collegeId) {
    this.token = token;
    this._collegeId = collegeId;
  }

  List<Data> get archives {
    return [..._archives];
  }

  List<Offer> get offers {
    return [
      ..._offers
        ..sort(
          (a, b) => DateTime.parse(b.selectedOn)
              .compareTo(DateTime.parse(a.selectedOn)),
        )
    ];
  }

  List<Offer> getOffersByYear(String year) {
    final res =
        _archives.firstWhere((data) => data.year == year, orElse: () => null);
    if (res != null)
      return [...res.offers];
    else
      return [];
  }

  List<Offer> getOffersByStudent(String id) {
    final year = DateTime.now().month <= 5
        ? DateTime.now().year.toString()
        : (DateTime.now().year + 1).toString();
    final res = _archives.firstWhere(
      (data) => data.year == year,
      orElse: () => null,
    );
    if (res != null) {
      final newOffers = res.offers.where((o) => o.userId == id).toList();
      newOffers.sort((a, b) => a.ctc.compareTo(b.ctc));
      return [...newOffers];
    } else {
      return [];
    }
  }

  Future<void> getCollegeOffers() async {
    final url =
        'https://placementhq-777.firebaseio.com/collegeData/$_collegeId/offers.json?auth=$token';
    final res = await http.get(url);
    final data = json.decode(res.body) as Map<String, dynamic>;

    List<Data> newData = [];
    if (data != null)
      data.forEach((year, offers) {
        List<Offer> newOffers = [];
        if (offers != null)
          offers.forEach((key, offer) {
            newOffers.add(Offer(
              id: key,
              userId: offer["userId"],
              candidate: offer["candidate"],
              driveId: offer["driveId"],
              rollNo: offer["rollNo"],
              department: offer["specialization"],
              companyId: offer["companyId"],
              companyName: offer["companyName"],
              companyImageUrl: offer["companyImageUrl"],
              ctc: offer["ctc"],
              selectedOn: offer["selectedOn"],
              accepted: offer["accepted"],
              category: offer["category"],
            ));
          });
        newOffers.sort((a, b) => a.rollNo.compareTo(b.rollNo));
        newData.add(Data(year: year, offers: newOffers));
      });

    newData.sort((a, b) => a.year.compareTo(b.year));
    _archives = newData;
    // newOffers.sort((a, b) => b.issuedOn.compareTo(a.issuedOn));
    notifyListeners();
  }

  Future<void> getCompanyOffers(String companyId) async {
    final url =
        'https://placementhq-777.firebaseio.com/collegeData/$_collegeId/offers.json?shallow=true&auth=$token';
    final shallowRes = await http.get(url);
    final shallowData = json.decode(shallowRes.body) as Map<String, dynamic>;
    final years = new List<String>();
    shallowData.forEach((key, value) {
      if (value == true && !years.contains(key)) {
        years.add(key);
      }
    });
    List<Offer> newOffers = [];
    years.forEach((year) async {
      var url2 =
          'https://placementhq-777.firebaseio.com/collegeData/$_collegeId/offers/$year.json?orderBy="companyId"&equalTo="$companyId"&auth=$token';
      final res = await http.get(url2);
      final offers = json.decode(res.body) as Map<String, dynamic>;
      if (offers != null)
        offers.forEach((key, offer) {
          newOffers.add(Offer(
            id: key,
            userId: offer["userId"],
            candidate: offer["candidate"],
            driveId: offer["driveId"],
            rollNo: offer["rollNo"],
            department: offer["specialization"],
            companyId: offer["companyId"],
            companyName: offer["companyName"],
            companyImageUrl: offer["companyImageUrl"],
            ctc: offer["ctc"],
            selectedOn: offer["selectedOn"],
            accepted: offer["accepted"],
            category: offer["category"],
          ));
        });
      _offers = newOffers;
      notifyListeners();
    });
  }

  Future<void> getYearOffers(String year) async {
    final url =
        'https://placementhq-777.firebaseio.com/collegeData/$_collegeId/offers/$year.json?auth=$token';
    final res = await http.get(url);
    final offers = json.decode(res.body) as Map<String, dynamic>;

    List<Offer> newOffers = [];
    if (offers != null)
      offers.forEach((key, offer) {
        newOffers.add(Offer(
          id: key,
          userId: offer["userId"],
          candidate: offer["candidate"],
          driveId: offer["driveId"],
          rollNo: offer["rollNo"],
          department: offer["specialization"],
          companyId: offer["companyId"],
          companyName: offer["companyName"],
          companyImageUrl: offer["companyImageUrl"],
          ctc: offer["ctc"],
          selectedOn: offer["selectedOn"],
          accepted: offer["accepted"],
          category: offer["category"],
        ));
      });
    newOffers.sort((a, b) => a.rollNo.compareTo(b.rollNo));

    _archives = [
      new Data(
        year: year,
        offers: newOffers,
      )
    ];
    // newOffers.sort((a, b) => b.issuedOn.compareTo(a.issuedOn));
    notifyListeners();
  }
}
