import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:paybis_com_shifts/constants.dart';
import 'package:paybis_com_shifts/models/progress.dart';

import 'login_screen.dart';
import 'shifts_screen.dart';

class CalendarScreen extends StatefulWidget {
  static const String id = 'calendar_screen';
  @override
  State<StatefulWidget> createState() {
    return CalendarState();
  }
}

class CalendarState extends State<CalendarScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
//  final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  QuerySnapshot _userEventSnapshot;
  int _beginMonthPadding = 0;

  CalendarState() {
    setMonthPadding();
  }

  @override
  void initState() {
    super.initState();

//    _firebaseMessaging.configure(
//      onMessage: (Map<String, dynamic> message) async {
//        print("******** - onMessage: $message");
//      },
//      onLaunch: (Map<String, dynamic> message) async {
//        print("******** - onLaunch: $message");
//      },
//      onResume: (Map<String, dynamic> message) async {
//        print("******** - onResume: $message");
//      },
//    );
//
//    _firebaseMessaging.requestNotificationPermissions(
//        const IosNotificationSettings(sound: true, badge: true, alert: true));
//    _firebaseMessaging.onIosSettingsRegistered
//        .listen((IosNotificationSettings settings) {
//      print("Settings registered: $settings");
//    });
//
//    _firebaseMessaging.getToken().then((String token) async {
//      assert(token != null);
//      print('push token: ' + token);
//
//      FirebaseUser user = await FirebaseAuth.instance.currentUser();
//      QuerySnapshot snapshot = await Firestore.instance
//          .collection('users')
//          .where('email', isEqualTo: user.email)
//          .getDocuments();
//
//      snapshot.documents.forEach((doc) {
//        Firestore.instance
//            .collection('users')
//            .document(doc.documentID)
//            .setData({'email': user.email, 'token': token});
//      });
//    });
  }

  void setMonthPadding() {
    _beginMonthPadding =
        new DateTime(dateTime.year, dateTime.month, 1).weekday - 1;
    _beginMonthPadding == 7 ? (_beginMonthPadding = 0) : _beginMonthPadding;
  }

