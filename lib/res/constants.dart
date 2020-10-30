import 'package:flutter/material.dart';
import 'package:placementhq/screens/for_officers/current_drives_screen.dart';
import 'package:placementhq/screens/for_officers/new_drive_screen.dart';
import 'package:placementhq/screens/for_officers/students_screen.dart';
import 'package:placementhq/screens/for_students/drives_screen.dart';
import 'package:placementhq/screens/for_students/notices_screen.dart';
import 'package:placementhq/screens/past_data_screens/archives_screen.dart';
import 'package:placementhq/screens/profile_screens/profile_screen.dart';
import 'package:placementhq/screens/for_students/registrations_screen.dart';

abstract class Constants {
  static const title = "PlacementHQ";

  static List<HomeItem> homeItems = [
    HomeItem(
      label: "Latest Placement Drives",
      routeName: DrivesScreen.routeName,
      imagePath: 'assets/images/companies.png',
      protected: true,
    ),
    HomeItem(
      label: "Registered Drives",
      routeName: RegistrationsScreen.routeName,
      imagePath: 'assets/images/registrations.png',
      protected: true,
    ),
    HomeItem(
      label: "Noticeboard",
      routeName: NoticesScreen.routeName,
      imagePath: 'assets/images/notices.png',
      protected: true,
    ),
    HomeItem(
      label: "My Profile",
      routeName: ProfileScreen.routeName,
      imagePath: 'assets/images/profile.png',
      protected: false,
    ),
    HomeItem(
      label: "Placement Archives",
      routeName: ArchivesScreen.routeName,
      imagePath: 'assets/images/history.png',
      protected: true,
    ),
  ];

  static List<HomeItem> tpoHomeItems = [
    HomeItem(
      label: "Current Placement Drives",
      routeName: CurrentDrivesScreen.routeName,
      imagePath: 'assets/images/drive.png',
      protected: false,
    ),
    HomeItem(
      label: "New Placement Drive",
      routeName: NewDriveScreen.routeName,
      imagePath: 'assets/images/companies.png',
      protected: false,
    ),
    HomeItem(
      label: "Noticeboard",
      routeName: NoticesScreen.routeName,
      imagePath: 'assets/images/notices.png',
      protected: true,
    ),
    HomeItem(
      label: "All Students",
      routeName: StudentsScreen.routeName,
      imagePath: 'assets/images/students.png',
      protected: false,
    ),
    HomeItem(
      label: "Placement Archives",
      routeName: ArchivesScreen.routeName,
      imagePath: 'assets/images/history.png',
      protected: false,
    ),
  ];

  static const List<String> branches = [
    "Information Technology",
    "Computer",
    "Automobile",
    "Biomedical",
    "Biotechnology",
    "Chemical",
    "Civil",
    "Construction",
    "Electrical",
    "Electronics",
    "Electronics & Tele.",
    "Instrumentation",
    "Marine",
    "Mechanical",
    "Production",
  ];

  static const List<String> driveCategories = [
    "Normal",
    "Dream",
    "Super Dream"
  ];

  static const List<String> registrationSortOptions = [
    SortOptions.uidAsc,
    SortOptions.uidDesc,
    SortOptions.nameAsc,
    SortOptions.nameDesc,
    SortOptions.registrationAsc,
    SortOptions.registrationDesc,
    SortOptions.onlySelected,
  ];

  static const List<String> studentSortOptions = [
    SortOptions.uidAsc,
    SortOptions.uidDesc,
    SortOptions.nameAsc,
    SortOptions.nameDesc,
  ];

  static const List<String> offersSortOptions = [
    SortOptions.uidAsc,
    SortOptions.uidDesc,
    SortOptions.ctcAsc,
    SortOptions.ctcDesc,
  ];
}

class HomeItem {
  @required
  final String label;
  @required
  final String routeName;
  @required
  final String imagePath;
  @required
  final bool protected;

  HomeItem({
    this.label,
    this.routeName,
    this.imagePath,
    this.protected,
  });
}

class SortOptions {
  static const uidAsc = "UID (asc.)";
  static const uidDesc = "UID (desc.)";
  static const nameAsc = "Name (asc.)";
  static const nameDesc = "Name (desc.)";
  static const registrationAsc = "Registration Date (asc.)";
  static const registrationDesc = "Registration Date (desc.)";
  static const onlySelected = "Only Selected";
  static const ctcAsc = "CTC (asc.)";
  static const ctcDesc = "CTC (desc.)";
}
