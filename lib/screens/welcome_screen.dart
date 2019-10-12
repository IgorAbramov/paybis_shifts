import 'package:flutter/material.dart';
import 'package:paybis_com_shifts/constants.dart';
import 'package:paybis_com_shifts/screens/login_screen.dart';
import 'package:paybis_com_shifts/ui_parts/rounded_button.dart';

class WelcomeScreen extends StatefulWidget {
  static const String id = 'welcome_screen';

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: textIconColor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Hero(
                  tag: 'logo',
                  child: Container(
                    child: Image.asset('images/logo.png'),
                    height: 60.0,
                  ),
                ),
                Text(
                  'PayBis Shifts',
                  style: TextStyle(
                    fontSize: 36.0,
                    fontWeight: FontWeight.w900,
                    color: primaryColor,
                    fontFamily: "Horizon",
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 48.0,
            ),
            RoundedButton(
              color: primaryColor,
              title: 'Log In',
              onPressed: () {
                //Go to login screen.
                Navigator.pushNamed(context, LoginScreen.id);
              },
            ),
//            RoundedButton(
//              color: Colors.blueAccent,
//              title: 'Register',
//              onPressed: () {
//                //Go to login screen.
//                Navigator.pushNamed(context, RegistrationScreen.id);
//              },
//            ),
          ],
        ),
      ),
    );
  }
}

/* Map<int day of the year, Day>
   List<Shifts> day = [];
   List<Employees> shift = [];
* */
