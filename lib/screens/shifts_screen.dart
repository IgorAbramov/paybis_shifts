import 'dart:math';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paybis_com_shifts/constants.dart';
import 'package:paybis_com_shifts/controller/db_controller.dart';
import 'package:paybis_com_shifts/models/employee.dart';

import 'changes_log_screen.dart';
import 'personal_panel_screen.dart';

//TODO implement ability to show holidays
//TODO Implement push notifications when shift is being changed or removed
//TODO Implement the ability for employees to mark shifts in the future they are not able to attend
//TODO Create calendar page with Vacations and Sick days for employees

final _fireStore = Firestore.instance;
FirebaseUser loggedInUser;
DocumentSnapshot _currentDocument;
int _beginMonthPadding = 0;
DateTime _dateTime = DateTime.now();
int selectedMonth = _dateTime.month;
Employee employee;
List<Day> daysWithShiftsForCountThisMonth = List<Day>();
List<Day> daysWithShiftsForCountLastMonth = List<Day>();
final dbController = DBController();

class ShiftScreen extends StatefulWidget {
  static const String id = 'shifts_screen';
  @override
  _ShiftScreenState createState() => _ShiftScreenState();
}

class _ShiftScreenState extends State<ShiftScreen> {
  final _auth = FirebaseAuth.instance;

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
        for (Employee emp in employees) {
          if (emp.email == loggedInUser.email) employee = emp;
        }
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    print("InitState method invoked");
    getCurrentUser();
    dbController.getDays();
  }

  @override
  void reassemble() {
    super.reassemble();
    print("Reassemble method invoked");
    daysWithShiftsForCountThisMonth.clear();
  }

  @override
  Widget build(BuildContext context) {
    daysWithShiftsForCountThisMonth.clear();
    print("Parent build method invoked");
    return Scaffold(
      appBar: AppBar(
        title: Text('PayBis Schedule'),
        actions: <Widget>[
          PopupMenuButton<String>(
            itemBuilder: (BuildContext context) {
              return kChoicesPopupMenu.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
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
            border: TableBorder.all(),
            columnWidths: {
              0: FlexColumnWidth(0.15),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(1),
              3: FlexColumnWidth(1),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(color: Colors.blue),
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: MaterialButton(
                  onPressed: () {
                    setState(() {
                      selectedMonth = selectedMonth - 1;
                    });
                  },
                  color: Colors.lightBlue,
                  child: Text(
                    'prev month',
                    style: kHeaderFontStyle,
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
//                          i <= getNumberOfDaysInMonth(_dateTime.month + 1);
//                          i++) {
//                        Day newDay = new Day(
//                            i,
//                            9,
//                            19,
//                            210919,
//                            {'holder': '', 'id': '${i}061}', 'type': 'night'},
//                            {'holder': '', 'id': '${i}062', 'type': 'night'},
//                            {'holder': '', 'id': '${i}063', 'type': 'night'},
//                            {'holder': '', 'id': '${i}064', 'type': 'morning'},
//                            {'holder': '', 'id': '${i}065', 'type': 'morning'},
//                            {'holder': '', 'id': '${i}066', 'type': 'morning'},
//                            {'holder': '', 'id': '${i}067', 'type': 'evening'},
//                            {'holder': '', 'id': '${i}068', 'type': 'evening'},
//                            {'holder': '', 'id': '${i}069', 'type': 'evening'});
//                        Map dayMap = newDay.buildMap(i, 9, 2019, 210919, {
//                          'holder': '',
//                          'id': '${newDay.day}${newDay.month}${newDay.year}1',
//                          'type': 'night'
//                        }, {
//                          'holder': '',
//                          'id': '${newDay.day}${newDay.month}${newDay.year}2',
//                          'type': 'night'
//                        }, {
//                          'holder': '',
//                          'id': '${newDay.day}${newDay.month}${newDay.year}3',
//                          'type': 'night'
//                        }, {
//                          'holder': '',
//                          'id': '${newDay.day}${newDay.month}${newDay.year}4',
//                          'type': 'morning'
//                        }, {
//                          'holder': '',
//                          'id': '${newDay.day}${newDay.month}${newDay.year}5',
//                          'type': 'morning'
//                        }, {
//                          'holder': '',
//                          'id': '${newDay.day}${newDay.month}${newDay.year}6',
//                          'type': 'morning'
//                        }, {
//                          'holder': '',
//                          'id': '${newDay.day}${newDay.month}${newDay.year}7',
//                          'type': 'evening'
//                        }, {
//                          'holder': '',
//                          'id': '${newDay.day}${newDay.month}${newDay.year}8',
//                          'type': 'evening'
//                        }, {
//                          'holder': '',
//                          'id': '${newDay.day}${newDay.month}${newDay.year}9',
//                          'type': 'evening'
//                        });
//                        await _fireStore
//                            .collection('days')
//                            .document()
//                            .setData(Map<String, dynamic>.from(dayMap));
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: MaterialButton(
                  onPressed: () {
                    setState(() {
                      selectedMonth = selectedMonth + 1;
                    });
                  },
                  color: Colors.lightBlue,
                  child: Text(
                    'next month',
                    style: kHeaderFontStyle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void choicesAction(String choice) {
    if (choice == kPersonalPanel) {
      if (employee != null)
        Navigator.pushNamed(context, PersonalPanelScreen.id);
    }
    if (choice == kSettings) {}
    if (choice == kItVacations) {}
    if (choice == kSupportVacations) {}
    if (choice == kChangesLog) {
      Navigator.pushNamed(context, ChangesLogScreen.id);
    }
    if (choice == kLogOut) {
      employee = null;
      _auth.signOut();
      Navigator.pop(context);
    }
  }
}

class DaysStream extends StatelessWidget {
  final int month;

  DaysStream({@required this.month});

  @override
  Widget build(BuildContext context) {
    print("Child build method invoked");
    if (daysWithShiftsForCountThisMonth.isNotEmpty)
      daysWithShiftsForCountThisMonth.clear();
    return StreamBuilder<QuerySnapshot>(
      stream: dbController.createStream(month),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        final days = snapshot.data.documents;
        List<Widget> daysWithShifts = [];
        for (var day in days) {
          final int dayDay = day.data['day'];
          final int dayMonth = day.data['month'];
          final int dayYear = day.data['year'];
          final int dayId = day.data['id'];
          _currentDocument = day;
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

//          String holderNightShift0 = day.data['1']['holder'];
//          String holderNightShift1 = day.data['2']['holder'];
//          String holderNightShift2 = day.data['3']['holder'];
//          String holderMorningShift0 = day.data['4']['holder'];
//          String holderMorningShift1 = day.data['5']['holder'];
//          String holderMorningShift2 = day.data['6']['holder'];
//          String holderEveningShift0 = day.data['7']['holder'];
//          String holderEveningShift1 = day.data['8']['holder'];
//          String holderEveningShift2 = day.data['9']['holder'];
//
//          String typeNightShift0 = day.data['1']['type'];
//          String typeNightShift1 = day.data['2']['type'];
//          String typeNightShift2 = day.data['3']['type'];
//          String typeMorningShift0 = day.data['4']['type'];
//          String typeMorningShift1 = day.data['5']['type'];
//          String typeMorningShift2 = day.data['6']['type'];
//          String typeEveningShift0 = day.data['7']['type'];
//          String typeEveningShift1 = day.data['8']['type'];
//          String typeEveningShift2 = day.data['9']['type'];

          final dayWithShifts = Day(dayDay, dayMonth, dayYear, dayId, shift1,
              shift2, shift3, shift4, shift5, shift6, shift7, shift8, shift9);

          if (!daysWithShiftsForCountThisMonth.contains(dayWithShifts) &&
              daysWithShiftsForCountThisMonth.length <
                  getNumberOfDaysInMonth(selectedMonth))
            daysWithShiftsForCountThisMonth.add(dayWithShifts);

          final dayWithShiftsUI = Table(
            border: TableBorder.all(),
            columnWidths: {
              0: FlexColumnWidth(0.15),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(1),
              3: FlexColumnWidth(1),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(
                  color: Colors.white,
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
                            documentID: dayDocumentID,
                            number: 1,
                          ),
                          ShiftsRoundButton(
                            key: ObjectKey(idNightShift1),
                            day: dayWithShifts.day,
                            month: dayWithShifts.month,
                            id: dayWithShifts.s2['id'],
                            text: dayWithShifts.s2['holder'],
                            documentID: dayDocumentID,
                            number: 2,
                          ),
                          ShiftsRoundButton(
                            key: ObjectKey(idNightShift2),
                            day: dayWithShifts.day,
                            month: dayWithShifts.month,
                            id: dayWithShifts.s3['id'],
                            text: dayWithShifts.s3['holder'],
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
                          documentID: dayDocumentID,
                          number: 4,
                        ),
                        ShiftsRoundButton(
                          key: ObjectKey(idMorningShift1),
                          day: dayWithShifts.day,
                          month: dayWithShifts.month,
                          id: dayWithShifts.s5['id'],
                          text: dayWithShifts.s5['holder'],
                          documentID: dayDocumentID,
                          number: 5,
                        ),
                        ShiftsRoundButton(
                          key: ObjectKey(idMorningShift2),
                          day: dayWithShifts.day,
                          month: dayWithShifts.month,
                          id: dayWithShifts.s6['id'],
                          text: dayWithShifts.s6['holder'],
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
                          documentID: dayDocumentID,
                          number: 7,
                        ),
                        ShiftsRoundButton(
                          key: ObjectKey(idEveningShift1),
                          day: dayWithShifts.day,
                          month: dayWithShifts.month,
                          id: dayWithShifts.s8['id'],
                          text: dayWithShifts.s8['holder'],
                          documentID: dayDocumentID,
                          number: 8,
                        ),
                        ShiftsRoundButton(
                          key: ObjectKey(idEveningShift2),
                          day: dayWithShifts.day,
                          month: dayWithShifts.month,
                          id: dayWithShifts.s9['id'],
                          text: dayWithShifts.s9['holder'],
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
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
                color: isWeekend ? Colors.redAccent : Colors.black,
              ),
            ),
          ),
          Transform.rotate(
            angle: pi * 1.5,
            child: Text(
              '$day.',
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
                color: isWeekend ? Colors.red : Colors.black,
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

  ShiftsRoundButton(
      {@required Key key,
      @required this.id,
      @required this.day,
      @required this.month,
      @required this.number,
      @required this.text,
      @required this.documentID})
      : super(key: ObjectKey(id));

  @override
  _ShiftsRoundButtonState createState() => _ShiftsRoundButtonState();
}

class _ShiftsRoundButtonState extends State<ShiftsRoundButton> {
  MaterialColor color = Colors.lightBlue;
  String buttonText = '+';
  double size = 26.0;
  double bottom = 5.0;
  double right = 1.0;
  String buttonHolder;
  bool employeeChosen = false;
  String id;
  String documentID;
  int number;
  bool isPast = false;
  PopupEmployeesLayout popupEmployeesLayout = PopupEmployeesLayout();

  @override
  Widget build(BuildContext context) {
    bool isLong = false;
    id = widget.id;
    documentID = widget.documentID;
    number = widget.number;
    widget.text == '' ? employeeChosen = false : employeeChosen = true;
    if (widget.text == 'ALA' || widget.text == 'ANT') isLong = true;
    if ((widget.day < DateTime.now().day &&
            widget.month <= DateTime.now().month) ||
        widget.month < DateTime.now().month) isPast = true;

    for (Employee emp in employees) {
      if (emp.initial == widget.text) color = emp.color;
    }
// if USER is Admin and not in the Past build this
    return (loggedInUser.email == 'admin@paybis.com' && isPast == false)
        ? SizedBox(
            width: 30.0,
            child: employeeChosen == false

                //If Emp is NOT chosen

                ? MaterialButton(
                    onPressed: () {
                      setState(() {
                        popupEmployeesLayout.showPopup(context, widget.id,
                            documentID, number, "Who's gonna work?");
                      });
                    },
                    color: Colors.white,
                    shape: CircleBorder(),
                    child: Padding(
                      padding: EdgeInsets.only(bottom: bottom, right: right),
                      child: Text(
                        buttonText,
                        style: TextStyle(
                          fontSize: size,
                          color: Colors.black,
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
                        popupEmployeesLayout.showPopup(context, widget.id,
                            documentID, number, "Who's gonna work?");
                      });
                    },
                    color: color,
                    shape: CircleBorder(),
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 0.0, right: 0.0),
                      child: Text(
                        widget.text,
                        style: TextStyle(
                          fontSize: isLong ? 13.0 : 16.0,
                          color: Colors.white,
                        ),
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
//                    onPressed: () {
//                    },
                    color: Colors.lightBlue,
                    shape: CircleBorder(),
                    child: Padding(
                      padding: EdgeInsets.only(bottom: bottom, right: right),
                      child: Text(
                        '',
                        style: TextStyle(
                          fontSize: size,
                          color: Colors.white,
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
                        if (widget.text == employee.initial) {
                          popupEmployeesLayout.showPersonalShiftPopup(
                              context,
                              widget.id,
                              documentID,
                              number,
                              'What to do with this shift?');
                        }
                      });
                    },
                    color: color,
                    shape: CircleBorder(),
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 0.0, right: 0.0),
                      child: Text(
                        widget.text,
                        style: TextStyle(
                          fontSize: isLong ? 13.0 : 16.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    padding: EdgeInsets.all(0.0),
                    minWidth: 10.0,
                  ),
          );
  }
}

class PopupEmployeesLayout extends ModalRoute {
  String id;
  double top;
  double bottom;
  double left;
  double right;
  Color bgColor;
  _ShiftsRoundButtonState state;
  String choiceOfEmployee;
  final Widget child;
  PopupEmployeesLayout(
      {Key key,
      this.bgColor,
      @required this.child,
      this.top,
      this.bottom,
      this.left,
      this.id,
      this.right,
      this.choiceOfEmployee});

  @override
  Duration get transitionDuration => Duration(milliseconds: 300);
  @override
  bool get opaque => false;
  @override
  bool get barrierDismissible => false;
  @override
  Color get barrierColor =>
      bgColor == null ? Colors.black.withOpacity(0.5) : bgColor;
  @override
  String get barrierLabel => null;
  @override
  bool get maintainState => false;
  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    if (top == null) this.top = 10;
    if (bottom == null) this.bottom = 20;
    if (left == null) this.left = 20;
    if (right == null) this.right = 20;

    return GestureDetector(
      onTap: () {
        // call this method here to hide soft keyboard
        SystemChannels.textInput.invokeMethod('TextInput.hide');
      },
      child: Material(
        // This makes sure that text and other content follows the material style
        type: MaterialType.transparency,
        //type: MaterialType.canvas,
        // make sure that the overlay content is not cut off
        child: SafeArea(
          bottom: true,
          child: _buildOverlayContent(context),
        ),
      ),
    );
  }

  List<Widget> listMyWidgets(BuildContext context) {
    List<Widget> list = List();
    for (Employee emp in employees) {
      list.add(
        MaterialButton(
          onPressed: () {
            Navigator.pop(context, emp.initial);
          },
          color: emp.color,
          child: Text(
            emp.name,
            style: kHeaderFontStyle,
          ),
        ),
      );
    }
    list.add(MaterialButton(
      onPressed: () {
        Navigator.pop(context, 'none');
      },
      color: Colors.black,
      child: Text(
        'none',
        style: kHeaderFontStyle,
      ),
    ));
    return list;
  }

  showPopup(
      BuildContext context, String id, String docID, int number, String title,
      {BuildContext popupContext}) {
    final result = Navigator.of(context).push(
      PopupEmployeesLayout(
        top: 30,
        left: 40,
        right: 40,
        bottom: 100,
        child: PopupContent(
          content: Scaffold(
            appBar: AppBar(
              title: Text(title),
              leading: new Builder(builder: (context) {
                return IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    try {
                      Navigator.pop(context); //close the popup
                    } catch (e) {}
                  },
                );
              }),
              brightness: Brightness.light,
            ),
            resizeToAvoidBottomPadding: false,
            body: Wrap(
              alignment: WrapAlignment.spaceEvenly,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: listMyWidgets(context),
            ),
          ),
        ),
      ),
    );
    result.then((result) {
      setState(() async {
        if (result == null || result == '') {
          result = '+';
        } else {
          _currentDocument =
              await _fireStore.collection('days').document('$docID').get();

          choiceOfEmployee = result.toString();
          print('result ' + result);
          print('Choice ' + choiceOfEmployee);

          if (choiceOfEmployee == 'none') {
            await _fireStore
                .collection('days')
                .document(_currentDocument.documentID)
                .updateData({'$number.holder': ''});
          } else
            await _fireStore
                .collection('days')
                .document(_currentDocument.documentID)
                .updateData({'$number.holder': choiceOfEmployee});
        }
      });
    });
  }

  showPersonalShiftPopup(
      BuildContext context, String id, String docID, int number, String title,
      {BuildContext popupContext}) {
    final result = Navigator.of(context).push(
      PopupEmployeesLayout(
        top: 30,
        left: 40,
        right: 40,
        bottom: 500,
        child: PopupContent(
          content: Scaffold(
            appBar: AppBar(
              title: Text(title),
              leading: new Builder(builder: (context) {
                return IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    try {
                      Navigator.pop(context); //close the popup
                    } catch (e) {}
                  },
                );
              }),
              brightness: Brightness.light,
            ),
            resizeToAvoidBottomPadding: false,
            body: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: MaterialButton(
                    //ToDo implement Exchange Shift logic
                    onPressed: () {
                      changeShifts();
                    },
                    color: Colors.green,
                    shape: RoundedRectangleBorder(),
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text(
                        'Exchange',
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    padding: EdgeInsets.all(0.0),
                    minWidth: 10.0,
                  ),
                ),
                Expanded(
                  child: MaterialButton(
                    //ToDo implement refuse Shift logic
                    onPressed: () {},
                    color: Colors.red,
                    shape: RoundedRectangleBorder(),
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text(
                        'Get rid of',
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    padding: EdgeInsets.all(0.0),
                    minWidth: 10.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    result.then((result) {
      setState(() async {
        if (result == null || result == '') {
          result = '+';
        } else {
          _currentDocument = await dbController.getDocument(docID);

          choiceOfEmployee = result.toString();
//          print('result ' + result);
//          print('Choice ' + choiceOfEmployee);

          if (choiceOfEmployee == 'none') {
            await dbController.updateHolderToNone(_currentDocument, number);
          } else
            await dbController.updateHolder(
                _currentDocument, number, choiceOfEmployee);
        }
      });
    });
  }

  //the dynamic content pass by parameter
  Widget _buildOverlayContent(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
          bottom: this.bottom,
          left: this.left,
          right: this.right,
          top: this.top),
      child: child,
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    // You can add your own animations for the overlay content
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: animation,
        child: child,
      ),
    );
  }
}

class PopupContent extends StatefulWidget {
  final Widget content;
  PopupContent({
    Key key,
    this.content,
  }) : super(key: key);
  _PopupContentState createState() => _PopupContentState();
}

class _PopupContentState extends State<PopupContent> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: widget.content,
    );
  }
}

class Day {
  int day;
  int month;
  int year;
  int id;
  Map s1 = {'holder': '', 'id': '', 'type': ''};
  Map s2 = {'holder': '', 'id': '', 'type': ''};
  Map s3 = {'holder': '', 'id': '', 'type': ''};
  Map s4 = {'holder': '', 'id': '', 'type': ''};
  Map s5 = {'holder': '', 'id': '', 'type': ''};
  Map s6 = {'holder': '', 'id': '', 'type': ''};
  Map s7 = {'holder': '', 'id': '', 'type': ''};
  Map s8 = {'holder': '', 'id': '', 'type': ''};
  Map s9 = {'holder': '', 'id': '', 'type': ''};

  Day(this.day, this.month, this.year, this.id, this.s1, this.s2, this.s3,
      this.s4, this.s5, this.s6, this.s7, this.s8, this.s9);

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
  for (Employee emp in employees) {
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

void changeShifts() {
  print('Changing Shifts...');
}
