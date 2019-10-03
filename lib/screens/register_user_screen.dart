import 'dart:io' show Platform;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/material_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:paybis_com_shifts/constants.dart';
import 'package:paybis_com_shifts/models/employee.dart';
import 'package:paybis_com_shifts/screens/welcome_screen.dart';
import 'package:paybis_com_shifts/ui_parts/rounded_button.dart';

//TODO add validations to form fields

class RegistrationScreen extends StatefulWidget {
  static const String id = 'register_user_screen';
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  String name;
  String email;
  String password;
  String initials;
  String selectedDepartment = kSupportDepartment;
  String selectedSupportPosition = kJuniorSupport;
  TextEditingController emailInputController;
  TextEditingController pwdInputController;
  final GlobalKey<FormState> _registerFormKey = GlobalKey<FormState>();
  final registerScaffoldKey = new GlobalKey<ScaffoldState>();
  bool showSpinner = false;
  Color pickerColor = Color(0xff443a49);
  Color currentColor = Color(0xff443a49);

  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  DropdownButton<String> androidDropdownDepartment() {
    List<DropdownMenuItem<String>> dropdownItems = [];
    for (int i = 0; i < kEmployeeDepartmentTypes.length; i++) {
      var newItem = DropdownMenuItem(
        child: Text(kEmployeeDepartmentTypes[i]),
        value: kEmployeeDepartmentTypes[i],
      );
      dropdownItems.add(newItem);
    }
    return DropdownButton<String>(
        value: selectedDepartment,
        items: dropdownItems,
        onChanged: (value) {
          setState(() {
            selectedDepartment = value;
          });
        });
  }

  CupertinoPicker iOSPickerDepartment() {
    List<Text> pickerItems = [];
    for (int i = 0; i < kEmployeeDepartmentTypes.length; i++) {
      pickerItems.add(Text(kEmployeeDepartmentTypes[i]));
    }

    return CupertinoPicker(
      backgroundColor: Colors.white,
      itemExtent: 32.0,
      onSelectedItemChanged: (selectedIndex) {
        setState(() {
          selectedDepartment = kEmployeeDepartmentTypes[selectedIndex];
        });
      },
      children: pickerItems,
    );
  }

  DropdownButton<String> androidDropdownSupportPositions() {
    List<DropdownMenuItem<String>> dropdownItems = [];
    for (int i = 0; i < kSupportPositionsChoices.length; i++) {
      var newItem = DropdownMenuItem(
        child: Text(kSupportPositionsChoices[i]),
        value: kSupportPositionsChoices[i],
      );
      dropdownItems.add(newItem);
    }
    return DropdownButton<String>(
        value: selectedSupportPosition,
        items: dropdownItems,
        onChanged: (value) {
          setState(() {
            selectedSupportPosition = value;
          });
        });
  }

  CupertinoPicker iOSPickerSupportPositions() {
    List<Text> pickerItems = [];
    for (int i = 0; i < kSupportPositionsChoices.length; i++) {
      pickerItems.add(Text(kSupportPositionsChoices[i]));
    }

    return CupertinoPicker(
      backgroundColor: Colors.white,
      itemExtent: 32.0,
      onSelectedItemChanged: (selectedIndex) {
        setState(() {
          selectedSupportPosition = kSupportPositionsChoices[selectedIndex];
        });
      },
      children: pickerItems,
    );
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
    if (value.length < 8) {
      return 'Password must be longer than 8 characters';
    } else {
      return null;
    }
  }

