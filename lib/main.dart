import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:paybis_com_shifts/screens/calendar_screen.dart';
import 'package:paybis_com_shifts/screens/change_user_screen.dart';
import 'package:paybis_com_shifts/screens/login_screen.dart';
import 'package:paybis_com_shifts/screens/register_user_screen.dart';
import 'package:paybis_com_shifts/screens/settings_screen.dart';
import 'package:paybis_com_shifts/screens/shifts_screen.dart';
import 'package:paybis_com_shifts/screens/welcome_screen.dart';

import 'constants.dart';
import 'screens/admin_calendar_screen.dart';
import 'screens/feed_screen.dart';
import 'screens/it_days_off_screen.dart';
import 'screens/login_screen.dart';
import 'screens/parking_screen.dart';
import 'screens/recent_changes_screen.dart';
import 'screens/shifts_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/support_days_off_screen.dart';
import 'screens/welcome_screen.dart';

FirebaseAuth _auth = FirebaseAuth.instance;
void main() => runApp(PBShifts());

final ThemeData _kPBShiftsTheme = _buildPBShiftsTheme();

ThemeData _buildPBShiftsTheme() {
  final ThemeData base = ThemeData.light();
  return base.copyWith(
    accentColor: accentColor,
    primaryColor: primaryColor,
    buttonTheme: base.buttonTheme.copyWith(
      buttonColor: lightPrimaryColor,
      textTheme: ButtonTextTheme.normal,
    ),
    scaffoldBackgroundColor: textIconColor,
    cardColor: textIconColor,
    textSelectionColor: textIconColor,
    errorColor: accentColor,
  );
}

class PBShifts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: LoginScreen.id,
//      home: _loadHomeScreen(),
      routes: {
        WelcomeScreen.id: (context) => WelcomeScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        RegistrationScreen.id: (context) => RegistrationScreen(),
        ShiftScreen.id: (context) => ShiftScreen(),
        StatsScreen.id: (context) => StatsScreen(),
        FeedScreen.id: (context) => FeedScreen(),
        SettingsScreen.id: (context) => SettingsScreen(),
        ChangeUserScreen.id: (context) => ChangeUserScreen(),
        RecentChangesScreen.id: (context) => RecentChangesScreen(),
        SupportDaysOffScreen.id: (context) => SupportDaysOffScreen(),
        ItDaysOffScreen.id: (context) => ItDaysOffScreen(),
        ParkingScreen.id: (context) => ParkingScreen(),
        CalendarScreen.id: (context) => CalendarScreen(),
        AdminCalendarScreen.id: (context) => AdminCalendarScreen(),
      },
//      theme: _kPBShiftsTheme,
    );
  }

//  Widget _loadHomeScreen() {
//    return FutureBuilder<FirebaseUser>(
//        future: _auth.currentUser(),
//        builder: (BuildContext context, AsyncSnapshot<FirebaseUser> snapshot) {
//          switch (snapshot.connectionState) {
//            case ConnectionState.none:
//            case ConnectionState.waiting:
//              return CircularProgressIndicator();
//            default:
//              if (snapshot.hasError) {
//                return Text('Error: ${snapshot.error}');
//              } else {
//                if (snapshot.data == null)
//                  return LoginScreen();
//                else
//                  return ShiftScreen();
//              }
//          }
//        });
//  }
}