//  Future<QuerySnapshot> _getCalendarData() async {
//    FirebaseUser currentUser = await _auth.currentUser();
//
//    if (currentUser != null) {
//      QuerySnapshot userEvents = await Firestore.instance
//          .collection('calendar_events')
//          .where('time',
//              isGreaterThanOrEqualTo:
//                  new DateTime(dateTime.year, dateTime.month))
//          .where('email', isEqualTo: currentUser.email)
//          .getDocuments();
//
//      _userEventSnapshot = userEvents;
//      return _userEventSnapshot;
//    } else {
//      return null;
//    }
//  }
//
//  void _goToToday() {
//    print("trying to go to the month of today");
//    setState(() {
//      dateTime = DateTime.now();
//      setMonthPadding();
//    });
//  }
//
//  void _onDayTapped(int day) {
//    Navigator.push(
//        context,
//        new MaterialPageRoute(
//            builder: (BuildContext context) => new EventsView(
//                new DateTime(dateTime.year, dateTime.month, day))));
//  }

  @override
  Widget build(BuildContext context) {
    final int numWeekDays = 7;
    var size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    /*28 is for weekday labels of the row*/
    // 55 is for iPhoneX clipping issue.
    final double itemHeight = (size.height -
            kToolbarHeight -
            kBottomNavigationBarHeight -
            24 -
            28 -
            55) /
        6;
    final double itemWidth = size.width / numWeekDays;

    return new Scaffold(
        backgroundColor: Colors.white,
        appBar: new AppBar(
          title: new FittedBox(
              fit: BoxFit.contain,
              child: new Text(
                getMonthName(dateTime.month) + " " + dateTime.year.toString(),
              )),
          actions: <Widget>[
//            IconButton(
//                icon: Icon(
//                  Icons.today,
//                  color: Colors.white,
//                ),
//                onPressed: _goToToday),
            IconButton(
                icon: Icon(
                  Icons.chevron_left,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    previousMonthSelected();
                    setMonthPadding();
                  });
                }),
            IconButton(
                icon: Icon(
                  Icons.chevron_right,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    nextMonthSelected();
                    setMonthPadding();
                  });
                }),
          ],
        ),
        body: StreamBuilder(
            stream:
                dbController.createDaysStream(dateTime.year, dateTime.month),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return circularProgress();
              }
              if (daysWithShiftsForCountThisMonth.isNotEmpty)
                daysWithShiftsForCountThisMonth.clear();

              final days = snapshot.data.documents;
              for (var day in days) {
                final int dayDay = day.data['day'];
                final int dayMonth = day.data['month'];
                final int dayYear = day.data['year'];
                final int dayId = day.data['id'];
                currentDocument = day;

                Map<dynamic, dynamic> shift1 = day.data['1'];
                Map<dynamic, dynamic> shift2 = day.data['2'];
                Map<dynamic, dynamic> shift3 = day.data['3'];
                Map<dynamic, dynamic> shift4 = day.data['4'];
                Map<dynamic, dynamic> shift5 = day.data['5'];
                Map<dynamic, dynamic> shift6 = day.data['6'];
                Map<dynamic, dynamic> shift7 = day.data['7'];
                Map<dynamic, dynamic> shift8 = day.data['8'];
                Map<dynamic, dynamic> shift9 = day.data['9'];

                final dayWithShifts = Day(
                    dayDay,
                    dayMonth,
                    dayYear,
                    dayId,
                    shift1,
                    shift2,
                    shift3,
                    shift4,
                    shift5,
                    shift6,
                    shift7,
                    shift8,
                    shift9);

                if (!daysWithShiftsForCountThisMonth.contains(dayWithShifts) &&
                    daysWithShiftsForCountThisMonth.length <
                        getNumberOfDaysInMonth(dateTime.month))
                  daysWithShiftsForCountThisMonth.add(dayWithShifts);
              }
              return Column(
                children: <Widget>[
                  new Row(
                    children: <Widget>[
                      new Expanded(
                          child: new Text('Mon',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headline)),
                      new Expanded(
                          child: new Text('Tue',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headline)),
                      new Expanded(
                          child: new Text('Wed',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headline)),
                      new Expanded(
                          child: new Text('Thu',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headline)),
                      new Expanded(
                          child: new Text('Fri',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headline)),
                      new Expanded(
                          child: new Text('Sat',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline
                                  .copyWith(color: accentColor))),
                      new Expanded(
                          child: new Text('Sun',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline
                                  .copyWith(color: accentColor))),
                    ],
                    mainAxisSize: MainAxisSize.min,
                  ),
                  new GridView.count(
                    crossAxisCount: numWeekDays,
                    childAspectRatio: (itemWidth / itemHeight),
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    children: List.generate(
                        getNumberOfDaysInMonth(dateTime.month), (index) {
                      int dayNumber = index + 1;
                      return new GestureDetector(
                          // Used for handling tap on each day view
//                    onTap: () => _onDayTapped(dayNumber - _beginMonthPadding),
                          child: new Container(
                              margin: const EdgeInsets.all(2.0),
                              padding: const EdgeInsets.all(1.0),
                              decoration: new BoxDecoration(
                                  border: new Border.all(color: Colors.grey)),
                              child: new Column(
                                children: <Widget>[
                                  buildDayNumberWidget(dayNumber),
                                  buildDayEventInfoWidget(dayNumber)
                                ],
                              )));
                    }),
                  )
                ],
              );
            }));
  }

  Align buildDayNumberWidget(int dayNumber) {
    //print('buildDayNumberWidget, dayNumber: $dayNumber');
    if ((dayNumber - _beginMonthPadding) == DateTime.now().day &&
        dateTime.month == DateTime.now().month &&
        dateTime.year == DateTime.now().year) {
      // Add a circle around the current day
      return Align(
        alignment: Alignment.topLeft,
        child: Container(
          width: 40.0, // Should probably calculate these values
          height: 40.0,
          padding: EdgeInsets.all(5.0),
          decoration: BoxDecoration(
//            shape: BoxShape.circle,
            color: secondaryColor,
            border: Border.all(),
          ),
          child: new Text(
            (dayNumber - _beginMonthPadding).toString(),
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .title
                .copyWith(color: Colors.white, fontSize: 20.0),
          ),
        ),
      );
    } else {
      // No circle around the current day
      return Align(
        alignment: Alignment.topLeft,
        child: Container(
          width: 35.0, // Should probably calculate these values
          height: 35.0,
          padding: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 0.0),
          child: new Text(
            dayNumber <= _beginMonthPadding
                ? ' '
                : (dayNumber - _beginMonthPadding).toString(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headline.copyWith(
                  color: (dayNumber == 7 ||
                          dayNumber == 6 ||
                          dayNumber == 13 ||
                          dayNumber == 14 ||
                          dayNumber == 20 ||
                          dayNumber == 21 ||
                          dayNumber == 27 ||
                          dayNumber == 28 ||
                          dayNumber == 34 ||
                          dayNumber == 35)
                      ? accentColor
                      : Colors.black,
                ),
          ),
        ),
      );
    }
  }

  Widget buildDayEventInfoWidget(int dayNumber) {
    int shiftCount = 0;
    String shiftType;
    DateTime eventDate;
    for (Day day in daysWithShiftsForCountThisMonth) {
      if (day.s1.containsValue(employee.initial) &&
          day.month == dateTime.month &&
          day.day == dayNumber - _beginMonthPadding) {
        shiftCount++;
        shiftType = 'Night....';
      }
      if (day.s2.containsValue(employee.initial) &&
          day.month == dateTime.month &&
          day.day == dayNumber - _beginMonthPadding) {
        shiftCount++;
        shiftType = 'Night....';
      }

      if (day.s3.containsValue(employee.initial) &&
          day.month == dateTime.month &&
          day.day == dayNumber - _beginMonthPadding) {
        shiftCount++;
        shiftType = 'Night....';
      }

      if (day.s4.containsValue(employee.initial) &&
          day.month == dateTime.month &&
          day.day == dayNumber - _beginMonthPadding) {
        shiftCount++;
        shiftType = 'Morning';
      }

      if (day.s5.containsValue(employee.initial) &&
          day.month == dateTime.month &&
          day.day == dayNumber - _beginMonthPadding) {
        shiftCount++;
        shiftType = 'Morning';
      }

      if (day.s6.containsValue(employee.initial) &&
          day.month == dateTime.month &&
          day.day == dayNumber - _beginMonthPadding) {
        shiftCount++;
        shiftType = 'Morning';
      }

      if (day.s7.containsValue(employee.initial) &&
          day.month == dateTime.month &&
          day.day == dayNumber - _beginMonthPadding) {
        shiftCount++;
        shiftType = 'Evening';
      }

      if (day.s8.containsValue(employee.initial) &&
          day.month == dateTime.month &&
          day.day == dayNumber - _beginMonthPadding) {
        shiftCount++;
        shiftType = 'Evening';
      }

      if (day.s9.containsValue(employee.initial) &&
          day.month == dateTime.month &&
          day.day == dayNumber - _beginMonthPadding) {
        shiftCount++;
        shiftType = 'Evening';
      }
    }

//
//    _userEventSnapshot.documents.forEach((doc) {
//      eventDate = DateTime(doc.data['time']);
//      if (eventDate != null &&
//          eventDate.day == dayNumber - _beginMonthPadding &&
//          eventDate.month == dateTime.month &&
//          eventDate.year == dateTime.year) {
//        eventCount++;
//      }
//    });

    if (shiftCount > 0) {
      return new Expanded(
        child: FittedBox(
          alignment: Alignment.topLeft,
          fit: BoxFit.contain,
          child: new Text(
            shiftType,
            maxLines: 1,
            style: new TextStyle(
                fontSize: 7.0,
                color: Colors.black,
                fontWeight: FontWeight.bold,
                background: Paint()..color = textIconColor),
          ),
        ),
      );
    } else {
      return new Container();
    }
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
}
