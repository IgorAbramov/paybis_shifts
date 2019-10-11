import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:paybis_com_shifts/constants.dart';
import 'package:paybis_com_shifts/models/colorpicker.dart';
import 'package:paybis_com_shifts/models/employee.dart';
import 'package:paybis_com_shifts/screens/login_screen.dart';
import 'package:paybis_com_shifts/ui_parts/rounded_button.dart';

import 'shifts_screen.dart';

class ChangeUserScreen extends StatefulWidget {
  static const String id = 'change_user_screen';
  @override
  _ChangeUserScreenState createState() => _ChangeUserScreenState();
}

class _ChangeUserScreenState extends State<ChangeUserScreen> {
  String selectedEmp = listWithEmployees.first.name;
  String name = listWithEmployees.first.name;
  String email = listWithEmployees.first.email;
  String password = '';
  String initials = listWithEmployees.first.initial;
  String selectedDepartment = kSupportDepartment;
  String selectedSupportPosition = kJuniorSupport;
  Color pickerColor = Color(0xff443a49);
  Color currentColor = convertColor(listWithEmployees.first.empColor);

  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  void fillForms(String selectedEmployee) {
    for (Employee emp in listWithEmployees) {
      if (emp.name == selectedEmployee) {
        name = emp.name;
        email = emp.email;
        initials = emp.initial;
        currentColor = convertColor(emp.empColor);
      }
    }
  }

  DropdownButton<String> androidDropdownName() {
    List<DropdownMenuItem<String>> dropdownItems = [];
    for (Employee emp in listWithEmployees) {
      var newItem = DropdownMenuItem(
        child: Text(emp.name),
        value: emp.name,
      );
      dropdownItems.add(newItem);
    }
    return DropdownButton<String>(
        value: selectedEmp,
        items: dropdownItems,
        onChanged: (value) {
          setState(() {
            selectedEmp = value;
            fillForms(selectedEmp);
          });
        });
  }

  CupertinoPicker iOSPickerName() {
    List<Text> pickerItems = [];
    for (Employee emp in listWithEmployees) {
      pickerItems.add(Text(emp.name));
    }

    return CupertinoPicker(
      backgroundColor: Colors.white,
      itemExtent: 32.0,
      onSelectedItemChanged: (selectedIndex) {
        setState(() {
          selectedEmp = listWithEmployees[selectedIndex].name;
          fillForms(selectedEmp);
        });
      },
      children: pickerItems,
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change user'),
        automaticallyImplyLeading: true,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: ListView(
          children: <Widget>[
            Container(
              height: 120.0,
              alignment: Alignment.center,
              padding: EdgeInsets.only(bottom: 30.0),
              color: Colors.white,
              child: Platform.isIOS ? iOSPickerName() : androidDropdownName(),
            ),
            TextFormField(
              enabled: false,
              keyboardType: TextInputType.text,
              textAlign: TextAlign.center,
              onChanged: (value) {
                //Do something with the user input.
                name = value;
              },
              decoration: kTextFieldDecoration.copyWith(
                hintText: name,
              ),
            ),
            SizedBox(
              height: 8.0,
            ),
            TextFormField(
              enabled: false,
              keyboardType: TextInputType.emailAddress,
              textAlign: TextAlign.center,
              onChanged: (value) {
                //Do something with the user input.
                email = value;
              },
              decoration: kTextFieldDecoration.copyWith(
                hintText: email,
              ),
            ),
            SizedBox(
              height: 8.0,
            ),
            TextFormField(
              enabled: false,
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
                hintText: initials,
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
              height: 16.0,
            ),
            RoundedButton(
              color: Colors.lightBlueAccent,
              title: 'Confirm change',
              onPressed: () async {
                //change user functionality
                try {
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

                  Map empToChange = newEmployee.buildMap(
                      name,
                      email,
                      initials,
                      colorValueString,
                      selectedDepartment,
                      selectedSupportPosition);
                  dbController.changeUser(email, empToChange);

                  Navigator.pop(context);
                } catch (e) {
                  print(e);
                }
              },
            ),
            RoundedButton(
              color: Colors.red,
              title: 'Delete user',
              onPressed: () async {
                //change user functionality
                try {
                  showAlertDialog(context);
                } catch (e) {
                  print(e);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget deleteButton = FlatButton(
      child: Text("Delete User"),
      onPressed: () {
        setState(() {
          Employee empToDelete;
          dbController.deleteUser(email);
          for (Employee emp in listWithEmployees) {
            if (emp.email == email) empToDelete = emp;
          }
          listWithEmployees.remove(empToDelete);
          Navigator.pop(context);
          reassemble();
        });
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Delete user"),
      content: Text("Are you sure that you want to delete this user?"),
      actions: [
        cancelButton,
        deleteButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