  @override
  void initState() {
    emailInputController = new TextEditingController();
    pwdInputController = new TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: registerScaffoldKey,
      appBar: AppBar(
        title: Text('Create user'),
        automaticallyImplyLeading: true,
      ),
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: ListView(
            children: <Widget>[
              SizedBox(
                height: 48.0,
              ),
              TextFormField(
                keyboardType: TextInputType.text,
                textAlign: TextAlign.center,
                validator: (value) =>
                    value.isEmpty ? 'Name field can\'t be empty' : null,
                onChanged: (value) {
                  //Do something with the user input.
                  name = value;
                },
                decoration: kTextFieldDecoration.copyWith(
                  hintText: 'Enter name',
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              Form(
                key: _registerFormKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      textAlign: TextAlign.center,
                      controller: emailInputController,
                      validator: emailValidator,
                      decoration: kTextFieldDecoration.copyWith(
                        hintText: 'Enter email',
                      ),
                      onChanged: (value) {
                        //Do something with the user input.
                        email = value;
                      },
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    TextFormField(
                      obscureText: true,
                      textAlign: TextAlign.center,
                      controller: pwdInputController,
                      validator: pwdValidator,
                      decoration: kTextFieldDecoration.copyWith(
                        hintText: 'Enter password',
                      ),
                      onChanged: (value) {
                        //Do something with the user input.
                        password = value;
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextFormField(
                autovalidate: true,
                validator: (val) {
                  if (val.trim().length < 2 || val.isEmpty) {
                    return 'Too short';
                  } else
                    return null;
                },
                keyboardType: TextInputType.text,
                textAlign: TextAlign.center,
                maxLength: 3,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (value) {
                  //Do something with the user input.
                  initials = value;
                },
                decoration: kTextFieldDecoration.copyWith(
                  hintText: 'Enter initials',
                ),
              ),
              Container(
                height: 120.0,
                alignment: Alignment.center,
                padding: EdgeInsets.only(bottom: 30.0),
                color: Colors.white,
                child: Platform.isIOS
                    ? iOSPickerDepartment()
                    : androidDropdownDepartment(),
              ),
              (selectedDepartment == kSupportDepartment)
                  ? Container(
                      height: 120.0,
                      alignment: Alignment.center,
                      padding: EdgeInsets.only(bottom: 30.0),
                      color: Colors.white,
                      child: Platform.isIOS
                          ? iOSPickerSupportPositions()
                          : androidDropdownSupportPositions(),
                    )
                  : SizedBox(
                      height: 8.0,
                    ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  MaterialButton(
                    child: Text(
                      'Pick color',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                    ),
                    color: currentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        child: AlertDialog(
                          title: const Text('Pick a color!'),
                          content: SingleChildScrollView(
//                        child: ColorPicker(
//                          pickerColor: pickerColor,
//                          onColorChanged: changeColor,
//                          enableLabel: true,
//                          pickerAreaHeightPercent: 0.8,
//                        ),
                            // Use Material color picker:
                            //
                            child: MaterialPicker(
                              pickerColor: pickerColor,
                              onColorChanged: changeColor,
                              enableLabel: true, // only on portrait mode
                            ),
                            //
                            // Use Block color picker:
                            //
                            // child: BlockPicker(
                            //   pickerColor: currentColor,
                            //   onColorChanged: changeColor,
                            // ),
                          ),
                          actions: <Widget>[
                            FlatButton(
                              child: const Text(
                                'OK',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  color: Colors.blue,
                                ),
                              ),
                              onPressed: () {
                                setState(() => currentColor = pickerColor);
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
//                  Container(
//                    decoration: BoxDecoration(
//                        shape: BoxShape.circle,
//                        color: pickerColor,
//                        borderRadius: BorderRadius.circular(10.0)),
//                  ),
                ],
              ),
              SizedBox(
                height: 24.0,
              ),
              RoundedButton(
                color: Colors.lightBlueAccent,
                title: 'Create user',
                onPressed: () async {
                  //registration functionality
                  if (_registerFormKey.currentState.validate()) {
                    try {
                      setState(() {
                        showSpinner = true;
                      });
                      final newUser = await _auth
                          .createUserWithEmailAndPassword(
                              email: emailInputController.text,
                              password: pwdInputController.text)
                          .catchError((err) => thereIsSuchUserError(err));

                      //Convert Color to String
                      String colorString = currentColor.toString();
                      String colorValueString =
                          colorString.split('(0x')[1].split(')')[0];

                      Employee newEmployee = new Employee(
                          name: name,
                          email: email,
                          initial: initials,
                          empColor: colorValueString,
                          department: selectedDepartment,
                          position: selectedSupportPosition);

                      Map newEmpMap = newEmployee.buildMap(
                          name,
                          email,
                          initials,
                          colorValueString,
                          selectedDepartment,
                          selectedSupportPosition);
                      dbController.createUser(newEmpMap);
                      listWithEmployees.add(newEmployee);
                      if (newUser != null) {
                        Navigator.pop(context);
                      }
                      setState(() {
                        showSpinner = false;
                      });
                    } catch (e) {
                      print(e);
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  thereIsSuchUserError(Exception err) {
    print(err);
    registerScaffoldKey.currentState.showSnackBar(new SnackBar(
        content: new Text(
      "There is such user",
      style: TextStyle(
          fontSize: 13.0,
          color: Colors.red,
          height: 1.0,
          fontWeight: FontWeight.w300),
    )));
    setState(() {
      showSpinner = false;
    });
  }
}
