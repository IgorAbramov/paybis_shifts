import 'package:flutter/material.dart';
import 'package:paybis_com_shifts/screens/change_user_screen.dart';
import 'package:paybis_com_shifts/ui_parts/rounded_button.dart';

import 'register_user_screen.dart';

class SettingsScreen extends StatefulWidget {
  static const String id = 'settings_screen';
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            height: 10.0,
          ),
          SettingsButton(
            buttonText: 'Add employee',
            function: redirectToCreateUserPage,
          ),
          SettingsButton(
            buttonText: 'Change or delete employee',
            function: redirectToChangeUserPage,
          ),
          //TODO add options to change appearance of the shifts screen and theme
        ],
      ),
    );
  }

  void redirectToCreateUserPage() {
    Navigator.pushNamed(context, RegistrationScreen.id);
  }

  void redirectToChangeUserPage() {
    Navigator.pushNamed(context, ChangeUserScreen.id);
  }
}

class SettingsButton extends StatefulWidget {
  final String buttonText;
  final Function function;

  SettingsButton({@required this.buttonText, this.function});

  @override
  _SettingsButtonState createState() => _SettingsButtonState();
}

class _SettingsButtonState extends State<SettingsButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: RoundedButton(
        onPressed: widget.function,
        title: widget.buttonText,
        color: Colors.lightBlueAccent,
      ),
    );
  }
}
