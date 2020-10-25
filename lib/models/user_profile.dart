import 'package:placementhq/models/registration.dart';

class Profile {
  //Personal
  bool verified;
  String id;
  String firstName;
  String middleName;
  String lastName;
  String dateOfBirth;
  String gender;
  String nationality;
  String imageUrl;
  String resumeUrl;
  //Academic
  String collegeName;
  String collegeId;
  String specialization;
  String rollNo;
  double secMarks;
  double highSecMarks;
  bool hasDiploma;
  double diplomaMarks;
  double cgpa;
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

  List<Registration> registrations;

  Profile({
    this.verified,
    this.id,
    this.firstName = "",
    this.middleName = "",
    this.lastName = "",
    this.dateOfBirth,
    this.gender,
    this.nationality,
    this.imageUrl,
    this.resumeUrl,
    this.collegeName,
    this.collegeId,
    this.specialization,
    this.rollNo,
    this.secMarks,
    this.highSecMarks,
    this.hasDiploma,
    this.diplomaMarks,
    this.beMarks,
    this.cgpa,
    this.numOfGapYears,
    this.numOfKTs,
    this.phone,
    this.email,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.registrations,
  });

  List<String> get hasRegistered {
    if (registrations != null) {
      return registrations.map((reg) => reg.driveId).toList();
    }
    return [];
  }

  String get fullNameWMid {
    return firstName + " " + middleName + " " + lastName;
  }

  String get fullName {
    return firstName + " " + lastName;
  }

  String get fullAddress {
    return address + ", " + city + ", " + state + ". " + pincode.toString();
  }

  String toString() {
    return this.fullName;
  }
}
