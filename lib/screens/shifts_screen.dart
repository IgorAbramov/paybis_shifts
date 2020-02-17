import 'dart:core';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:paybis_com_shifts/constants.dart';
import 'package:paybis_com_shifts/models/employee.dart';
import 'package:paybis_com_shifts/models/progress.dart';
import 'package:paybis_com_shifts/screens/calendar_screen.dart';
import 'package:paybis_com_shifts/screens/it_days_off_screen.dart';
import 'package:paybis_com_shifts/screens/login_screen.dart';
import 'package:paybis_com_shifts/screens/recent_changes_screen.dart';
import 'package:paybis_com_shifts/screens/support_days_off_screen.dart';

import 'admin_calendar_screen.dart';
import 'feed_screen.dart';
import 'parking_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';

FirebaseUser loggedInUser;
DocumentSnapshot currentDocument;
String shiftDocIDContainer1ForShiftExchange;
String shiftDocIDContainer2ForShiftExchange;
String shiftPositionContainer1ForShiftExchange;
String shiftPositionContainer2ForShiftExchange;
String shiftHolderContainer1ForShiftExchange;
String shiftHolderContainer2ForShiftExchange;
String shiftDateContainer1ForShiftExchange;
String shiftDateContainer2ForShiftExchange;
String shiftTypeContainer1ForShiftExchange;
String shiftTypeContainer2ForShiftExchange;

int _beginMonthPadding = 0;
DateTime timestamp = DateTime.now();
DateTime dateTime = DateTime(timestamp.year, timestamp.month);
double workingHours;
String shiftExchangeMessage = '';
String highlighted = '';
List<Day> daysWithShiftsForCountThisMonth = List<Day>();
final shiftsScaffoldKey = new GlobalKey<ScaffoldState>();
final shiftsScreenKey = new GlobalKey<_ShiftScreenState>();
TextEditingController reasonTextInputController;
ScrollController scrollController;
FirebaseMessaging firebaseMessaging = FirebaseMessaging();
String _markerInitials = '';
List copiedShift = [];
List emptyList = [];
bool dragCompleted = false;
Shift shiftOnDragComplete = Shift('', 8.0, '', '');
DocumentSnapshot dragDocument;

class ShiftScreen extends StatefulWidget {
  static const String id = 'shifts_screen_new';
  const ShiftScreen({Key key}) : super(key: key);
  @override
  _ShiftScreenState createState() => _ShiftScreenState();
}

class _ShiftScreenState extends State<ShiftScreen> {
  final _auth = FirebaseAuth.instance;
  @override
  void initState() {
    SystemChrome.setEnabledSystemUIOverlays([]);
    super.initState();

    reasonTextInputController = new TextEditingController();
    scrollController = new ScrollController();
    configurePushNotifications();
//    if (SchedulerBinding.instance.schedulerPhase ==
//        SchedulerPhase.persistentCallbacks) {
//      SchedulerBinding.instance.addPostFrameCallback((_) =>
//          scrollController.jumpTo(scrollController.offset + timestamp.day));
//    }
  }

  void rebuild() {
    setState(() {});
  }

