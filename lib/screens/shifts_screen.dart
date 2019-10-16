import 'dart:core';
import 'dart:math';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paybis_com_shifts/constants.dart';
import 'package:paybis_com_shifts/models/employee.dart';
import 'package:paybis_com_shifts/models/progress.dart';
import 'package:paybis_com_shifts/screens/it_days_off_screen.dart';
import 'package:paybis_com_shifts/screens/login_screen.dart';
import 'package:paybis_com_shifts/screens/recent_changes_screen.dart';
import 'package:paybis_com_shifts/screens/support_days_off_screen.dart';

import 'feed_screen.dart';
import 'parking_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';

//TODO implement ability to show holidays
//TODO Implement push notifications when shift is being changed or removed
//TODO Implement the ability for employees to mark shifts in the future they are not able to attend
//TODO Create calendar page with Vacations and Sick days for employees
FirebaseUser loggedInUser;
DocumentSnapshot currentDocument;
String shiftDocIDContainer1ForShiftExchange;
String shiftDocIDContainer2ForShiftExchange;
int shiftNumberContainer1ForShiftExchange;
int shiftNumberContainer2ForShiftExchange;
String shiftHolderContainer1ForShiftExchange;
String shiftHolderContainer2ForShiftExchange;
String shiftDateContainer1ForShiftExchange;
String shiftDateContainer2ForShiftExchange;
String shiftTypeContainer1ForShiftExchange;
String shiftTypeContainer2ForShiftExchange;

int _beginMonthPadding = 0;
DateTime timestamp = DateTime.now();
int selectedMonth = timestamp.month;
int workingHours;
String shiftExchangeMessage = '';
String highlighted = '';
List<Day> daysWithShiftsForCountThisMonth = List<Day>();
final shiftsScaffoldKey = new GlobalKey<ScaffoldState>();
final shiftsScreenKey = new GlobalKey<_ShiftScreenState>();
TextEditingController reasonTextInputController;

class ShiftScreen extends StatefulWidget {
  static const String id = 'shifts_screen';
  const ShiftScreen({Key key}) : super(key: key);
  @override
  _ShiftScreenState createState() => _ShiftScreenState();
}

class _ShiftScreenState extends State<ShiftScreen> {
  final _auth = FirebaseAuth.instance;
  @override
  void initState() {
    super.initState();
    reasonTextInputController = new TextEditingController();
  }

  void rebuild() {
    setState(() {});
  }

  @override
  void reassemble() {
    super.reassemble();
//    print("Reassemble method invoked");
    daysWithShiftsForCountThisMonth.clear();
  }

