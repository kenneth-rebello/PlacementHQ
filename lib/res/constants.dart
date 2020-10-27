import 'package:flutter/material.dart';
import 'package:placementhq/screens/for_officers/current_drives_screen.dart';
import 'package:placementhq/screens/for_officers/new_drive_screen.dart';
import 'package:placementhq/screens/for_officers/new_notice_screen.dart';
import 'package:placementhq/screens/for_officers/students_screen.dart';
import 'package:placementhq/screens/for_students/drives_screen.dart';
import 'package:placementhq/screens/for_students/notices_screen.dart';
import 'package:placementhq/screens/profile_screens/profile_screen.dart';
import 'package:placementhq/screens/for_students/registrations_screen.dart';

abstract class Constants {
  static const title = "PlacementHQ";

  static List<HomeItem> homeItems = [
    HomeItem(
      label: "Latest Placement Drives",
      icon: Icons.business_center,
      routeName: DrivesScreen.routeName,
      imagePath: 'assets/images/companies.png',
      protected: true,
    ),
    HomeItem(
      label: "Registered Drives",
      icon: Icons.subscriptions,
      routeName: RegistrationsScreen.routeName,
      imagePath: 'assets/images/registrations.png',
      protected: true,
    ),
    HomeItem(
      label: "Noticeboard",
      icon: Icons.subscriptions,
      routeName: NoticesScreen.routeName,
      imagePath: 'assets/images/notices.png',
      protected: true,
    ),
    HomeItem(
      label: "My Profile",
      icon: Icons.subscriptions,
      routeName: ProfileScreen.routeName,
      imagePath: 'assets/images/profile.png',
      protected: false,
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
      label: "New Notice",
      routeName: NewNoticeScreen.routeName,
      imagePath: 'assets/images/notices.png',
      protected: false,
    ),
    HomeItem(
      label: "All Students",
      routeName: StudentsScreen.routeName,
      imagePath: 'assets/images/students.png',
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
}

class HomeItem {
  @required
  final String label;
  @required
  final IconData icon;
  @required
  final String routeName;
  @required
  final String imagePath;
  @required
  final bool protected;

  HomeItem({
    this.label,
    this.icon,
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
}