  @override
  void reassemble() {
    super.reassemble();
    daysWithShiftsForCountThisMonth.clear();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    ScreenUtil.init(context, width: 1080, height: 2220, allowFontScaling: true);
    daysWithShiftsForCountThisMonth.clear();
    return Scaffold(
      key: shiftsScaffoldKey,
      backgroundColor: Theme.of(context).textSelectionColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColorDark,
        automaticallyImplyLeading: false,
        title: Text('PayBis Schedule'),
        actions: <Widget>[
          (employee.department == kAdmin || employee.department == kSuperAdmin)
              ? (_markerInitials == '')
                  ? IconButton(
                      icon: Icon(
                        Icons.edit,
                        color: Theme.of(context).textSelectionColor,
                      ),
                      onPressed: () {
                        showAdminMarkerAlertDialog(context);
                      },
                    )
                  : Material(
                      elevation: 5.0,
                      color: Theme.of(context).indicatorColor,
                      borderRadius: BorderRadius.circular(30.0),
                      child: MaterialButton(
                        onPressed: () {
                          _markerInitials = '';
                          shiftsScreenKey.currentState.rebuild();
                        },
                        minWidth: 26.0,
                        height: 26.0,
                        child: Text(
                          _markerInitials,
                          style: TextStyle(
                            color: Theme.of(context).textSelectionColor,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    )
              : SizedBox(
                  height: 1.0,
                ),
          IconButton(
              icon: Icon(
                Icons.today,
                color: Theme.of(context).textSelectionColor,
              ),
              onPressed: goToCalendar),
          (employee.department != kAdmin && employee.department != kSuperAdmin)
              ? (employee.hasCar)
                  ? PopupMenuButton<String>(
                      color: Theme.of(context).indicatorColor.withOpacity(0.8),
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
                                color: Theme.of(context).textSelectionColor,
                              ),
                            ),
                          );
                        }).toList();
                      },
                      onSelected: choicesAction,
                    )
                  : PopupMenuButton<String>(
                      color: Theme.of(context).indicatorColor.withOpacity(0.8),
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
                                color: Theme.of(context).textSelectionColor,
                              ),
                            ),
                          );
                        }).toList();
                      },
                      onSelected: choicesAction,
                    )
              : (employee.department == kAdmin)
                  ? PopupMenuButton<String>(
                      color: Theme.of(context).indicatorColor.withOpacity(0.8),
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(10.0))),
                      itemBuilder: (BuildContext context) {
                        return kAdminChoicesPopupMenu.map((String choice) {
                          return PopupMenuItem<String>(
                            value: choice,
                            child: Text(
                              choice,
                              style: TextStyle(
                                color: Theme.of(context).textSelectionColor,
                              ),
                            ),
                          );
                        }).toList();
                      },
                      onSelected: choicesAction,
                    )
                  : PopupMenuButton<String>(
                      color: Theme.of(context).indicatorColor.withOpacity(0.8),
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(10.0))),
                      itemBuilder: (BuildContext context) {
                        return kSuperAdminChoicesPopupMenu.map((String choice) {
                          return PopupMenuItem<String>(
                            value: choice,
                            child: Text(
                              choice,
                              style: TextStyle(
                                color: Theme.of(context).textSelectionColor,
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
                decoration:
                    BoxDecoration(color: Theme.of(context).primaryColorDark),
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
          DaysStream(
            year: dateTime.year,
            month: dateTime.month,
          ),
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
                    color: Theme.of(context).primaryColorDark,
                    borderRadius: BorderRadius.circular(15.0),
                    child: MaterialButton(
                      onPressed: () {
                        setState(() {
                          previousMonthSelected();
                        });
                      },
                      child: Icon(
                        Icons.navigate_before,
                        color: Theme.of(context).textSelectionColor,
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
                      onPressed: () {
                        scrollController.jumpTo(timestamp.day * 47.0);
                      },
                      child: Text(
                        getMonthName(dateTime.month),
                        style: kButtonStyle,
                      ),
                    ),
                  ),
                ),
              ),

//ADD MONTH Button
//              Expanded(
//                flex: 9,
//                child: Padding(
//                  padding: const EdgeInsets.all(8.0),
//                  child: MaterialButton(
//                    onPressed: () {
//                      setState(() async {
////                        dbController.deleteMonth(2);
//                        for (int i = 1; i <= getNumberOfDaysInMonth(7); i++) {
//                          Day newDay = new Day(i, 7, 19, false, [], [], []);
//                          Map dayMap =
//                              newDay.buildMap(i, 7, 2019, false, [], [], []);
//                          await dbController.addMonth(dayMap);
//                        }
//                      });
//                    },
//                    color: Colors.lightBlue,
//                    child: Text(
//                      'add month',
//                      style: kHeaderFontStyle,
//                    ),
//                  ),
//                ),
//              ),
              Expanded(
                flex: 7,
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 4.0, right: 16.0, top: 8.0, bottom: 8.0),
                  child: Material(
                    elevation: 5.0,
                    color: Theme.of(context).primaryColorDark,
                    borderRadius: BorderRadius.circular(15.0),
                    child: MaterialButton(
                      onPressed: () {
                        setState(() {
                          nextMonthSelected();
                        });
                      },
                      child: Icon(
                        Icons.navigate_next,
                        color: Theme.of(context).textSelectionColor,
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

  void configurePushNotifications() {
    if (Platform.isIOS) {
      getiOSPermission();
    }

    firebaseMessaging.getToken().then((token) {
      print("Firebase Messaging Token: $token\n");
      dbController.configureToken(token);
    });

    firebaseMessaging.configure(
      onLaunch: (Map<String, dynamic> message) async {
        print("on Launch: $message\n");
        final String recipientId = message['data']['recipient'];
        final String body = message['notification']['body'];
        if (recipientId == employee.id) {
//          print("Notification shown!");
          openNotificationAlertDialog(context, body, 'Change Request');
        }
      },
      onResume: (Map<String, dynamic> message) async {
        print("on Resume: $message\n");
        final String recipientId = message['data']['recipient'];
        final String body = message['notification']['body'];
        if (recipientId == employee.id) {
//          print("Notification shown!");
          openNotificationAlertDialog(context, body, 'Change Request');
        }
      },
      onMessage: (Map<String, dynamic> message) async {
        print("on message: $message\n");
        print('Employee ${employee.id}');
        final String recipientId = message['data']['recipient'];
        final String body = message['notification']['body'];
        print('Recipient $recipientId');
        print('Employee ${employee.id}');
        if (recipientId == employee.id) {
          print("Notification shown!");
          openNotificationAlertDialog(context, body, 'Change Request');
//          SnackBar snackbar = SnackBar(
//              content: Text(
//            body,
//            overflow: TextOverflow.ellipsis,
//          ));
//          shiftsScaffoldKey.currentState.showSnackBar(snackbar);
        } else
          print("Notification NOT shown");
      },
    );
  }

  getiOSPermission() {
    firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(alert: true, badge: true, sound: true));
    firebaseMessaging.onIosSettingsRegistered.listen((settings) {
      // print("Settings registered: $settings");
    });
  }

  void goToCalendar() {
    if (employee.department == kAdmin || employee.department == kSuperAdmin) {
      Navigator.pushNamed(context, AdminCalendarScreen.id);
    } else {
      Navigator.pushNamed(context, CalendarScreen.id);
    }
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
  final int year;
  final int month;
  final int day;

  DaysStream({
    @required this.year,
    @required this.month,
    this.day,
  });

  @override
  Widget build(BuildContext context) {
    if (daysWithShiftsForCountThisMonth.isNotEmpty)
      daysWithShiftsForCountThisMonth.clear();

    return StreamBuilder<QuerySnapshot>(
      stream: (day == null)
          ? dbController.createDaysStream(year, month)
          : dbController.createOneDayStream(year, month, day),
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
          final String dayDocumentID = day.documentID;
          final bool dayIsHoliday = day.data['isHoliday'];
          final bool isWeekUnconfirmed = day.data['isWeekUnconfirmed'];
          final List nightShifts = day.data[kNight];
          final List morningShifts = day.data[kMorning];
          final List eveningShifts = day.data[kEvening];
          currentDocument = day;

          List nightAbsent = day.data['abscent$kNight'];
          List morningAbsent = day.data['abscent$kMorning'];
          List eveningAbsent = day.data['abscent$kEvening'];
          bool isAbsentNight = false;
          bool isAbsentMorning = false;
          bool isAbsentEvening = false;
          bool isWeekConfirmed = true;

          if (nightAbsent != null) {
            if (nightAbsent.contains(employee.initial)) {
              isAbsentNight = true;
            }
          }
          if (morningAbsent != null) {
            if (morningAbsent.contains(employee.initial)) {
              isAbsentMorning = true;
            }
          }
          if (eveningAbsent != null) {
            if (eveningAbsent.contains(employee.initial)) {
              isAbsentEvening = true;
            }
          }
          if (isWeekUnconfirmed != null) {
            if (isWeekUnconfirmed == true) {
              isWeekConfirmed = false;
            }
          }

          final dayWithShifts = Day(dayDay, dayMonth, dayYear, dayIsHoliday,
              nightShifts, morningShifts, eveningShifts);

          if (!daysWithShiftsForCountThisMonth.contains(dayWithShifts) &&
              daysWithShiftsForCountThisMonth.length <
                  getNumberOfDaysInMonth(dateTime.month, dateTime.year))
            daysWithShiftsForCountThisMonth.add(dayWithShifts);

          final dayWithShiftsUI = Table(
            border: TableBorder.all(
              color: Theme.of(context).indicatorColor,
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
                      ? Theme.of(context).primaryColor.withOpacity(0.4)
                      : Theme.of(context).textSelectionColor,
                ),
                children: [
                  DateTableCell(
                    day: dayWithShifts.day,
                    month: dayWithShifts.month,
                    year: dayWithShifts.year,
                    dayDocumentID: dayDocumentID,
                    isHoliday: dayIsHoliday,
                  ),
                  TableCell(
                    child: Container(
                      color: dayIsHoliday != null
                          ? dayIsHoliday
                              ? Colors.indigo.shade200
                              : Colors.indigo.shade100
                          : Colors.indigo.shade100,
                      child: GestureDetector(
                        onLongPress: () async {
                          currentDocument =
                              await dbController.getDocument(dayDocumentID);

                          if (employee.department == kAdmin ||
                              employee.department == kSuperAdmin) {
                            if (dayWithShifts.night.isEmpty) {
                              await dbController.createWholeShiftCopy(
                                  currentDocument, copiedShift, kNight);
                            } else {
                              copiedShift.clear();
                              for (int i = 0;
                                  i < dayWithShifts.night.length;
                                  i++) {
                                copiedShift.add(dayWithShifts.night[i]);
                              }
                              showCopyMessage();
                            }
                          }
                          if (nightAbsent != null &&
                              employee.department == kSupportDepartment) {
                            if (isAbsentNight) {
                              if (employee.department == kSupportDepartment &&
                                  nightAbsent.contains(employee.initial)) {
                                dbController.removeAbsenceShift(
                                    dayDocumentID, employee.initial, kNight);
                              }
                            }
                            if (employee.department == kSupportDepartment &&
                                !nightAbsent.contains(employee.initial)) {
                              dbController.addAbsenceShift(
                                  dayDocumentID, employee.initial, kNight);
                              showAbsentMessage();
                            }
                          } else {
                            if (employee.department == kSupportDepartment) {
                              dbController.addAbsenceShift(
                                  dayDocumentID, employee.initial, kNight);
                              showAbsentMessage();
                            }
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: listShifts(
                              dayWithShifts.day,
                              dayWithShifts.month,
                              dayWithShifts.year,
                              nightShifts,
                              kNight,
                              dayDocumentID,
                              isAbsentNight,
                              nightAbsent),
                        ),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Container(
                      color: dayIsHoliday != null
                          ? dayIsHoliday
                              ? Colors.red.shade100
                              : Colors.transparent
                          : Colors.transparent,
                      child: GestureDetector(
                        onLongPress: () async {
                          currentDocument =
                              await dbController.getDocument(dayDocumentID);
                          if (employee.department == kAdmin ||
                              employee.department == kSuperAdmin) {
                            if (dayWithShifts.morning.isEmpty) {
                              await dbController.createWholeShiftCopy(
                                  currentDocument, copiedShift, kMorning);
                            } else {
                              copiedShift.clear();
                              for (int i = 0;
                                  i < dayWithShifts.morning.length;
                                  i++) {
                                copiedShift.add(dayWithShifts.morning[i]);
                              }
                              showCopyMessage();
                            }
                          }
                          if (morningAbsent != null &&
                              employee.department == kSupportDepartment) {
                            if (isAbsentMorning) {
                              if (employee.department == kSupportDepartment &&
                                  morningAbsent.contains(employee.initial)) {
                                dbController.removeAbsenceShift(
                                    dayDocumentID, employee.initial, kMorning);
                              }
                            }
                            if (employee.department == kSupportDepartment &&
                                !morningAbsent.contains(employee.initial)) {
                              dbController.addAbsenceShift(
                                  dayDocumentID, employee.initial, kMorning);
                              showAbsentMessage();
                            }
                          } else {
                            if (employee.department == kSupportDepartment) {
                              dbController.addAbsenceShift(
                                  dayDocumentID, employee.initial, kMorning);
                              showAbsentMessage();
                            }
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: listShifts(
                              dayWithShifts.day,
                              dayWithShifts.month,
                              dayWithShifts.year,
                              morningShifts,
                              kMorning,
                              dayDocumentID,
                              isAbsentMorning,
                              morningAbsent),
                        ),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Container(
                      color: dayIsHoliday != null
                          ? dayIsHoliday
                              ? Colors.red.shade100
                              : Colors.transparent
                          : Colors.transparent,
                      child: GestureDetector(
                        onLongPress: () async {
                          currentDocument =
                              await dbController.getDocument(dayDocumentID);
                          if (employee.department == kAdmin ||
                              employee.department == kSuperAdmin) {
                            if (dayWithShifts.evening.isEmpty) {
                              await dbController.createWholeShiftCopy(
                                  currentDocument, copiedShift, kEvening);
                            } else {
                              copiedShift.clear();
                              for (int i = 0;
                                  i < dayWithShifts.evening.length;
                                  i++) {
                                copiedShift.add(dayWithShifts.evening[i]);
                              }
                              showCopyMessage();
                            }
                          }
                          if (eveningAbsent != null &&
                              employee.department == kSupportDepartment) {
                            if (isAbsentEvening) {
                              if (employee.department == kSupportDepartment &&
                                  eveningAbsent.contains(employee.initial)) {
                                dbController.removeAbsenceShift(
                                    dayDocumentID, employee.initial, kEvening);
                              }
                            }
                            if (employee.department == kSupportDepartment &&
                                !eveningAbsent.contains(employee.initial)) {
                              dbController.addAbsenceShift(
                                  dayDocumentID, employee.initial, kEvening);
                              showAbsentMessage();
                            }
                          } else {
                            if (employee.department == kSupportDepartment) {
                              dbController.addAbsenceShift(
                                  dayDocumentID, employee.initial, kEvening);
                              showAbsentMessage();
                            }
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: listShifts(
                              dayWithShifts.day,
                              dayWithShifts.month,
                              dayWithShifts.year,
                              eveningShifts,
                              kEvening,
                              dayDocumentID,
                              isAbsentEvening,
                              eveningAbsent),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
          daysWithShifts.add(dayWithShiftsUI);

          if (weekdayCheck(dayDay, dayMonth, dayYear) == 7) {
            final divider = isWeekConfirmed
                ? GestureDetector(
                    onDoubleTap: () {
                      if (employee.department == kAdmin ||
                          employee.department == kSuperAdmin) {
                        openWeekEditorAlertDialog(context, dayDay + 1);
                      }
                    },
                    onLongPress: () async {
                      if (employee.department == kAdmin ||
                          employee.department == kSuperAdmin) {
                        await dbController.changeWeekConfirmedStatus(
                            dayDocumentID, true);
                      }
                    },
                    child: Container(
                      color: Theme.of(context).textSelectionColor,
                      height: 20.0,
                      width: 600.0,
                    ),
                  )
                : GestureDetector(
                    onDoubleTap: () {
                      if (employee.department == kAdmin ||
                          employee.department == kSuperAdmin) {
                        openWeekEditorAlertDialog(context, dayDay + 1);
                      }
                    },
                    onLongPress: () async {
                      if (employee.department == kAdmin ||
                          employee.department == kSuperAdmin) {
                        await dbController.changeWeekConfirmedStatus(
                            dayDocumentID, false);
                      }
                    },
                    child: Container(
                      color: Theme.of(context).accentColor,
                      height: 20.0,
                      width: 600.0,
                      child: Center(
                        child: Text(
                          'Unconfirmed',
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(45),
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textSelectionColor,
                          ),
                        ),
                      ),
                    ),
                  );
            daysWithShifts.add(divider);
          }
        }
        return Expanded(
          child: ListView(
            controller: scrollController,
            reverse: false,
            children: (daysWithShifts.length != 0)
                ? daysWithShifts
                : (employee.department == kAdmin ||
                        employee.department == kSuperAdmin)
                    ? [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Material(
                            elevation: 5.0,
                            color: Theme.of(context).primaryColorDark,
                            borderRadius: BorderRadius.circular(15.0),
                            child: MaterialButton(
                              height: 50.00,
                              onPressed: () async {
//                        dbController.deleteMonth(2);
                                for (int i = 1;
                                    i <= getNumberOfDaysInMonth(month, year);
                                    i++) {
                                  Day newDay = new Day(
                                      i, month, year, false, [], [], []);
                                  Map dayMap = newDay.buildMap(
                                      i, month, year, false, [], [], []);
                                  await dbController.addMonth(dayMap);
                                }
                              },
                              child: Text(
                                'Add month',
                                style: kHeaderFontStyle,
                              ),
                            ),
                          ),
                        )
                      ]
                    : [SizedBox()],
          ),
        );
      },
    );
  }

  listShifts(int day, int month, int year, List shifts, String shiftType,
      String documentID, bool absent, List absentList) {
    List<ShiftsRoundButton> list = [];
    if (shifts != null && shifts.isNotEmpty) {
      if (shifts.length > 0 || shifts.isEmpty) {
        for (int i = 0; i < shifts.length; i++) {
          list.add(ShiftsRoundButton(
            day: day,
            month: month,
            year: year,
            shift: Shift(shifts[i]['holder'], shifts[i]['hours'].toDouble(),
                shifts[i]['position'], shifts[i]['type']),
            shiftType: shiftType,
            text: shifts[i]['holder'],
            workingHours: shifts[i]['hours'].toDouble(),
            documentID: documentID,
            absent: absent,
            absentList: absentList,
          ));
        }
        if ((employee.department == kAdmin ||
                employee.department == kSuperAdmin) &&
//            ((day > DateTime.now().day - 2 &&
//                    month >= DateTime.now().month &&
//                    year == DateTime.now().year) ||
//                (month > DateTime.now().month && year == DateTime.now().year) ||
//                (year > DateTime.now().year)) &&
            list.length < 4)
          list.add(ShiftsRoundButton(
            day: day,
            month: month,
            year: year,
            shiftType: shiftType,
            shift: Shift('', 8.0, '', shiftType),
            text: '',
            workingHours: 8.0,
            documentID: documentID,
            absent: absent,
            absentList: absentList,
          ));
        return list;
      }
    } else
      list.add(ShiftsRoundButton(
        day: day,
        month: month,
        year: year,
        shiftType: shiftType,
        shift: Shift('', 8.0, '', shiftType),
        text: '',
        workingHours: 8.0,
        documentID: documentID,
        absent: absent,
        absentList: absentList,
      ));
    return list;
  }
}

class DateTableCell extends StatelessWidget {
  final int day;
  final int month;
  final int year;
  final String dayDocumentID;
  final bool isHoliday;

  DateTableCell(
      {@required this.day,
      @required this.month,
      @required this.year,
      @required this.dayDocumentID,
      @required this.isHoliday});

  @override
  Widget build(BuildContext context) {
    int weekDay = weekdayCheck(day, month, year);
    bool isWeekend = false;

    if (weekDay == 6 || weekDay == 7) isWeekend = true;
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: GestureDetector(
        onLongPress: () async {
          if (employee.department == kSuperAdmin) {
            if (isHoliday == false) {
              await dbController.changeHolidayStatus(dayDocumentID, true);
            } else {
              await dbController.changeHolidayStatus(dayDocumentID, false);
            }
          }
        },
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Container(
            child: Column(
              children: <Widget>[
                Transform.rotate(
                  angle: pi * 1.5,
                  child: Text(
                    '$month',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(29),
                      fontWeight: FontWeight.bold,
                      color: isWeekend
                          ? Theme.of(context).accentColor
                          : Theme.of(context).indicatorColor,
                    ),
                  ),
                ),
                Transform.rotate(
                  angle: pi * 1.5,
                  child: Text(
                    '$day.',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(29),
                      fontWeight: FontWeight.bold,
                      color: isWeekend
                          ? Theme.of(context).accentColor
                          : Theme.of(context).indicatorColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ShiftsRoundButton extends StatefulWidget {
  final int day;
  final int month;
  final String shiftType;
  final Shift shift;
  final String text;
  final String documentID;
  final double workingHours;
  final int year;
  final bool absent;
  final List absentList;

  ShiftsRoundButton(
      {@required this.day,
      @required this.month,
      @required this.year,
      @required this.shiftType,
      @required this.shift,
      @required this.text,
      @required this.documentID,
      @required this.workingHours,
      this.absent,
      this.absentList});

  @override
  _ShiftsRoundButtonState createState() => _ShiftsRoundButtonState();
}

class _ShiftsRoundButtonState extends State<ShiftsRoundButton> {
  String buttonText = '+';
  double size = 26.0;

  double bottom = 5.0;
  double right = 1.0;
  String buttonHolder;
  bool employeeChosen = false;
  String id;
  String documentID;
  String date;
  bool isPast = false;
//  PopupEmployeesLayout popupEmployeesLayout = PopupEmployeesLayout();

  @override
  Widget build(BuildContext context) {
    Color color = Theme.of(context).primaryColor;
    bool isLong = false;
    date = '${widget.day}.${widget.month}';
    documentID = widget.documentID;
    widget.text == '' ? employeeChosen = false : employeeChosen = true;
    if (widget.text.length == 3) isLong = true;

    isPast = false;
    if ((widget.day < DateTime.now().day - 2 &&
            widget.month <= DateTime.now().month &&
            widget.year <= DateTime.now().year) ||
        (widget.month < DateTime.now().month &&
            widget.year <= DateTime.now().year)) isPast = true;

    for (Employee emp in listWithEmployees) {
      //Converting String to Color
      if (emp.initial == widget.text) {
        color = convertColor(emp.empColor);
      }
    }

// if USER is Admin "and not in the Past" build this
    return ((employee.department == kAdmin ||
            employee.department == kSuperAdmin)
//        && isPast == false
        )
        ? SizedBox(
            width: ScreenUtil().setWidth(84),
//            30.0,
            child: employeeChosen == false

                //If Emp is NOT chosen

                ? DragTarget(
                    onWillAccept: (shift) {
                      dragCompleted = true;
                      return true;
                    },
                    onAccept: (Shift shift) async {
                      shiftOnDragComplete.type = widget.shift.type;
                      dragDocument = await dbController.getDocument(documentID);
                      return dragCompleted = true;
                    },
                    onLeave: (shift) {
                      return dragCompleted = false;
                    },
                    builder: (context, accepted, rejected) {
                      return MaterialButton(
                        onPressed: () {
                          setState(() async {
                            if (_markerInitials == '') {
                              showAdminAlertDialog(
                                  context,
                                  documentID,
                                  widget.shift,
                                  "Who's gonna work?",
                                  widget.absentList);
                            } else if (_markerInitials == 'X') {
                            } else {
                              currentDocument =
                                  await dbController.getDocument(documentID);

                              String position;
                              for (Employee emp in listWithEmployees) {
                                if (emp.initial == _markerInitials) {
                                  position = emp.position;
                                }
                              }
                              Shift newShift = Shift(_markerInitials, 8.0,
                                  position, widget.shift.type);
                              await dbController.createShift(
                                  currentDocument,
                                  newShift.type,
                                  newShift.buildMap(
                                      newShift.holder,
                                      newShift.hours,
                                      newShift.position,
                                      newShift.type));
                            }
                          });
                        },
                        color: Theme.of(context).textSelectionColor,
                        shape: CircleBorder(),
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 3.0, right: 0.0),
                          child: Text(
                            buttonText,
                            style: TextStyle(
                              fontSize: size,
                              color: Theme.of(context).indicatorColor,
                            ),
                          ),
                        ),
                        padding: EdgeInsets.all(0.0),
                        minWidth: 10.0,
                      );
                    },
                  )

                //If Emp is chosen

                : Tooltip(
                    message: '${widget.shift.hours} hours',
                    child: Draggable(
                      maxSimultaneousDrags: 1,
                      affinity: Axis.horizontal,
                      data: widget.shift,
                      onDragCompleted: () async {
                        if (dragCompleted) {
                          currentDocument =
                              await dbController.getDocument(documentID);
                          Shift newShift = Shift(widget.shift.holder, 8.0,
                              widget.shift.position, shiftOnDragComplete.type);
                          await dbController.deleteShift(
                              currentDocument,
                              widget.shiftType,
                              widget.shift.buildMap(
                                  widget.shift.holder,
                                  widget.shift.hours,
                                  widget.shift.position,
                                  widget.shift.type));
                          await dbController.createShift(
                              dragDocument,
                              newShift.type,
                              newShift.buildMap(newShift.holder, newShift.hours,
                                  newShift.position, newShift.type));
                          setState(() {});
                        }
                      },
                      feedback:
                          //Container(),
                          MaterialButton(
                        onPressed: () {},
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
                                      color:
                                          Theme.of(context).textSelectionColor,
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
                                              ? Theme.of(context).accentColor
                                              : Colors.green),
                                    ),
                                  )
                                ],
                              )
                            : Text(
                                widget.text,
                                style: TextStyle(
                                  fontSize: isLong ? 13.0 : 16.0,
                                  color: Theme.of(context).textSelectionColor,
                                ),
                              ),
                        padding: EdgeInsets.all(0.0),
                        minWidth: 30.0,
                      ),
                      childWhenDragging: Container(),
                      child: MaterialButton(
                        onPressed: () {
                          setState(() async {
                            if (_markerInitials == '') {
                              showAdminAlertDialog(
                                  context,
                                  documentID,
                                  widget.shift,
                                  "Who's gonna work?",
                                  widget.absentList);
                            } else if (_markerInitials == 'X') {
                              currentDocument =
                                  await dbController.getDocument(documentID);
                              await dbController.deleteShift(
                                  currentDocument,
                                  widget.shiftType,
                                  widget.shift.buildMap(
                                      widget.shift.holder,
                                      widget.shift.hours,
                                      widget.shift.position,
                                      widget.shift.type));
                            } else {
                              currentDocument =
                                  await dbController.getDocument(documentID);

                              String position;
                              for (Employee emp in listWithEmployees) {
                                if (emp.initial == _markerInitials) {
                                  position = emp.position;
                                }
                              }
                              Shift newShift = Shift(_markerInitials, 8.0,
                                  position, widget.shift.type);

                              await dbController.updateShift(
                                  currentDocument,
                                  widget.shift.type,
                                  widget.shift.buildMap(
                                      widget.shift.holder,
                                      widget.shift.hours,
                                      widget.shift.position,
                                      widget.shift.type),
                                  newShift.buildMap(
                                      newShift.holder,
                                      newShift.hours,
                                      newShift.position,
                                      newShift.type));
                            }
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
                                      color:
                                          Theme.of(context).textSelectionColor,
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
                                              ? Theme.of(context).accentColor
                                              : Colors.green),
                                    ),
                                  )
                                ],
                              )
                            : Text(
                                widget.text,
                                style: TextStyle(
                                  fontSize: isLong ? 13.0 : 16.0,
                                  color: Theme.of(context).textSelectionColor,
                                ),
                              ),
                        padding: EdgeInsets.all(0.0),
                        minWidth: 10.0,
                      ),
                    ),
                  ),
          )

        // if user is NOT Admin or in the past build this

        : SizedBox(
            width: 30.0,
            child: employeeChosen == false

                //If Emp is NOT chosen

                ? (widget.absent)
                    ? MaterialButton(
                        onPressed: () {},
                        color: Theme.of(context).accentColor,
                        shape: CircleBorder(),
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 0.0, right: 0.0),
                          child: Text(
                            '',
                            style: TextStyle(
                              fontSize: size,
                              color: Theme.of(context).textSelectionColor,
                            ),
                          ),
                        ),
                        padding: EdgeInsets.all(0.0),
                        minWidth: 10.0,
                      )
                    : MaterialButton(
//                        onPressed: () {},
                        shape: CircleBorder(),
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 0.0, right: 0.0),
                          child: Text(
                            '',
                            style: TextStyle(
                              fontSize: size,
                              color: Theme.of(context).textSelectionColor,
                            ),
                          ),
                        ),
                        minWidth: 10.0,
                      )

                //If Emp is chosen
                : Tooltip(
                    message: '${widget.shift.hours} hours',
                    child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 0.1),
                        child: Material(
                            color: (employee != null)
                                ? (widget.text == employee.initial)
                                    ? Theme.of(context).indicatorColor
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
                                      shiftPositionContainer1ForShiftExchange ==
                                          null &&
                                      shiftHolderContainer1ForShiftExchange ==
                                          null) {
                                    openPersonalShiftAlertBox(
                                        context,
                                        documentID,
                                        widget.shift.position,
                                        date,
                                        'Exchange?',
                                        widget.shiftType);
                                  }
                                  if (isPast == false &&
                                      widget.text != employee.initial &&
                                      shiftDocIDContainer1ForShiftExchange !=
                                          null &&
                                      shiftPositionContainer1ForShiftExchange !=
                                          null &&
                                      shiftHolderContainer1ForShiftExchange !=
                                          null) {
                                    openChangeShiftsConfirmationAlertBox(
                                      context,
                                      documentID,
                                      widget.shift.position,
                                      date,
                                      'Exchange with ${widget.text}?',
                                      widget.text,
                                      widget.shiftType,
                                    );
                                  }

                                  if (widget.text != employee.initial &&
                                      highlighted == '' &&
                                      shiftDocIDContainer1ForShiftExchange ==
                                          null &&
                                      shiftPositionContainer1ForShiftExchange ==
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
                                      ? Theme.of(context).primaryColorDark
                                      : (widget.text == highlighted)
                                          ? Theme.of(context).indicatorColor
                                          : color.withOpacity(0.25)
                                  : color,
                              shape: CircleBorder(),
                              child: Padding(
                                padding:
                                    EdgeInsets.only(bottom: 0.0, right: 0.0),
                                child: (widget.workingHours != 8)
                                    ? Stack(
                                        alignment: AlignmentDirectional.center,
                                        children: <Widget>[
                                          Text(
                                            widget.text,
                                            style: TextStyle(
                                              fontSize: isLong ? 13.0 : 16.0,
                                              color: Theme.of(context)
                                                  .textSelectionColor,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 24.0, left: 24.0),
                                            child: Text(
                                              (widget.workingHours < 8)
                                                  ? '-'
                                                  : '+',
                                              style: TextStyle(
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      (widget.workingHours < 8)
                                                          ? Theme.of(context)
                                                              .accentColor
                                                          : Colors.green),
                                            ),
                                          )
                                        ],
                                      )
                                    : Text(
                                        widget.text,
                                        style: TextStyle(
                                          fontSize: isLong ? 13.0 : 16.0,
                                          color: Theme.of(context)
                                              .textSelectionColor,
                                        ),
                                      ),
                              ),
                              padding: EdgeInsets.all(0.0),
                              minWidth: 10.0,
                            ))),
                  ));
  }
}

void highlightEmp(String initials) {
  highlighted = initials;
}

void deHighlightEmp() {
  highlighted = '';
}

void updateShiftExchangeValuesToNull() {
  shiftDocIDContainer1ForShiftExchange = null;
  shiftDocIDContainer2ForShiftExchange = null;
  shiftHolderContainer1ForShiftExchange = null;
  shiftHolderContainer2ForShiftExchange = null;
  shiftPositionContainer1ForShiftExchange = null;
  shiftPositionContainer2ForShiftExchange = null;
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
  String docID,
  Shift shift,
  String title,
  List absent,
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
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
              ),
              SizedBox(
                height: 5.0,
              ),
              Wrap(
                alignment: WrapAlignment.spaceEvenly,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: listMyWidgets(context, absent),
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
                          'Update working hours for this shift (at this moment: ${shift.hours})',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                            color: Theme.of(context).textSelectionColor,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40.0),
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 4,
                          decoration: kTextFieldDecoration.copyWith(
                            hintText: '${shift.hours}',
                          ),
                          onChanged: (value) {
                            //Do something with the user input.
                            workingHours = double.parse(value);
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Material(
                          elevation: 5.0,
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(15.0),
                          child: MaterialButton(
                            child: Text(
                              'Update',
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Theme.of(context).textSelectionColor,
                              ),
                            ),
                            onPressed: () async {
                              currentDocument =
                                  await dbController.getDocument(docID);
                              if (workingHours != null) {
                                await dbController.updateHours(
                                    currentDocument,
                                    shift.type,
                                    shift.buildMap(shift.holder, shift.hours,
                                        shift.position, shift.type),
                                    shift.buildMap(shift.holder, workingHours,
                                        shift.position, shift.type));
                              }
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
        await dbController.deleteShift(
            currentDocument,
            shift.type,
            shift.buildMap(
                shift.holder, shift.hours, shift.position, shift.type));
      } else {
        String position;
        for (Employee emp in listWithEmployees) {
          if (emp.initial == choiceOfEmployee) {
            position = emp.position;
          }
        }
        Shift newShift = Shift(choiceOfEmployee, 8.0, position, shift.type);
        if (shift.holder != null) {
          await dbController.updateShift(
              currentDocument,
              shift.type,
              shift.buildMap(
                  shift.holder, shift.hours, shift.position, shift.type),
              newShift.buildMap(newShift.holder, newShift.hours,
                  newShift.position, newShift.type));
        } else {
          await dbController.createShift(
              currentDocument,
              newShift.type,
              newShift.buildMap(newShift.holder, newShift.hours,
                  newShift.position, newShift.type));
        }
      }
    }
  });
}

showAdminMarkerAlertDialog(BuildContext context) {
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
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
              ),
              SizedBox(
                height: 5.0,
              ),
              Wrap(
                alignment: WrapAlignment.spaceEvenly,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: listMyWidgets(context, emptyList),
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
        _markerInitials = 'X';
        shiftsScreenKey.currentState.rebuild();
      } else
        _markerInitials = choiceOfEmployee;
      shiftsScreenKey.currentState.rebuild();
    }
  });
}

