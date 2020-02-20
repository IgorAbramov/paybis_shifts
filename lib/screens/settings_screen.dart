import 'package:flutter/material.dart';
import 'package:paybis_com_shifts/constants.dart';
import 'package:paybis_com_shifts/screens/change_user_screen.dart';
import 'package:paybis_com_shifts/screens/login_screen.dart';
import 'package:paybis_com_shifts/ui_parts/rounded_button.dart';

import '../main.dart';
import 'register_user_screen.dart';
import 'shifts_screen.dart';

final settingsScaffoldKey = GlobalKey<ScaffoldState>();

class SettingsScreen extends StatefulWidget {
  static const String id = 'settings_screen';
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  getUsers() async {
    listWithEmployees.clear();
    await dbController.getUsers(listWithEmployees);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    getUsers();
    return Scaffold(
      key: settingsScaffoldKey,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColorDark,
        title: Text('Settings'),
      ),
      body: (employee.department == kSuperAdmin)
          ? Column(
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
                SettingsButton(
                  buttonText: 'Change password',
                  function: openConfirmationWindow,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(appVersion),
                ),
                //TODO add options to change appearance of the shifts screen and theme
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SettingsButton(
                  buttonText: 'Change password',
                  function: openConfirmationWindow,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(appVersion),
                ),
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

  void openConfirmationWindow() {
    openPasswordChangeConfirmationAlertBox(context, 'Reset the password?');
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
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}

openPasswordChangeConfirmationAlertBox(BuildContext context, String title) {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(32.0))),
          contentPadding: EdgeInsets.only(top: 10.0),
          content: Container(
            width: 300.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      title,
                      style: TextStyle(fontSize: 24.0),
                    ),
                  ],
                ),
                SizedBox(
                  height: 5.0,
                ),
                Divider(
                  color: Theme.of(context).dividerColor,
                  height: 4.0,
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          dbController
                              .sendPasswordResetEmail(loggedInUser.email);
                          Navigator.pop(context);
                          showPasswordConfirmationMessage();
                        },
                        child: InkWell(
                          child: Container(
                            padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(32.0),
                              ),
                            ),
                            child: Text(
                              "Yes",
                              style: TextStyle(
                                  color: Theme.of(context).textSelectionColor,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          showCancelMessage();
                        },
                        child: InkWell(
                          child: Container(
                            padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context).accentColor,
                              borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(32.0)),
                            ),
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                  color: Theme.of(context).textSelectionColor,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      });
}

showPasswordConfirmationMessage() {
  settingsScaffoldKey.currentState.showSnackBar(
      new SnackBar(content: new Text("Password reset email has been sent")));
}
