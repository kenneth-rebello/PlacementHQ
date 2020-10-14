import 'package:flutter/material.dart';
import 'package:placementshq/providers/companies.dart';
import 'package:placementshq/providers/drives.dart';
import 'package:provider/provider.dart';
import 'package:placementshq/providers/auth.dart';
import 'package:placementshq/providers/colleges.dart';
import 'package:placementshq/providers/officer.dart';
import 'package:placementshq/providers/user.dart';
import 'package:placementshq/res/constants.dart';
import 'package:placementshq/screens/auth_screen.dart';
import 'package:placementshq/screens/splash_screen.dart';
import 'package:placementshq/screens/home_screens/home_screen.dart';
import 'package:placementshq/screens/profile_screens/edit_profile.dart';
import 'package:placementshq/screens/profile_screens/profile_screen.dart';
import 'package:placementshq/screens/profile_screens/tpo_application.dart';
import 'package:placementshq/screens/for_students/notices_screen.dart';
import 'package:placementshq/screens/for_students/registrations_screen.dart';
import 'package:placementshq/screens/for_students/drives_screen.dart';
import 'package:placementshq/screens/for_officers/current_drives_screen.dart';
import 'package:placementshq/screens/for_officers/new_drive_screen.dart';
import 'package:placementshq/screens/for_officers/students_screen.dart';

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
        builder: (ctx, auth, _) => MaterialApp(
          title: Constants.title,
          theme: ThemeData(
            primaryColor: Colors.indigo[800],
            accentColor: Colors.orange[500],
            buttonColor: Colors.indigo[800],
            textTheme: TextTheme(
              headline3: TextStyle(
                color: Colors.indigo[800],
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              button: TextStyle(color: Colors.white),
            ),
          ),
          home: auth.isAuth
              ? HomeScreen()
              : FutureBuilder<bool>(
                  future: auth.autoLogIn(),
                  builder: (ctx, snapshot) =>
                      snapshot.connectionState == ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen(),
                ),
          routes: {
            DrivesScreen.routeName: (ctx) => DrivesScreen(),
            RegistrationsScreen.routeName: (ctx) => RegistrationsScreen(),
            NoticesScreen.routeName: (ctx) => NoticesScreen(),
            ProfileScreen.routeName: (ctx) => ProfileScreen(),
            EditProfile.routeName: (ctx) => EditProfile(),
            TPOApplication.routeName: (ctx) => TPOApplication(),
            NewDriveScreen.routeName: (ctx) => NewDriveScreen(),
            StudentsScreen.routeName: (ctx) => StudentsScreen(),
            CurrentDrivesScreen.routeName: (ctx) => CurrentDrivesScreen(),
          },
        ),
      ),
    );
  }
}