List<Widget> listMyWidgets(BuildContext context, List absent) {
  List<Widget> list = List();
  for (Employee emp in listWithEmployees) {
    if (emp.department == kSupportDepartment) {
      bool isAbsent = false;
      if (absent != null) {
        for (int i = 0; i < absent.length; i++) {
          if (absent[i] == emp.initial) {
            isAbsent = true;
          }
        }
      }
      list.add(
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: Material(
            elevation: 5.0,
            color: isAbsent
                ? convertColor(emp.empColor).withOpacity(0.25)
                : convertColor(emp.empColor),
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
                  color: isAbsent
                      ? Theme.of(context).indicatorColor
                      : Theme.of(context).textSelectionColor,
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
      color: Theme.of(context).indicatorColor,
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

openPersonalShiftAlertBox(BuildContext context, String docID, String position,
    String date, String title, String shiftType) {
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
                      style: TextStyle(
                        fontSize: 24.0,
                      ),
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
                    shiftPositionContainer1ForShiftExchange = position;
                    shiftHolderContainer1ForShiftExchange = employee.initial;
                    shiftDateContainer1ForShiftExchange = date;
                    shiftExchangeMessage = reasonTextInputController.text;
                    reasonTextInputController.clear();
                    shiftTypeContainer1ForShiftExchange = shiftType;
                  },
                  child: InkWell(
                    child: Container(
                      padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(32.0),
                            bottomRight: Radius.circular(32.0)),
                      ),
                      child: Text(
                        "Exchange",
                        style: TextStyle(
                            color: Theme.of(context).textSelectionColor,
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

openChangeShiftsConfirmationAlertBox(
    BuildContext context,
    String docID,
    String position,
    String date,
    String title,
    String initials,
    String shiftType) {
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
                      style: TextStyle(
                        fontSize: 24.0,
                      ),
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
                          shiftDocIDContainer2ForShiftExchange = docID;
                          shiftPositionContainer2ForShiftExchange = position;
                          shiftHolderContainer2ForShiftExchange = initials;
                          shiftTypeContainer2ForShiftExchange = shiftType;
                          shiftDateContainer2ForShiftExchange = date;
                          dbController.addChangeRequestToFeed(
                              shiftDocIDContainer1ForShiftExchange,
                              shiftDocIDContainer2ForShiftExchange,
                              shiftPositionContainer1ForShiftExchange,
                              shiftPositionContainer2ForShiftExchange,
                              shiftHolderContainer1ForShiftExchange,
                              shiftHolderContainer2ForShiftExchange,
                              shiftDateContainer1ForShiftExchange,
                              shiftDateContainer2ForShiftExchange,
                              shiftTypeContainer1ForShiftExchange,
                              shiftTypeContainer2ForShiftExchange,
                              shiftExchangeMessage,
                              false);
                          String uid;
                          for (Employee emp in listWithEmployees) {
                            if (emp.initial ==
                                shiftHolderContainer2ForShiftExchange)
                              uid = emp.id;
                          }
                          dbController.addUserFeedItemToNotify(
                              uid,
                              'Exchange Request',
                              '${employee.name} wants to exchange with you!');
                          updateShiftExchangeValuesToNull();
                          Navigator.pop(context);
                          showConfirmationMessage();
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
                          updateShiftExchangeValuesToNull();
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

openNotificationAlertDialog(
    BuildContext context, String message, String title) {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(32.0))),
      content: ListTile(
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
        ),
        subtitle: Text(
          message,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
          ),
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text(
            'OK',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22.0,
            ),
          ),
          onPressed: () async {
            Navigator.of(context).pop();
          },
        ),
      ],
    ),
  );
}

openWeekEditorAlertDialog(BuildContext context, int startDayNumber) {
  double width = MediaQuery.of(context).size.width;
  double height = MediaQuery.of(context).size.height;
  double padding = (height - 380) / 2;
  return showDialog(
    context: context,
    builder: (context) => StatefulBuilder(builder: (context, setState) {
      return Padding(
        padding: EdgeInsets.only(top: padding, bottom: padding),
        child: Column(
          children: buildWeekdayStreamGroup(startDayNumber, context),
        ),
      );
    }),
  );
}

List<Widget> buildWeekdayStreamGroup(int startDayNumber, BuildContext context) {
  DateTime weekEditorDateTime =
      DateTime(dateTime.year, dateTime.month, startDayNumber);
  List<Widget> listOfStreams = [];

  for (int i = 0; i < 7; i++) {
    var newDateTime = weekEditorDateTime.add(Duration(days: i));
    listOfStreams.add(DaysStream(
        year: newDateTime.year,
        month: newDateTime.month,
        day: newDateTime.day));
  }
  listOfStreams.add(
    Material(
      borderRadius: BorderRadius.circular(15.0),
      child: IconButton(
          icon: Icon(
            Icons.cancel,
            color: Theme.of(context).indicatorColor,
          ),
          onPressed: () {
            Navigator.pop(context);
          }),
    ),
  );

  return listOfStreams;
}

class Shift {
  String holder;
  double hours;
  String position;
  String type;

  Shift(this.holder, this.hours, this.position, this.type);

  Map buildMap(String holder, double hours, String position, String type) {
    Map map = {
      'holder': holder,
      'hours': hours,
      'position': position,
      'type': type,
    };

    return map;
  }
}

class Day {
  int day;
  int month;
  int year;
  int id;
  bool isHoliday;
  List night;
  List morning;
  List evening;

  Day(this.day, this.month, this.year, this.isHoliday, this.night, this.morning,
      this.evening);
  Day.year(this.year);

  Map buildMap(int day, int month, int year, bool isHoliday, List night,
      List morning, List evening) {
    Map map = {
      'day': day,
      'month': month,
      'year': year,
      'isHoliday': isHoliday,
      'night': night,
      'morning': morning,
      'evening': evening,
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

int getNumberOfDaysInMonth(final int month, final int year) {
  int numDays = 28;

  // Months are 1, ..., 12
  switch (month) {
    case 1:
      numDays = 31;
      break;
    case 2:
      if ((2020 - year) % 4 == 0) {
        numDays = 29;
      } else
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
  shiftsScaffoldKey.currentState.showSnackBar(new SnackBar(
    content: new Text("Choose The Shift You Want"),
    duration: Duration(seconds: 2),
  ));
}

void showConfirmationMessage() {
  shiftsScaffoldKey.currentState.showSnackBar(new SnackBar(
    content: new Text("Your request has been sent"),
    duration: Duration(seconds: 2),
  ));
}

void showCancelMessage() {
  shiftsScaffoldKey.currentState.showSnackBar(new SnackBar(
    content: new Text("Shift exchange cancelled"),
    duration: Duration(seconds: 2),
  ));
}

void showCopyMessage() {
  shiftsScaffoldKey.currentState.showSnackBar(new SnackBar(
    content: new Text("Shift coppied"),
    duration: Duration(seconds: 2),
  ));
}

void showAbsentMessage() {
  shiftsScaffoldKey.currentState.showSnackBar(new SnackBar(
    content: new Text("Marked as not recommended for you"),
    duration: Duration(seconds: 2),
  ));
}

Color convertColor(String color) {
  int colorValueInt = int.parse(color, radix: 16);
  Color otherColor = new Color(colorValueInt);
  return otherColor;
}

void previousMonthSelected() {
  if (dateTime.month == DateTime.january) {
    dateTime = new DateTime(dateTime.year - 1, DateTime.december);
  } else {
    dateTime = new DateTime(dateTime.year, dateTime.month - 1);
  }
}

void nextMonthSelected() {
  if (dateTime.month == DateTime.december) {
    dateTime = new DateTime(dateTime.year + 1, DateTime.january);
  } else {
    dateTime = new DateTime(dateTime.year, dateTime.month + 1);
  }
}
