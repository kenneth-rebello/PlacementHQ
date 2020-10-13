import 'package:flutter/material.dart';
import 'package:placementshq/screens/for_officers/current_drives_screen.dart';
import 'package:placementshq/screens/for_officers/new_drive_screen.dart';
import 'package:placementshq/screens/for_officers/students_screen.dart';
import 'package:placementshq/screens/for_students/companies_screen.dart';
import 'package:placementshq/screens/for_students/notices_screen.dart';
import 'package:placementshq/screens/profile_screens/profile_screen.dart';
import 'package:placementshq/screens/for_students/registrations_screen.dart';

abstract class Constants {
  static const title = "PlacementHQ";

  static List<HomeItem> homeItems = [
    HomeItem(
      label: "Companies",
      icon: Icons.business_center,
      routeName: CompaniesScreen.routeName,
      imagePath: 'assets/images/companies.png',
      protected: true,
    ),
    HomeItem(
      label: "Registrations",
      icon: Icons.subscriptions,
      routeName: RegistrationsScreen.routeName,
      imagePath: 'assets/images/registrations.png',
      protected: true,
    ),
    HomeItem(
      label: "Notices",
      icon: Icons.subscriptions,
      routeName: NoticesScreen.routeName,
      imagePath: 'assets/images/notices.png',
      protected: true,
    ),
    HomeItem(
      label: "Profile",
      icon: Icons.subscriptions,
      routeName: ProfileScreen.routeName,
      imagePath: 'assets/images/profile.png',
      protected: false,
    ),
  ];

  static List<HomeItem> tpoHomeItems = [
    HomeItem(
      label: "New Drive",
      icon: Icons.subscriptions,
      routeName: NewDriveScreen.routeName,
      imagePath: 'assets/images/companies.png',
      protected: false,
    ),
    HomeItem(
      label: "Students",
      routeName: StudentsScreen.routeName,
      imagePath: 'assets/images/students.png',
      protected: false,
    ),
    HomeItem(
      label: "Current Drives",
      routeName: CurrentDrivesScreen.routeName,
      imagePath: 'assets/images/drive.png',
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
