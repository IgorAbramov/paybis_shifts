import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:paybis_com_shifts/constants.dart';
import 'package:paybis_com_shifts/controller/db_controller.dart';
import 'package:paybis_com_shifts/models/employee.dart';
import 'package:paybis_com_shifts/screens/calendar_screen.dart';
import 'package:paybis_com_shifts/screens/parking_screen.dart';
import 'package:paybis_com_shifts/screens/shifts_screen.dart';
import 'package:paybis_com_shifts/ui_parts/rounded_button.dart';

import 'shifts_screen.dart';

Employee employee;
final dbController = DBController();
List<Employee> listWithEmployees = List<Employee>();

class LoginScreen extends StatefulWidget {
  static const String id = 'login_screen';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  TextEditingController _emailInputController;
  TextEditingController _pwdInputController;
  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  final loginScaffoldKey = new GlobalKey<ScaffoldState>();

  Future getCurrentUserAndLogin() async {
    try {
      final user = await _auth.currentUser();
      listWithEmployees.clear();
      await dbController.getUsers(listWithEmployees);
      if (user != null) {
        loggedInUser = user;
        for (Employee emp in listWithEmployees) {
          if (emp.email == loggedInUser.email) employee = emp;
        }
        recognizeUserType();
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUserAndLogin();

    _emailInputController = new TextEditingController();
    _pwdInputController = new TextEditingController();
  }

  String emailValidator(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Email format is invalid';
    } else {
      return null;
    }
  }

  String pwdValidator(String value) {
    if (value.length < 6) {
      return 'Password must be longer than 6 characters';
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: loginScaffoldKey,
      backgroundColor: Theme.of(context).textSelectionColor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Flexible(
              child: Hero(
                tag: 'logo',
                child: Container(
                  height: 200.0,
                  child: Image.asset('images/logo.png'),
                ),
              ),
            ),
            SizedBox(
              height: 48.0,
            ),
            Form(
              key: _loginFormKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    textAlign: TextAlign.center,
                    controller: _emailInputController,
                    validator: emailValidator,
                    decoration: kTextFieldDecoration.copyWith(
                      labelText: 'Email',
                      hintText: 'Enter your Email',
                    ),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  TextFormField(
                    textAlign: TextAlign.center,
                    controller: _pwdInputController,
                    obscureText: true,
                    validator: pwdValidator,
                    decoration: kTextFieldDecoration.copyWith(
                      labelText: 'Password',
                      hintText: 'Enter your Password',
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 24.0,
            ),
            RoundedButton(
              color: Theme.of(context).primaryColor,
              title: 'Log In',
              onPressed: () async {
                _emailInputController.text =
                    _emailInputController.text.replaceAll(' ', '');
                _pwdInputController.text =
                    _pwdInputController.text.replaceAll(' ', '');
                if (_loginFormKey.currentState.validate()) {
                  try {
                    final user = await _auth
                        .signInWithEmailAndPassword(
                            email: _emailInputController.text,
                            password: _pwdInputController.text)
                        .catchError(((err) => wrongEmailOrPasswordError(err)));
                    if (user != null) {
                      await getCurrentUserAndLogin();
                    }
                  } catch (e) {
                    print(e);
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void recognizeUserType() {
    switch (employee.department) {
      case kSuperAdmin:
        {
          print(kSuperAdmin);
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return ShiftScreen(key: shiftsScreenKey);
          }));
        }
        break;
      case kAdmin:
        {
          print(kAdmin);
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return ShiftScreen(key: shiftsScreenKey);
          }));
        }
        break;

      case kITAdmin:
        {
          print(kITAdmin);
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return ParkingScreen();
          }));
        }
        break;

      case kManagement:
        {
          print(kManagement);
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return CalendarScreen();
          }));
        }
        break;

      case kITDepartment:
        {
          print(kITDepartment);
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return CalendarScreen();
          }));
        }
        break;

      case kSupportDepartment:
        {
          print(kSupportDepartment);
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return ShiftScreen(key: shiftsScreenKey);
          }));
        }
        break;

      case kMarketingDepartment:
        {
          print(kMarketingDepartment);
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return CalendarScreen();
          }));
        }
        break;
      default:
        {
          print("Invalid choice");
        }
        break;
    }
  }

  wrongEmailOrPasswordError(Exception err) {
    print(err);
    loginScaffoldKey.currentState.showSnackBar(new SnackBar(
        content: new Text(
      "Wrong email or password",
      style: TextStyle(
          fontSize: 13.0,
          color: Theme.of(context).accentColor,
          height: 1.0,
          fontWeight: FontWeight.w300),
    )));
  }
}
