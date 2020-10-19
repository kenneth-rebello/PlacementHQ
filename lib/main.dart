import 'package:flutter/material.dart';
import 'package:placementhq/providers/companies.dart';
import 'package:placementhq/providers/drives.dart';
import 'package:placementhq/screens/drive_screens/drive_details.dart';
import 'package:placementhq/screens/for_officers/new_notice_screen.dart';
import 'package:provider/provider.dart';
import 'package:placementhq/providers/auth.dart';
import 'package:placementhq/providers/colleges.dart';
import 'package:placementhq/providers/officer.dart';
import 'package:placementhq/providers/user.dart';
import 'package:placementhq/res/constants.dart';
import 'package:placementhq/screens/auth_screen.dart';
import 'package:placementhq/screens/splash_screen.dart';
import 'package:placementhq/screens/home_screens/home_screen.dart';
import 'package:placementhq/screens/profile_screens/edit_profile.dart';
import 'package:placementhq/screens/profile_screens/profile_screen.dart';
import 'package:placementhq/screens/profile_screens/tpo_application.dart';
import 'package:placementhq/screens/for_students/notices_screen.dart';
import 'package:placementhq/screens/for_students/registrations_screen.dart';
import 'package:placementhq/screens/for_students/drives_screen.dart';
import 'package:placementhq/screens/for_officers/current_drives_screen.dart';
import 'package:placementhq/screens/for_officers/new_drive_screen.dart';
import 'package:placementhq/screens/for_officers/students_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, User>(
          create: (ctx) => null,
          update: (ctx, auth, prevUser) => User(
            auth.token,
            auth.userId,
            auth.userEmail,
          ),
        ),
        ChangeNotifierProxyProvider<Auth, Officer>(
          create: (ctx) => null,
          update: (ctx, auth, prevUser) => Officer(
            auth.token,
            auth.userId,
            auth.userEmail,
          ),
        ),
        ChangeNotifierProxyProvider<Auth, Colleges>(
          create: (ctx) => null,
          update: (ctx, auth, prevUser) => Colleges(
            auth.token,
          ),
        ),
        ChangeNotifierProxyProvider<Auth, Companies>(
          create: (ctx) => null,
          update: (ctx, auth, prevUser) => Companies(
            auth.token,
          ),
        ),
        ChangeNotifierProxyProvider<Auth, Drives>(
          create: (ctx) => null,
          update: (ctx, auth, prevUser) => Drives(
            auth.token,
          ),
        )
      ],
      child: Consumer<Auth>(
        builder: (ctxApp, auth, _) => MaterialApp(
          title: Constants.title,
          theme: ThemeData(
            primaryColor: Colors.indigo[800],
            accentColor: Colors.orange[500],
            buttonColor: Colors.indigo[800],
            textTheme: TextTheme(
              headline1: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
                fontFamily: 'Exo',
              ),
              headline3: TextStyle(
                color: Colors.indigo[900],
                fontWeight: FontWeight.bold,
                fontSize: 18,
                fontFamily: 'Merriweather',
              ),
              headline4: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.italic,
                fontFamily: 'Ubuntu',
                fontSize: 17,
              ),
              bodyText1: TextStyle(
                fontFamily: 'Ubuntu',
                fontSize: 14,
              ),
              bodyText2: TextStyle(
                fontFamily: 'Ubuntu',
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
              button: TextStyle(
                fontFamily: 'Ubuntu',
                color: Colors.white,
              ),
            ),
          ),
          home: auth.isAuth
              ? HomeScreen()
              : FutureBuilder<bool>(
                  future: auth.autoLogIn(),
                  builder: (ctxFuture, snapshot) =>
                      snapshot.connectionState == ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen(),
                ),
          routes: {
            DrivesScreen.routeName: (ctx) =>
                auth.isAuth ? DrivesScreen() : AuthScreen(),
            RegistrationsScreen.routeName: (ctx) =>
                auth.isAuth ? RegistrationsScreen() : AuthScreen(),
            NoticesScreen.routeName: (ctx) =>
                auth.isAuth ? NoticesScreen() : AuthScreen(),
            ProfileScreen.routeName: (ctx) =>
                auth.isAuth ? ProfileScreen() : AuthScreen(),
            EditProfile.routeName: (ctx) =>
                auth.isAuth ? EditProfile() : AuthScreen(),
            TPOApplication.routeName: (ctx) =>
                auth.isAuth ? TPOApplication() : AuthScreen(),
            NewDriveScreen.routeName: (ctx) =>
                auth.isAuth ? NewDriveScreen() : AuthScreen(),
            StudentsScreen.routeName: (ctx) =>
                auth.isAuth ? StudentsScreen() : AuthScreen(),
            NewNoticeScreen.routeName: (ctx) =>
                auth.isAuth ? NewNoticeScreen() : AuthScreen(),
            CurrentDrivesScreen.routeName: (ctx) =>
                auth.isAuth ? CurrentDrivesScreen() : AuthScreen(),
            DriveDetailsScreen.routeName: (ctx) =>
                auth.isAuth ? DriveDetailsScreen() : AuthScreen(),
          },
        ),
      ),
    );
  }
}
