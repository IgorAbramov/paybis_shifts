import 'package:flutter/material.dart';
import 'package:paybis_com_shifts/screens/login_screen.dart';
import 'package:paybis_com_shifts/screens/registration_screen.dart';
import 'package:paybis_com_shifts/screens/shifts_screen.dart';
import 'package:paybis_com_shifts/screens/welcome_screen.dart';

import 'screens/changes_log_screen.dart';
import 'screens/personal_panel_screen.dart';

void main() => runApp(PBShifts());

class PBShifts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: WelcomeScreen.id,
      routes: {
        WelcomeScreen.id: (context) => WelcomeScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        RegistrationScreen.id: (context) => RegistrationScreen(),
        ShiftScreen.id: (context) => ShiftScreen(),
        PersonalPanelScreen.id: (context) => PersonalPanelScreen(),
        ChangesLogScreen.id: (context) => ChangesLogScreen(),
      },
    );
  }
}
