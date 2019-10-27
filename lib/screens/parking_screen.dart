import 'dart:core';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:paybis_com_shifts/constants.dart';
import 'package:paybis_com_shifts/models/employee.dart';
import 'package:paybis_com_shifts/models/progress.dart';
import 'package:paybis_com_shifts/screens/it_days_off_screen.dart';
import 'package:paybis_com_shifts/screens/login_screen.dart';
import 'package:paybis_com_shifts/screens/recent_changes_screen.dart';

import 'calendar_screen.dart';
import 'feed_screen.dart';
import 'login_screen.dart';
import 'settings_screen.dart';
import 'shifts_screen.dart';
import 'stats_screen.dart';
import 'support_days_off_screen.dart';

String _markerInitials = '';
String _markerTime = '';

final _auth = FirebaseAuth.instance;
String _parkingTime = '';

class ParkingScreen extends StatefulWidget {
  static const String id = 'parking_screen';
  @override
  _ParkingScreenState createState() => _ParkingScreenState();
}

class _ParkingScreenState extends State<ParkingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: textIconColor,
//      bottomNavigationBar: BottomAppBar(
//        color: textPrimaryColor,
//        elevation: 10.0,
//      ),
      floatingActionButton: InfoFloatingActionButton(),
      appBar: AppBar(
        backgroundColor: darkPrimaryColor,
        automaticallyImplyLeading: (employee.department == kAdmin ||
                employee.department == kSuperAdmin ||
                employee.department == kSupportDepartment)
            ? true
            : false,
        title: Text('PayBis Parking'),
        actions: <Widget>[
          (employee.department == kITDepartment ||
                  employee.department == kManagement ||
                  employee.department == kMarketingDepartment)
              ? IconButton(
                  icon: Icon(
                    Icons.today,
                    color: Colors.white,
                  ),
                  onPressed: goToCalendar)
              : SizedBox(
                  height: 1.0,
                ),
          (employee.department != kAdmin && employee.department != kSuperAdmin)
              ? (employee.department == kSupportDepartment)
                  ? SizedBox(
                      height: 1.0,
                    )
                  : PopupMenuButton<String>(
                      color: textPrimaryColor.withOpacity(0.8),
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(10.0))),
                      itemBuilder: (BuildContext context) {
                        return kItChoicesPopupMenu.map((String choice) {
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
              : (_markerInitials == '' || _markerInitials == 'none')
                  ? IconButton(
                      icon: Icon(
                        Icons.edit,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        showAdminMarkerAlertDialogParking(context);
                      },
                    )
                  : Material(
                      elevation: 5.0,
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(30.0),
                      child: MaterialButton(
                        onPressed: () {
                          setState(() {
                            _markerInitials = '';
                          });
                        },
                        minWidth: 26.0,
                        height: 26.0,
                        child: Text(
                          _markerInitials,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    ),
        ],
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Table(
              border: TableBorder.all(
                color: secondaryColor,
              ),
              columnWidths: {
                0: FlexColumnWidth(0.2),
                1: FlexColumnWidth(0.5),
                2: FlexColumnWidth(1),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(color: darkPrimaryColor),
                  children: [
                    TableCell(
                      child: Text(
                        'Date',
                        style: kHeaderFontStyle,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    TableCell(
                      child: Text(
                        'MGMT (1-3)',
                        style: kHeaderFontStyle,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    TableCell(
                      child: Text(
                        'IT/CS (4-7)',
                        style: kHeaderFontStyle,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            ParkingDaysStream(year: dateTime.year, month: dateTime.month),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 7,
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
                            previousMonthSelected();
                          });
                        },
                        child: Icon(
                          Icons.navigate_before,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 10,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 4.0, right: 4.0, top: 8.0, bottom: 8.0),
                    child: Material(
                      elevation: 5.0,
                      color: secondaryColor,
                      borderRadius: BorderRadius.circular(15.0),
                      child: MaterialButton(
                        child: Text(
                          getMonthName(dateTime.month),
                          style: kButtonFontStyle.copyWith(fontSize: 14.0),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 7,
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
                            nextMonthSelected();
                          });
                        },
                        child: Icon(
                          Icons.navigate_next,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: SizedBox(),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  void goToCalendar() {
    Navigator.pushNamed(context, CalendarScreen.id);
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

  showAdminMarkerAlertDialogParking(
    BuildContext context,
  ) {
    final result = showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(20.0),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(32.0))),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Center(
                  child: Text(
                    'Choose employee',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                  ),
                ),
                SizedBox(
                  height: 5.0,
                ),
                Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: listParkingWidgets(context),
                ),
                Container(
                  child: Wrap(
                    children: <Widget>[
                      ParkingDates(),
                    ],
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
        result = '';
      } else {
        String choiceOfEmployee = result.toString();

        if (choiceOfEmployee == 'none') {
          setState(() {
            _markerInitials = '';
            _markerTime = '';
            _parkingTime = '';
          });
        } else
          setState(() {
            _markerInitials = choiceOfEmployee;
            _markerTime = _parkingTime;
            _parkingTime = '';
          });
      }
    });
  }
}

class InfoFloatingActionButton extends StatefulWidget {
  @override
  _InfoFloatingActionButtonState createState() =>
      _InfoFloatingActionButtonState();
}

class _InfoFloatingActionButtonState extends State<InfoFloatingActionButton> {
  bool showFab = true;
  @override
  Widget build(BuildContext context) {
    return showFab
        ? FloatingActionButton(
            backgroundColor: darkPrimaryColor,
            child: Icon(
              Icons.info_outline,
              size: 35.0,
            ),
            onPressed: () {
              var bottomSheetController = showBottomSheet(
                  context: context, builder: (context) => BottomSheetWidget());

              showFloatingActionButton(false);
              bottomSheetController.closed.then((value) {
                showFloatingActionButton(true);
              });
            },
          )
        : Container();
  }

  void showFloatingActionButton(bool value) {
    setState(() {
      showFab = value;
    });
  }
}

class BottomSheetWidget extends StatefulWidget {
  @override
  _BottomSheetWidgetState createState() => _BottomSheetWidgetState();
}

class _BottomSheetWidgetState extends State<BottomSheetWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[900],
      height: 650,
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 5.0,
            ),
            Image.asset('images/parking.png'),
            Padding(
              padding:
                  const EdgeInsets.only(top: 16.0, left: 16.0, bottom: 25.0),
              child: Column(
//                mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: listParkingInfo(context),
              ),
            )
          ],
        ),
      ),
//      child: Column(
//        children: <Widget>[
//          Container(
//            child: Icon(Icons.info),
//            decoration: BoxDecoration(
//              shape: BoxShape.circle,
//              color: Colors.green,
//            ),
//          ),
//          Container(
//            child: Icon(Icons.info),
//            decoration: BoxDecoration(
//              shape: BoxShape.circle,
//              color: accentColor,
//            ),
//          ),
//        ],
//      ),
    );
  }
}

List<Widget> listParkingInfo(BuildContext context) {
  List<Widget> list = List();
  for (Employee emp in listWithEmployees) {
    if (emp.hasCar) {
      list.add(
        Row(
          children: <Widget>[
            Expanded(
              flex: 5,
              child: Text(
                '${emp.name}',
                style: TextStyle(
                  color: textIconColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '${emp.initial}',
                style: TextStyle(
                  color: textIconColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                '${emp.cardId}',
                style: TextStyle(
                  color: textIconColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              flex: 10,
              child: Text(
                '${emp.carInfo}',
                style: TextStyle(
                  color: textIconColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
  return list;
}

class ParkingDates extends StatelessWidget {
  final List<String> dates = [
    '7-15',
    '9-17',
    '10-18',
    '10-19',
    '15-23',
    '23-7',
  ];
  @override
  Widget build(BuildContext context) {
    return RadioButtonGroup(
        labels: dates,
        orientation: GroupedButtonsOrientation.HORIZONTAL,
        onSelected: (String selected) =>
            _parkingTime = selected.replaceAll(RegExp(r'-'), ' '));
  }
}

List<Widget> listParkingWidgets(BuildContext context) {
  List<Widget> list = List();
  for (Employee emp in listWithEmployees) {
    if (emp.hasCar) {
      list.add(Padding(
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
      ));
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

class ParkingDaysStream extends StatelessWidget {
  final int year;

  final int month;

  ParkingDaysStream({@required this.year, @required this.month});

  @override
  Widget build(BuildContext context) {
//    print("Child build method invoked");
    return StreamBuilder<QuerySnapshot>(
      stream: dbController.createDaysStream(year, month),
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

          List mgmt = day.data['mgmt'];
          List itcs = day.data['itcs'];

          final dayWithShifts = Day(dayDay, dayMonth, dayYear, dayId, shift1,
              shift2, shift3, shift4, shift5, shift6, shift7, shift8, shift9);

          final dayWithShiftsUI = Table(
            border: TableBorder.all(
              color: textPrimaryColor,
            ),
            columnWidths: {
              0: FlexColumnWidth(0.2),
              1: FlexColumnWidth(0.5),
              2: FlexColumnWidth(1),
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
                  DateTableCellDaysOff(
                    day: dayWithShifts.day,
                    month: dayWithShifts.month,
                    year: dayWithShifts.year,
                  ),
                  TableCell(
                    child: Container(
                      color: Colors.blue.withOpacity(0.3),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: listMGMT(
                            dayWithShifts.day,
                            dayWithShifts.month,
                            dayWithShifts.year,
                            mgmt,
                            dayDocumentID),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Container(
                      color: Colors.yellow.withOpacity(0.3),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: listITCS(
                            dayWithShifts.day,
                            dayWithShifts.month,
                            dayWithShifts.year,
                            itcs,
                            dayDocumentID),
                      ),
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

  listMGMT(int day, int month, int year, List mgmt, String documentID) {
    List<ParkingRoundButton> list = [];
    if (mgmt != null) {
      if (mgmt.length > 0 || mgmt.isEmpty) {
        for (int i = 0; i < mgmt.length; i++) {
          String mgmtConverted = mgmt[i];
          List<String> splitted = mgmtConverted.split(' ');

          list.add(ParkingRoundButton(
            day: day,
            month: month,
            year: year,
            text: splitted[0],
            documentID: documentID,
            time: (splitted.length == 3) ? '${splitted[1]} ${splitted[2]}' : '',
            type: 'mgmt',
          ));
        }
        if (list.length < 3)
          list.add(ParkingRoundButton(
            day: day,
            month: month,
            year: year,
            text: '',
            documentID: documentID,
            time: '',
            type: 'mgmt',
          ));
        return list;
      }
    } else
      list.add(ParkingRoundButton(
        day: day,
        month: month,
        year: year,
        text: '',
        documentID: documentID,
        time: '',
        type: 'mgmt',
      ));
    return list;
  }

  listITCS(int day, int month, int year, List itcs, String documentID) {
    List<ParkingRoundButton> list = [];
    if (itcs != null) {
      if (itcs.length >= 0) {
        for (int i = 0; i < itcs.length; i++) {
          String itcsConverted = itcs[i];
          List<String> splitted = itcsConverted.split(' ');
          list.add(ParkingRoundButton(
            day: day,
            month: month,
            year: year,
            text: splitted[0],
            documentID: documentID,
            time: (splitted.length == 3) ? '${splitted[1]} ${splitted[2]}' : '',
            type: 'itcs',
          ));
        }
        if (list.length < 6)
          list.add(ParkingRoundButton(
            day: day,
            month: month,
            year: year,
            text: '',
            documentID: documentID,
            time: '',
            type: 'itcs',
          ));
        return list;
      }
    } else
      list.add(ParkingRoundButton(
        day: day,
        month: month,
        year: year,
        text: '',
        documentID: documentID,
        time: '',
        type: 'itcs',
      ));
    return list;
  }
}

class ParkingRoundButton extends StatefulWidget {
  final int day;
  final int month;
  final int year;
  final String text;
  final String documentID;
  final String time;
  final String type;

  ParkingRoundButton({
    @required this.day,
    @required this.month,
    @required this.year,
    @required this.text,
    @required this.documentID,
    @required this.time,
    @required this.type,
  }) : super();

  @override
  _ParkingRoundButton createState() => _ParkingRoundButton();
}

class _ParkingRoundButton extends State<ParkingRoundButton> {
  Color color = primaryColor;
  String buttonText = '+';
  double size = 26.0;
  double bottom = 5.0;
  double right = 1.0;
  String buttonHolder;
  bool employeeChosen = false;
  String documentID;
  String date;
  bool isPast = false;
//  PopupEmployeesLayout popupEmployeesLayout = PopupEmployeesLayout();

  @override
  Widget build(BuildContext context) {
    bool isLong = false;
    date = '${widget.day}.${widget.month}';
    documentID = widget.documentID;
    widget.text == '+' ? employeeChosen = false : employeeChosen = true;
    widget.text == '' ? employeeChosen = false : employeeChosen = true;
    if (widget.text.length == 3) isLong = true;
    if ((widget.day < DateTime.now().day - 2 &&
            widget.month <= DateTime.now().month &&
            widget.year <= DateTime.now().year) ||
        (widget.month < DateTime.now().month &&
            widget.year <= DateTime.now().year)) isPast = true;

    for (Employee emp in listWithEmployees) {
      //Converting String to Color
      if (emp.initial == widget.text) {
        if (emp.department == kManagement) {
          color = darkPrimaryColor;
        }
        if (emp.department == kSupportDepartment) {
          color = Colors.amber;
        }
        if (emp.department == kITDepartment ||
            emp.department == kMarketingDepartment) {
          color = Colors.lightGreen;
        }
//        color = convertColor(emp.empColor);
      }
    }

// if USER is Admin "and not in the Past" build this
    return ((employee.department == kAdmin ||
            employee.department == kSuperAdmin)
//        && isPast == false
        )
        ? SizedBox(
            width: 30.0,
            child: employeeChosen == false

                //If Emp is NOT chosen

                ? MaterialButton(
                    onPressed: () {
                      setState(() async {
                        if (_markerInitials == '') {
                          showAdminAlertDialogParking(
                              context, documentID, widget.type, widget.text);
                        } else if (_markerInitials == 'none') {
                        } else {
                          if (widget.type == 'mgmt') {
                            await dbController.addParkingMGMT(
                                documentID, '$_markerInitials $_markerTime');
                          }

                          if (widget.type == 'itcs') {
                            await dbController.addParkingItCs(
                                documentID, '$_markerInitials $_markerTime');
                          }
                        }
                      });
                    },
                    color: textIconColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
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
                      setState(() async {
                        if (_markerInitials == '' ||
                            _markerInitials == 'none') {
                          if (widget.type == 'mgmt') {
                            dbController.removeParkingMGMT(
                                documentID, '${widget.text} ${widget.time}');
                          }
                          if (widget.type == 'itcs') {
                            dbController.removeParkingItCs(
                                documentID, '${widget.text} ${widget.time}');
                          }
                        } else {
                          if (widget.text == _markerInitials) {
                          } else {
                            if (widget.type == 'mgmt') {
                              await dbController.addParkingMGMT(
                                  documentID, '$_markerInitials $_markerTime');
                            }

                            if (widget.type == 'itcs') {
                              await dbController.addParkingItCs(
                                  documentID, '$_markerInitials $_markerTime');
                            }
                          }
                        }
                      });
                    },
                    color: color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: Stack(
                      alignment: AlignmentDirectional.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            widget.text,
                            style: TextStyle(
                              fontSize: isLong ? 13.0 : 16.0,
                              color: textIconColor,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 22.0),
                          child: Text(
                            widget.time,
                            style: TextStyle(
                              fontSize: 10.0,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
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
                          onPressed: () {},
                          color: color,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 0.0, right: 0.0),
                            child: Stack(
                              alignment: AlignmentDirectional.center,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Text(
                                    widget.text,
                                    style: TextStyle(
                                      fontSize: isLong ? 13.0 : 16.0,
                                      color: textIconColor,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 22.0),
                                  child: Text(
                                    widget.time,
                                    style: TextStyle(
                                      fontSize: 10.0,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          padding: EdgeInsets.all(0.0),
                          minWidth: 10.0,
                        ))));
  }
}

showAdminAlertDialogParking(
  BuildContext context,
  String docID,
  String type,
  String title,
) {
  final result = showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        contentPadding: EdgeInsets.all(20.0),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(32.0))),
        content: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Center(
                child: Text(
                  'Choose employee',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                ),
              ),
              SizedBox(
                height: 5.0,
              ),
              Wrap(
                alignment: WrapAlignment.spaceEvenly,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: listParkingWidgets(context),
              ),
              Container(
                child: Wrap(
                  children: <Widget>[
                    ParkingDates(),
                  ],
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
      String choiceOfEmployee = result.toString();

      if (type == 'mgmt') {
        if (choiceOfEmployee == 'none') {
          await dbController.removeParkingMGMT(docID, title);
        } else
          await dbController.addParkingMGMT(
              docID, '$choiceOfEmployee $_parkingTime');
        _parkingTime = '';
      }
      if (type == 'itcs') {
        if (choiceOfEmployee == 'none') {
          await dbController.removeParkingItCs(docID, title);
        } else
          await dbController.addParkingItCs(
              docID, '$choiceOfEmployee $_parkingTime');
        _parkingTime = '';
      }
    }
  });
}
