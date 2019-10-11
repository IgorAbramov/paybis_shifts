import 'package:flutter/material.dart';
import 'package:paybis_com_shifts/screens/change_user_screen.dart';
import 'package:paybis_com_shifts/screens/login_screen.dart';
import 'package:paybis_com_shifts/screens/register_user_screen.dart';
import 'package:paybis_com_shifts/screens/settings_screen.dart';
import 'package:paybis_com_shifts/screens/shifts_screen.dart';
import 'package:paybis_com_shifts/screens/welcome_screen.dart';

import 'screens/feed_screen.dart';
import 'screens/personal_panel_screen.dart';
import 'screens/recent_changes_screen.dart';

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
        PersonalPanelScreen.id: (context) => PersonalPanelScreen(),
        FeedScreen.id: (context) => FeedScreen(),
        SettingsScreen.id: (context) => SettingsScreen(),
        ChangeUserScreen.id: (context) => ChangeUserScreen(),
        RecentChangesScreen.id: (context) => RecentChangesScreen(),
      },
    );
  }
}
