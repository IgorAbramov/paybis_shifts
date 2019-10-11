import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:paybis_com_shifts/constants.dart';
import 'package:paybis_com_shifts/controller/db_controller.dart';
import 'package:paybis_com_shifts/models/employee.dart';
import 'package:paybis_com_shifts/screens/shifts_screen.dart';
import 'package:paybis_com_shifts/ui_parts/rounded_button.dart';

import 'shifts_screen.dart';

Employee employee;
final dbController = DBController();
List<Employee> listWithEmployees = List<Employee>();

//TODO (In the end) add google auto log in option

class LoginScreen extends StatefulWidget {
  static const String id = 'login_screen';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  TextEditingController emailInputController;
  TextEditingController pwdInputController;
  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  final loginScaffoldKey = new GlobalKey<ScaffoldState>();

  Future getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      listWithEmployees.clear();
      await dbController.getUsers(listWithEmployees);
      if (user != null) {
        loggedInUser = user;
        for (Employee emp in listWithEmployees) {
          if (emp.email == loggedInUser.email) employee = emp;
        }
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    emailInputController = new TextEditingController();
    pwdInputController = new TextEditingController();
    super.initState();
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
      backgroundColor: Colors.white,
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
                    controller: emailInputController,
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
                    controller: pwdInputController,
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
              color: Colors.lightBlueAccent,
              title: 'Log In',
              onPressed: () async {
                if (_loginFormKey.currentState.validate()) {
                  try {
                    final user = await _auth
                        .signInWithEmailAndPassword(
                            email: emailInputController.text,
                            password: pwdInputController.text)
                        .catchError(((err) => wrongEmailOrPasswordError(err)));
                    if (user != null) {
                      await getCurrentUser();
//                      Navigator.pushNamed(context, ShiftScreen.id);
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (BuildContext context) {
                        return ShiftScreen();
                      }));
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

  wrongEmailOrPasswordError(Exception err) {
    print(err);
    loginScaffoldKey.currentState.showSnackBar(new SnackBar(
        content: new Text(
      "Wrong email or password",
      style: TextStyle(
          fontSize: 13.0,
          color: Colors.red,
          height: 1.0,
          fontWeight: FontWeight.w300),
    )));
  }
}