  @override
  Widget build(BuildContext context) {
    daysWithShiftsForCountThisMonth.clear();
//    print("Parent build method invoked");
    return Scaffold(
      key: shiftsScaffoldKey,
      backgroundColor: textIconColor,
//      bottomNavigationBar: BottomAppBar(
//        color: textPrimaryColor,
//        elevation: 10.0,
//      ),
      appBar: AppBar(
        backgroundColor: darkPrimaryColor,
        automaticallyImplyLeading: false,
        title: Text('PayBis Schedule'),
        actions: <Widget>[
          (employee.department != kAdmin)
              ? (employee.hasCar)
                  ? PopupMenuButton<String>(
                      color: textPrimaryColor.withOpacity(0.8),
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(10.0))),
                      itemBuilder: (BuildContext context) {
                        return kEmployeeWithCarChoicesPopupMenu
                            .map((String choice) {
                          return PopupMenuItem<String>(
                            value: choice,
                            child: Text(
                              choice,
                              style: TextStyle(
                                color: textIconColor,
                              ),
                            ),
                          );
                        }).toList();
                      },
                      onSelected: choicesAction,
                    )
                  : PopupMenuButton<String>(
                      color: textPrimaryColor.withOpacity(0.8),
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(10.0))),
                      itemBuilder: (BuildContext context) {
                        return kEmployeeChoicesPopupMenu.map((String choice) {
                          return PopupMenuItem<String>(
                            value: choice,
                            child: Text(
                              choice,
                              style: TextStyle(
                                color: textIconColor,
                              ),
                            ),
                          );
                        }).toList();
                      },
                      onSelected: choicesAction,
                    )
              : PopupMenuButton<String>(
                  color: textPrimaryColor.withOpacity(0.8),
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0))),
                  itemBuilder: (BuildContext context) {
                    return kAdminChoicesPopupMenu.map((String choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        child: Text(
                          choice,
                          style: TextStyle(
                            color: textIconColor,
                          ),
                        ),
                      );
                    }).toList();
                  },
                  onSelected: choicesAction,
                ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Table(
            border: TableBorder.all(
              color: secondaryColor,
            ),
            columnWidths: {
              0: FlexColumnWidth(0.15),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(1),
              3: FlexColumnWidth(1),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(color: darkPrimaryColor),
                children: [
                  TableCell(
                    child: Text(
                      'D',
                      style: kHeaderFontStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  TableCell(
                    child: Text(
                      '23:30-7:30',
                      style: kHeaderFontStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  TableCell(
                    child: Text(
                      '7:30-15:30',
                      style: kHeaderFontStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  TableCell(
                    child: Text(
                      '15:30-23:30',
                      style: kHeaderFontStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              )
            ],
          ),
          DaysStream(month: selectedMonth),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 10,
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 16.0, right: 4.0, top: 8.0, bottom: 8.0),
                  child: Material(
                    elevation: 5.0,
                    color: darkPrimaryColor,
                    borderRadius: BorderRadius.circular(15.0),
                    child: MaterialButton(
                      onPressed: () {
                        setState(() {
                          if (selectedMonth == 1) selectedMonth = 13;
                          selectedMonth = selectedMonth - 1;
                        });
                      },
                      child: Text(
                        'prev month',
                        style: kButtonFontStyle,
                      ),
                    ),
                  ),
                ),
              ),

              Expanded(
                flex: 9,
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 4.0, right: 4.0, top: 8.0, bottom: 8.0),
                  child: Material(
                    elevation: 5.0,
                    color: secondaryColor,
                    borderRadius: BorderRadius.circular(15.0),
                    child: MaterialButton(
                      child: Text(
                        getMonthName(selectedMonth),
                        style: kButtonFontStyle,
                      ),
                    ),
                  ),
                ),
              ),

//ADD MONTH Button
//              Padding(
//                padding: const EdgeInsets.all(8.0),
//                child: MaterialButton(
//                  onPressed: () {
//                    setState(() async {
//                      for (int i = 1;
//                          i <= getNumberOfDaysInMonth(timestamp.month + 1);
//                          i++) {
//                        Day newDay = new Day(i, 11, 19, 211119, {
//                          'holder': '',
//                          'id': '${i}061',
//                          'type': 'night',
//                          'hours': 8
//                        }, {
//                          'holder': '',
//                          'id': '${i}062',
//                          'type': 'night',
//                          'hours': 8
//                        }, {
//                          'holder': '',
//                          'id': '${i}063',
//                          'type': 'night',
//                          'hours': 8
//                        }, {
//                          'holder': '',
//                          'id': '${i}064',
//                          'type': 'morning',
//                          'hours': 8
//                        }, {
//                          'holder': '',
//                          'id': '${i}065',
//                          'type': 'morning',
//                          'hours': 8
//                        }, {
//                          'holder': '',
//                          'id': '${i}066',
//                          'type': 'morning',
//                          'hours': 8
//                        }, {
//                          'holder': '',
//                          'id': '${i}067',
//                          'type': 'evening',
//                          'hours': 8
//                        }, {
//                          'holder': '',
//                          'id': '${i}068',
//                          'type': 'evening',
//                          'hours': 8
//                        }, {
//                          'holder': '',
//                          'id': '${i}069',
//                          'type': 'evening',
//                          'hours': 8
//                        });
//                        Map dayMap = newDay.buildMap(i, 11, 2019, 211019, {
//                          'holder': '',
//                          'id': '${newDay.day}${newDay.month}${newDay.year}1',
//                          'type': 'night',
//                          'hours': 8
//                        }, {
//                          'holder': '',
//                          'id': '${newDay.day}${newDay.month}${newDay.year}2',
//                          'type': 'night',
//                          'hours': 8
//                        }, {
//                          'holder': '',
//                          'id': '${newDay.day}${newDay.month}${newDay.year}3',
//                          'type': 'night',
//                          'hours': 8
//                        }, {
//                          'holder': '',
//                          'id': '${newDay.day}${newDay.month}${newDay.year}4',
//                          'type': 'morning',
//                          'hours': 8
//                        }, {
//                          'holder': '',
//                          'id': '${newDay.day}${newDay.month}${newDay.year}5',
//                          'type': 'morning',
//                          'hours': 8
//                        }, {
//                          'holder': '',
//                          'id': '${newDay.day}${newDay.month}${newDay.year}6',
//                          'type': 'morning',
//                          'hours': 8
//                        }, {
//                          'holder': '',
//                          'id': '${newDay.day}${newDay.month}${newDay.year}7',
//                          'type': 'evening',
//                          'hours': 8
//                        }, {
//                          'holder': '',
//                          'id': '${newDay.day}${newDay.month}${newDay.year}8',
//                          'type': 'evening',
//                          'hours': 8
//                        }, {
//                          'holder': '',
//                          'id': '${newDay.day}${newDay.month}${newDay.year}9',
//                          'type': 'evening',
//                          'hours': 8
//                        });
//                        await dbController.addMonth(dayMap);
//                      }
//                    });
//                  },
//                  color: Colors.lightBlue,
//                  child: Text(
//                    'add month',
//                    style: kHeaderFontStyle,
//                  ),
//                ),
//              ),
              Expanded(
                flex: 10,
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 4.0, right: 16.0, top: 8.0, bottom: 8.0),
                  child: Material(
                    elevation: 5.0,
                    color: darkPrimaryColor,
                    borderRadius: BorderRadius.circular(15.0),
                    child: MaterialButton(
                      onPressed: () {
                        setState(() {
                          if (selectedMonth == 12) selectedMonth = 0;
                          selectedMonth = selectedMonth + 1;
                        });
                      },
                      child: Text(
                        'next month',
                        style: kButtonFontStyle,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  void choicesAction(String choice) {
    if (choice == kStats) {
      Navigator.pushNamed(context, StatsScreen.id);
    }
    if (choice == kSettings) {
      Navigator.pushNamed(context, SettingsScreen.id);
    }
    if (choice == kItDaysOff) {
      Navigator.pushNamed(context, ItDaysOffScreen.id);
    }
    if (choice == kParking) {
      Navigator.pushNamed(context, ParkingScreen.id);
    }
    if (choice == kSupportDaysOff) {
      Navigator.pushNamed(context, SupportDaysOffScreen.id);
    }
    if (choice == kChangeRequests) {
      Navigator.pushNamed(context, FeedScreen.id);
    }
    if (choice == kRecentChanges) {
      Navigator.pushNamed(context, RecentChangesScreen.id);
    }

    if (choice == kLogOut) {
      employee = null;
      _auth.signOut();
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (BuildContext context) {
        return LoginScreen();
      }));
    }
  }
}

class DaysStream extends StatelessWidget {
  final int month;

  DaysStream({@required this.month});

  @override
  Widget build(BuildContext context) {
//    print("Child build method invoked");
    if (daysWithShiftsForCountThisMonth.isNotEmpty)
      daysWithShiftsForCountThisMonth.clear();
    return StreamBuilder<QuerySnapshot>(
      stream: dbController.createDaysStream(month),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        final days = snapshot.data.documents;
        List<Widget> daysWithShifts = [];
        for (var day in days) {
          final int dayDay = day.data['day'];
          final int dayMonth = day.data['month'];
          final int dayYear = day.data['year'];
          final int dayId = day.data['id'];
          currentDocument = day;
          final String dayDocumentID = day.documentID;

          Map<dynamic, dynamic> shift1 = day.data['1'];
          Map<dynamic, dynamic> shift2 = day.data['2'];
          Map<dynamic, dynamic> shift3 = day.data['3'];
          Map<dynamic, dynamic> shift4 = day.data['4'];
          Map<dynamic, dynamic> shift5 = day.data['5'];
          Map<dynamic, dynamic> shift6 = day.data['6'];
          Map<dynamic, dynamic> shift7 = day.data['7'];
          Map<dynamic, dynamic> shift8 = day.data['8'];
          Map<dynamic, dynamic> shift9 = day.data['9'];

          String idNightShift0 = day.data['1']['id'];
          String idNightShift1 = day.data['2']['id'];
          String idNightShift2 = day.data['3']['id'];
          String idMorningShift0 = day.data['4']['id'];
          String idMorningShift1 = day.data['5']['id'];
          String idMorningShift2 = day.data['6']['id'];
          String idEveningShift0 = day.data['7']['id'];
          String idEveningShift1 = day.data['8']['id'];
          String idEveningShift2 = day.data['9']['id'];

          final dayWithShifts = Day(dayDay, dayMonth, dayYear, dayId, shift1,
              shift2, shift3, shift4, shift5, shift6, shift7, shift8, shift9);

          if (!daysWithShiftsForCountThisMonth.contains(dayWithShifts) &&
              daysWithShiftsForCountThisMonth.length <
                  getNumberOfDaysInMonth(selectedMonth))
            daysWithShiftsForCountThisMonth.add(dayWithShifts);

          final dayWithShiftsUI = Table(
            border: TableBorder.all(
              color: textPrimaryColor,
            ),
            columnWidths: {
              0: FlexColumnWidth(0.15),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(1),
              3: FlexColumnWidth(1),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(
                  color: ('${dayWithShifts.day}${dayWithShifts.month}' ==
                          '${DateTime.now().day}${DateTime.now().month}')
                      ? primaryColor.withOpacity(0.4)
                      : Colors.white,
                ),
                children: [
                  DateTableCell(
                    day: dayWithShifts.day,
                    month: dayWithShifts.month,
                    year: dayWithShifts.year,
                  ),
                  TableCell(
                    child: Container(
                      color: Colors.indigo.shade100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          ShiftsRoundButton(
                            key: ObjectKey(idNightShift0),
                            day: dayWithShifts.day,
                            month: dayWithShifts.month,
                            id: dayWithShifts.s1['id'],
                            text: dayWithShifts.s1['holder'],
                            workingHours: dayWithShifts.s1['hours'],
                            documentID: dayDocumentID,
                            number: 1,
                          ),
                          ShiftsRoundButton(
                            key: ObjectKey(idNightShift1),
                            day: dayWithShifts.day,
                            month: dayWithShifts.month,
                            id: dayWithShifts.s2['id'],
                            text: dayWithShifts.s2['holder'],
                            workingHours: dayWithShifts.s2['hours'],
                            documentID: dayDocumentID,
                            number: 2,
                          ),
                          ShiftsRoundButton(
                            key: ObjectKey(idNightShift2),
                            day: dayWithShifts.day,
                            month: dayWithShifts.month,
                            id: dayWithShifts.s3['id'],
                            text: dayWithShifts.s3['holder'],
                            workingHours: dayWithShifts.s3['hours'],
                            documentID: dayDocumentID,
                            number: 3,
                          ),
                        ],
                      ),
                    ),
                  ),
                  TableCell(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        ShiftsRoundButton(
                          key: ObjectKey(idMorningShift0),
                          day: dayWithShifts.day,
                          month: dayWithShifts.month,
                          id: dayWithShifts.s4['id'],
                          text: dayWithShifts.s4['holder'],
                          workingHours: dayWithShifts.s4['hours'],
                          documentID: dayDocumentID,
                          number: 4,
                        ),
                        ShiftsRoundButton(
                          key: ObjectKey(idMorningShift1),
                          day: dayWithShifts.day,
                          month: dayWithShifts.month,
                          id: dayWithShifts.s5['id'],
                          text: dayWithShifts.s5['holder'],
                          workingHours: dayWithShifts.s5['hours'],
                          documentID: dayDocumentID,
                          number: 5,
                        ),
                        ShiftsRoundButton(
                          key: ObjectKey(idMorningShift2),
                          day: dayWithShifts.day,
                          month: dayWithShifts.month,
                          id: dayWithShifts.s6['id'],
                          text: dayWithShifts.s6['holder'],
                          workingHours: dayWithShifts.s6['hours'],
                          documentID: dayDocumentID,
                          number: 6,
                        ),
                      ],
                    ),
                  ),
                  TableCell(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        ShiftsRoundButton(
                          key: ObjectKey(idEveningShift0),
                          day: dayWithShifts.day,
                          month: dayWithShifts.month,
                          id: dayWithShifts.s7['id'],
                          text: dayWithShifts.s7['holder'],
                          workingHours: dayWithShifts.s7['hours'],
                          documentID: dayDocumentID,
                          number: 7,
                        ),
                        ShiftsRoundButton(
                          key: ObjectKey(idEveningShift1),
                          day: dayWithShifts.day,
                          month: dayWithShifts.month,
                          id: dayWithShifts.s8['id'],
                          text: dayWithShifts.s8['holder'],
                          workingHours: dayWithShifts.s8['hours'],
                          documentID: dayDocumentID,
                          number: 8,
                        ),
                        ShiftsRoundButton(
                          key: ObjectKey(idEveningShift2),
                          day: dayWithShifts.day,
                          month: dayWithShifts.month,
                          id: dayWithShifts.s9['id'],
                          text: dayWithShifts.s9['holder'],
                          workingHours: dayWithShifts.s9['hours'],
                          documentID: dayDocumentID,
                          number: 9,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
          daysWithShifts.add(dayWithShiftsUI);

          if (weekdayCheck(dayDay, dayMonth, dayYear) == 7) {
            final divider = SizedBox(
              height: 15.0,
            );
            daysWithShifts.add(divider);
          }
        }
        return Expanded(
          child: ListView(
            reverse: false,
            children: daysWithShifts,
          ),
        );
      },
    );
  }
}

class DateTableCell extends StatelessWidget {
  final int day;
  final int month;
  final int year;

  DateTableCell(
      {@required this.day, @required this.month, @required this.year});

  @override
  Widget build(BuildContext context) {
    int weekDay = weekdayCheck(day, month, year);
    bool isWeekend = false;

    if (weekDay == 6 || weekDay == 7) isWeekend = true;
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Column(
        children: <Widget>[
          Transform.rotate(
            angle: pi * 1.5,
            child: Text(
              '$month',
              style: TextStyle(
                fontSize: 11.0,
                fontWeight: FontWeight.bold,
                color: isWeekend ? accentColor : textPrimaryColor,
              ),
            ),
          ),
          Transform.rotate(
            angle: pi * 1.5,
            child: Text(
              '$day.',
              style: TextStyle(
                fontSize: 11.0,
                fontWeight: FontWeight.bold,
                color: isWeekend ? accentColor : textPrimaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ShiftsRoundButton extends StatefulWidget {
  final String id;
  final int day;
  final int month;
  final int number;
  final String text;
  final String documentID;
  final int workingHours;

  ShiftsRoundButton(
      {@required Key key,
      @required this.id,
      @required this.day,
      @required this.month,
      @required this.number,
      @required this.text,
      @required this.documentID,
      @required this.workingHours})
      : super(key: ObjectKey(id));

  @override
  _ShiftsRoundButtonState createState() => _ShiftsRoundButtonState();
}

class _ShiftsRoundButtonState extends State<ShiftsRoundButton> {
  Color color = primaryColor;
  String buttonText = '+';
  double size = 26.0;
  double bottom = 5.0;
  double right = 1.0;
  String buttonHolder;
  bool employeeChosen = false;
  String id;
  String documentID;
  int number;
  String date;
  bool isPast = false;
//  PopupEmployeesLayout popupEmployeesLayout = PopupEmployeesLayout();

  @override
  Widget build(BuildContext context) {
    bool isLong = false;
    id = widget.id;
    date = '${widget.day}.${widget.month}';
    documentID = widget.documentID;
    number = widget.number;
    widget.text == '' ? employeeChosen = false : employeeChosen = true;
    if (widget.text.length == 3) isLong = true;
    if ((widget.day < DateTime.now().day &&
            widget.month <= DateTime.now().month) ||
        widget.month < DateTime.now().month) isPast = true;

    for (Employee emp in listWithEmployees) {
      //Converting String to Color
      if (emp.initial == widget.text) {
        color = convertColor(emp.empColor);
      }
    }

// if USER is Admin "and not in the Past"(disabled) build this
    return (employee.department == kAdmin
//        && isPast == false
        )
        ? SizedBox(
            width: 30.0,
            child: employeeChosen == false

                //If Emp is NOT chosen

                ? MaterialButton(
                    onPressed: () {
                      setState(() {
                        showAdminAlertDialog(context, widget.id, documentID,
                            number, widget.workingHours, "Who's gonna work?");
                      });
                    },
                    color: textIconColor,
                    shape: CircleBorder(),
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 3.0, right: 0.0),
                      child: Text(
                        buttonText,
                        style: TextStyle(
                          fontSize: size,
                          color: textPrimaryColor,
                        ),
                      ),
                    ),
                    padding: EdgeInsets.all(0.0),
                    minWidth: 10.0,
                  )

                //If Emp is chosen

                : MaterialButton(
                    onPressed: () {
                      setState(() {
                        showAdminAlertDialog(context, widget.id, documentID,
                            number, widget.workingHours, "Who's gonna work?");
                      });
                    },
                    color: color,
                    shape: CircleBorder(),
                    child: (widget.workingHours != 8)
                        ? Stack(
                            alignment: AlignmentDirectional.center,
                            children: <Widget>[
                              Text(
                                widget.text,
                                style: TextStyle(
                                  fontSize: isLong ? 13.0 : 16.0,
                                  color: textIconColor,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 24.0, left: 24.0),
                                child: Text(
                                  (widget.workingHours < 8) ? '-' : '+',
                                  style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                      color: (widget.workingHours < 8)
                                          ? accentColor
                                          : Colors.green),
                                ),
                              )
                            ],
                          )
                        : Text(
                            widget.text,
                            style: TextStyle(
                              fontSize: isLong ? 13.0 : 16.0,
                              color: textIconColor,
                            ),
                          ),
                    padding: EdgeInsets.all(0.0),
                    minWidth: 10.0,
                  ),
          )

        // if user is NOT Admin or in the past build this

        : SizedBox(
            width: 30.0,
            child: employeeChosen == false

                //If Emp is NOT chosen

                ? MaterialButton(
                    //  onPressed: () {
                    //  },

                    color: primaryColor,
                    shape: CircleBorder(),
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 0.0, right: 0.0),
                      child: Text(
                        '',
                        style: TextStyle(
                          fontSize: size,
                          color: textIconColor,
                        ),
                      ),
                    ),
                    padding: EdgeInsets.all(0.0),
                    minWidth: 10.0,
                  )

                //If Emp is chosen
                : Padding(
                    padding: EdgeInsets.symmetric(vertical: 1.8),
                    child: Material(
                        color: (employee != null)
                            ? (widget.text == employee.initial)
                                ? textPrimaryColor
                                : color.withOpacity(0)
                            : color.withOpacity(0),
                        borderRadius: BorderRadius.circular(15.0),
                        child: MaterialButton(
                          onPressed: () {
                            setState(() {
                              if (widget.text == employee.initial &&
                                  isPast == false &&
                                  shiftDocIDContainer1ForShiftExchange ==
                                      null &&
                                  shiftNumberContainer1ForShiftExchange ==
                                      null &&
                                  shiftHolderContainer1ForShiftExchange ==
                                      null) {
                                openPersonalShiftAlertBox(context, widget.id,
                                    documentID, number, date, 'Exchange?');
                              }
                              if (isPast == false &&
                                  widget.text != employee.initial &&
                                  shiftDocIDContainer1ForShiftExchange !=
                                      null &&
                                  shiftNumberContainer1ForShiftExchange !=
                                      null &&
                                  shiftHolderContainer1ForShiftExchange !=
                                      null) {
                                openChangeShiftsConfirmationAlertBox(
                                  context,
                                  widget.id,
                                  documentID,
                                  number,
                                  date,
                                  'Exchange with ${widget.text}?',
                                  widget.text,
                                );
                              }

                              if (widget.text != employee.initial &&
                                  highlighted == '' &&
                                  shiftDocIDContainer1ForShiftExchange ==
                                      null &&
                                  shiftNumberContainer1ForShiftExchange ==
                                      null &&
                                  shiftHolderContainer1ForShiftExchange ==
                                      null) {
//                                setState(() {
                                highlightEmp(widget.text);
                                shiftsScreenKey.currentState.rebuild();
//                                });
                              } else {
//                                setState(() {
                                deHighlightEmp();
                                shiftsScreenKey.currentState.rebuild();
//                                });
                              }
                            });
                          },
                          color: (employee != null)
                              ? (widget.text == employee.initial)
                                  ? darkPrimaryColor
                                  : (widget.text == highlighted)
                                      ? textPrimaryColor
                                      : color.withOpacity(0.25)
                              : color,
                          shape: CircleBorder(),
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 0.0, right: 0.0),
                            child: (widget.workingHours != 8)
                                ? Stack(
                                    alignment: AlignmentDirectional.center,
                                    children: <Widget>[
                                      Text(
                                        widget.text,
                                        style: TextStyle(
                                          fontSize: isLong ? 13.0 : 16.0,
                                          color: textIconColor,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 24.0, left: 24.0),
                                        child: Text(
                                          (widget.workingHours < 8) ? '-' : '+',
                                          style: TextStyle(
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.bold,
                                              color: (widget.workingHours < 8)
                                                  ? accentColor
                                                  : Colors.green),
                                        ),
                                      )
                                    ],
                                  )
                                : Text(
                                    widget.text,
                                    style: TextStyle(
                                      fontSize: isLong ? 13.0 : 16.0,
                                      color: textIconColor,
                                    ),
                                  ),
                          ),
                          padding: EdgeInsets.all(0.0),
                          minWidth: 10.0,
                        ))));
  }
}

void highlightEmp(String initials) {
//  print('Highlight $highlighted');
  highlighted = initials;
//  print(highlighted);
}

void deHighlightEmp() {
//  print(' DeHighlight $highlighted');

  highlighted = '';
//  print(highlighted);
}

void updateShiftExchangeValuesToNull() {
  shiftDocIDContainer1ForShiftExchange = null;
  shiftDocIDContainer2ForShiftExchange = null;
  shiftHolderContainer1ForShiftExchange = null;
  shiftHolderContainer2ForShiftExchange = null;
  shiftNumberContainer1ForShiftExchange = null;
  shiftNumberContainer2ForShiftExchange = null;
  shiftDateContainer1ForShiftExchange = null;
  shiftDateContainer2ForShiftExchange = null;
  shiftTypeContainer1ForShiftExchange = null;
  shiftTypeContainer2ForShiftExchange = null;
  shiftExchangeMessage = '';
  reasonTextInputController.clear();
}

///ADMIN ALERT DIALOG
///
showAdminAlertDialog(
  BuildContext context,
  String id,
  String docID,
  int number,
  int workingHoursFromWidget,
  String title,
) {
  final result = showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(32.0))),
        content: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Center(
                child: Text(
                  'Who is going to work?',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                ),
              ),
              SizedBox(
                height: 5.0,
              ),
              Wrap(
                alignment: WrapAlignment.spaceEvenly,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: listMyWidgets(context),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: 10.0),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 15.0, top: 8.0, right: 4.0, bottom: 18.0),
                        child: Text(
                          'Update working hours for this shift (at this moment: $workingHoursFromWidget)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40.0),
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 2,
                          decoration: kTextFieldDecoration.copyWith(
                            hintText: '$workingHoursFromWidget',
                          ),
                          onChanged: (value) {
                            //Do something with the user input.
                            workingHours = int.parse(value);
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Material(
                          elevation: 5.0,
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(15.0),
                          child: MaterialButton(
                            child: Text(
                              'Update',
                              style: TextStyle(
                                fontSize: 16.0,
                                color: textIconColor,
                              ),
                            ),
                            onPressed: () async {
                              currentDocument =
                                  await dbController.getDocument(docID);
                              await dbController.updateHours(
                                  currentDocument, number, workingHours);
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
  result.then((result) async {
    if (result == null || result == '') {
      result = '+';
    } else {
      currentDocument = await dbController.getDocument(docID);

      String choiceOfEmployee = result.toString();

      if (choiceOfEmployee == 'none') {
        await dbController.updateHolderToNone(currentDocument, number);
      } else
        await dbController.updateHolder(
            currentDocument, number, choiceOfEmployee);
    }
  });
}

List<Widget> listMyWidgets(BuildContext context) {
  List<Widget> list = List();
  for (Employee emp in listWithEmployees) {
    if (emp.department == kSupportDepartment) {
      list.add(
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: Material(
            elevation: 5.0,
            color: convertColor(emp.empColor),
            borderRadius: BorderRadius.circular(15.0),
            child: MaterialButton(
              minWidth: 100.0,
              onPressed: () {
                Navigator.pop(context, emp.initial);
              },
              child: Text(
                emp.name,
                style: TextStyle(
                  fontSize: (emp.name.length <= 7) ? 17.0 : 14.0,
                  color: textIconColor,
                ),
              ),
            ),
          ),
        ),
      );
    }
  }
  list.add(Padding(
    padding: const EdgeInsets.all(5.0),
    child: Material(
      elevation: 5.0,
      color: textPrimaryColor,
      borderRadius: BorderRadius.circular(15.0),
      child: MaterialButton(
        onPressed: () {
          Navigator.pop(context, 'none');
        },
        child: Text(
          'none',
          style: kHeaderFontStyle,
        ),
      ),
    ),
  ));
  return list;
}

openPersonalShiftAlertBox(BuildContext context, String id, String docID,
    int number, String date, String title) {
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
                  color: dividerColor,
                  height: 4.0,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 30.0, right: 30.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Type the reason here",
                      border: InputBorder.none,
                    ),
                    maxLines: 5,
                    controller: reasonTextInputController,
                  ),
                ),
                GestureDetector(
                  onTap: () {
//                        FocusScopeNode currentScope = FocusScope.of(context);
//                        currentScope.unfocus();

                    Navigator.pop(context);
                    chooseShiftToExchange();
                    shiftDocIDContainer1ForShiftExchange = docID;
                    shiftNumberContainer1ForShiftExchange = number;
                    shiftHolderContainer1ForShiftExchange = employee.initial;
                    shiftDateContainer1ForShiftExchange = date;
                    shiftExchangeMessage = reasonTextInputController.text;
                    reasonTextInputController.clear();
                    if (number < 4) {
                      shiftTypeContainer1ForShiftExchange = 'night';
                    } else if (number > 5) {
                      shiftTypeContainer1ForShiftExchange = 'evening';
                    } else {
                      shiftTypeContainer1ForShiftExchange = 'morning';
                    }
                  },
                  child: InkWell(
                    child: Container(
                      padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(32.0),
                            bottomRight: Radius.circular(32.0)),
                      ),
                      child: Text(
                        "Exchange",
                        style: TextStyle(
                            color: textIconColor,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      });
}

openChangeShiftsConfirmationAlertBox(BuildContext context, String id,
    String docID, int number, String date, String title, String initials) {
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
                  color: dividerColor,
                  height: 4.0,
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          shiftDocIDContainer2ForShiftExchange = docID;
                          shiftNumberContainer2ForShiftExchange = number;
                          shiftHolderContainer2ForShiftExchange = initials;
                          shiftDateContainer2ForShiftExchange = date;
                          if (number < 4) {
                            shiftTypeContainer2ForShiftExchange = 'night';
                          } else if (number > 5) {
                            shiftTypeContainer2ForShiftExchange = 'evening';
                          } else {
                            shiftTypeContainer2ForShiftExchange = 'morning';
                          }
                          dbController.addChangeRequestToAdminFeed(
                              shiftDocIDContainer1ForShiftExchange,
                              shiftDocIDContainer2ForShiftExchange,
                              shiftNumberContainer1ForShiftExchange,
                              shiftNumberContainer2ForShiftExchange,
                              shiftHolderContainer1ForShiftExchange,
                              shiftHolderContainer2ForShiftExchange,
                              shiftDateContainer1ForShiftExchange,
                              shiftDateContainer2ForShiftExchange,
                              shiftTypeContainer1ForShiftExchange,
                              shiftTypeContainer2ForShiftExchange,
                              shiftExchangeMessage);

                          updateShiftExchangeValuesToNull();
                          Navigator.pop(context);
                          showConfirmationMessage();
                        },
                        child: InkWell(
                          child: Container(
                            padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(32.0),
                              ),
                            ),
                            child: Text(
                              "Yes",
                              style: TextStyle(
                                  color: textIconColor,
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
                          updateShiftExchangeValuesToNull();
                          Navigator.pop(context);
                          showCancelMessage();
                        },
                        child: InkWell(
                          child: Container(
                            padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                            decoration: BoxDecoration(
                              color: accentColor,
                              borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(32.0)),
                            ),
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                  color: textIconColor,
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

class Day {
  int day;
  int month;
  int year;
  int id;
  Map s1 = {'holder': '', 'id': '', 'type': '', 'hours': 8};
  Map s2 = {'holder': '', 'id': '', 'type': '', 'hours': 8};
  Map s3 = {'holder': '', 'id': '', 'type': '', 'hours': 8};
  Map s4 = {'holder': '', 'id': '', 'type': '', 'hours': 8};
  Map s5 = {'holder': '', 'id': '', 'type': '', 'hours': 8};
  Map s6 = {'holder': '', 'id': '', 'type': '', 'hours': 8};
  Map s7 = {'holder': '', 'id': '', 'type': '', 'hours': 8};
  Map s8 = {'holder': '', 'id': '', 'type': '', 'hours': 8};
  Map s9 = {'holder': '', 'id': '', 'type': '', 'hours': 8};

  Day(this.day, this.month, this.year, this.id, this.s1, this.s2, this.s3,
      this.s4, this.s5, this.s6, this.s7, this.s8, this.s9);
  Day.year(this.year);

  Map buildMap(int day, int month, int year, int id, Map s1, Map s2, Map s3,
      Map s4, Map s5, Map s6, Map s7, Map s8, Map s9) {
    Map map = {
      'id': id,
      'day': day,
      'month': month,
      'year': year,
      '1': s1,
      '2': s2,
      '3': s3,
      '4': s4,
      '5': s5,
      '6': s6,
      '7': s7,
      '8': s8,
      '9': s9
    };

    return map;
  }
}

String getEmployeeName(String initials) {
  String result = '';
  for (Employee emp in listWithEmployees) {
    if (initials == emp.initial) result = emp.name;
  }
  return result;
}

int getNumberOfDaysInMonth(final int month) {
  int numDays = 28;

  // Months are 1, ..., 12
  switch (month) {
    case 1:
      numDays = 31;
      break;
    case 2:
      numDays = 28;
      break;
    case 3:
      numDays = 31;
      break;
    case 4:
      numDays = 30;
      break;
    case 5:
      numDays = 31;
      break;
    case 6:
      numDays = 30;
      break;
    case 7:
      numDays = 31;
      break;
    case 8:
      numDays = 31;
      break;
    case 9:
      numDays = 30;
      break;
    case 10:
      numDays = 31;
      break;
    case 11:
      numDays = 30;
      break;
    case 12:
      numDays = 31;
      break;
    default:
      numDays = 28;
  }
  return numDays + _beginMonthPadding;
}

String getMonthName(final int month) {
  // Months are 1, ..., 12
  switch (month) {
    case 1:
      return "January";
    case 2:
      return "February";
    case 3:
      return "March";
    case 4:
      return "April";
    case 5:
      return "May";
    case 6:
      return "June";
    case 7:
      return "July";
    case 8:
      return "August";
    case 9:
      return "September";
    case 10:
      return "October";
    case 11:
      return "November";
    case 12:
      return "December";
    default:
      return "Unknown";
  }
}

int weekdayCheck(int day, int month, int year) {
  int weekday = new DateTime(year, month, day).weekday;
  return weekday;
}

void chooseShiftToExchange() {
  shiftsScaffoldKey.currentState.showSnackBar(
      new SnackBar(content: new Text("Choose The Shift You Want")));
}

void showConfirmationMessage() {
  shiftsScaffoldKey.currentState.showSnackBar(
      new SnackBar(content: new Text("Your request has been sent to admin")));
}

void showCancelMessage() {
  shiftsScaffoldKey.currentState.showSnackBar(
      new SnackBar(content: new Text("Shift exchange cancelled")));
}

Color convertColor(String color) {
  int colorValueInt = int.parse(color, radix: 16);
  Color otherColor = new Color(colorValueInt);
  return otherColor;
}
