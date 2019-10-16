import 'package:flutter/material.dart';
import 'package:paybis_com_shifts/screens/change_user_screen.dart';
import 'package:paybis_com_shifts/screens/login_screen.dart';
import 'package:paybis_com_shifts/screens/register_user_screen.dart';
import 'package:paybis_com_shifts/screens/settings_screen.dart';
import 'package:paybis_com_shifts/screens/shifts_screen.dart';
import 'package:paybis_com_shifts/screens/welcome_screen.dart';

import 'screens/feed_screen.dart';
import 'screens/it_days_off_screen.dart';
import 'screens/login_screen.dart';
import 'screens/parking_screen.dart';
import 'screens/recent_changes_screen.dart';
import 'screens/shifts_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/support_days_off_screen.dart';
import 'screens/welcome_screen.dart';

void main() => runApp(PBShifts());

class PBShifts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: LoginScreen.id,
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
      },
    );
  }
}
