import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:paybis_com_shifts/constants.dart';
import 'package:paybis_com_shifts/models/employee.dart';
import 'package:paybis_com_shifts/models/progress.dart';

import 'login_screen.dart';
import 'shifts_screen.dart';

String _btnDepartmentText = 'SUP';
String _btnTypeText = 'Vacations';
final adminCalendarScreenKey = new GlobalKey<AdminCalendarState>();

class AdminCalendarScreen extends StatefulWidget {
  static const String id = 'admin_calendar_screen';
  const AdminCalendarScreen({Key key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return AdminCalendarState();
  }
}

class AdminCalendarState extends State<AdminCalendarScreen> {
  String parkingStatus = 'free';
  int _beginMonthPadding = 0;

  CalendarState() {
    setMonthPadding();
  }

  void rebuild() {
    setState(() {});
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
    _beginMonthPadding = DateTime(dateTime.year, dateTime.month, 1).weekday - 1;
    _beginMonthPadding == 7 ? (_beginMonthPadding = 0) : _beginMonthPadding;
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    ScreenUtil.init(context, width: 1080, height: 2220, allowFontScaling: true);
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

    return Scaffold(
      drawerScrimColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        actions: <Widget>[
          Material(
            elevation: 0.0,
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(30.0),
            child: MaterialButton(
              onPressed: () {
                setState(() {
                  if (_btnTypeText == 'Vacations') {
                    _btnTypeText = 'Sick Leaves';
                  } else
                    _btnTypeText = 'Vacations';
                });
              },
              minWidth: 26.0,
              height: 26.0,
              child: Text(
                _btnTypeText,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                ),
              ),
            ),
          ),
          Material(
            elevation: 0.0,
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(30.0),
            child: MaterialButton(
              onPressed: () {
                setState(() {
                  if (_btnDepartmentText == 'SUP') {
                    _btnDepartmentText = 'IT';
                  } else
                    _btnDepartmentText = 'SUP';
                });
              },
              minWidth: 26.0,
              height: 26.0,
              child: Text(
                _btnDepartmentText,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                ),
              ),
            ),
          ),
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
      body: Column(
        children: <Widget>[
          FittedBox(
              fit: BoxFit.contain,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  getMonthName(dateTime.month) + " " + dateTime.year.toString(),
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )),
          StreamBuilder(
              stream:
                  dbController.createDaysStream(dateTime.year, dateTime.month),
              builder: (context, snapshot) {
                List emptyDay = [];
                List daysOff = [];

                for (int i = 0; i < _beginMonthPadding; i++) {
                  daysOff.add(emptyDay);
                }
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
                  final bool dayIsHoliday = day.data['isHoliday'];
                  final List nightShifts = [];
                  final List morningShifts = [];
                  final List eveningShifts = [];
                  if (_btnDepartmentText == 'SUP' &&
                      _btnTypeText == 'Vacations') {
                    final List vacation = day.data['vacations'];
                    if (vacation != null) {
                      daysOff.add(vacation);
                    } else
                      daysOff.add(emptyDay);
                  }
                  if (_btnDepartmentText == 'IT' &&
                      _btnTypeText == 'Vacations') {
                    final List vacation = day.data['ITVacations'];
                    if (vacation != null) {
                      daysOff.add(vacation);
                    } else
                      daysOff.add(emptyDay);
                  }
                  if (_btnDepartmentText == 'SUP' &&
                      _btnTypeText == 'Sick Leaves') {
                    final List vacation = day.data['sick'];
                    if (vacation != null) {
                      daysOff.add(vacation);
                    } else
                      daysOff.add(emptyDay);
                  }
                  if (_btnDepartmentText == 'IT' &&
                      _btnTypeText == 'Sick Leaves') {
                    final List vacation = day.data['ITSick'];
                    if (vacation != null) {
                      daysOff.add(vacation);
                    } else
                      daysOff.add(emptyDay);
                  }

                  currentDocument = day;

                  final dayWithShifts = Day(dayDay, dayMonth, dayYear,
                      dayIsHoliday, nightShifts, morningShifts, eveningShifts);

                  if (!daysWithShiftsForCountThisMonth
                          .contains(dayWithShifts) &&
                      daysWithShiftsForCountThisMonth.length <
                          getNumberOfDaysInMonth(dateTime.month))
                    daysWithShiftsForCountThisMonth.add(dayWithShifts);
                }
                return Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                            child: Text('Mon',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headline5)),
                        Expanded(
                            child: Text('Tue',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headline5)),
                        Expanded(
                            child: Text('Wed',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headline5)),
                        Expanded(
                            child: Text('Thu',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headline5)),
                        Expanded(
                            child: Text('Fri',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headline5)),
                        Expanded(
                            child: Text('Sat',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline5
                                    .copyWith(color: accentColor))),
                        Expanded(
                            child: Text('Sun',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline5
                                    .copyWith(color: accentColor))),
                      ],
                      mainAxisSize: MainAxisSize.min,
                    ),
                    GridView.count(
                      crossAxisCount: numWeekDays,
                      childAspectRatio: (itemWidth / itemHeight),
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      children: List.generate(
                          getNumberOfDaysInMonth(dateTime.month), (index) {
                        int dayNumber = index + 1;
                        return GestureDetector(
                            // Used for handling tap on each day view
//                    onTap: () => _onDayTapped(dayNumber - _beginMonthPadding),
                            child: Container(
                                margin: const EdgeInsets.all(1.0),
                                padding: const EdgeInsets.all(1.0),
                                decoration: BoxDecoration(
                                  gradient: RadialGradient(
                                      colors: [primaryColor, darkPrimaryColor]),
                                  color: ((dayNumber - _beginMonthPadding) ==
                                              DateTime.now().day &&
                                          dateTime.month ==
                                              DateTime.now().month &&
                                          dateTime.year == DateTime.now().year)
                                      ? darkPrimaryColor
                                      : (dayNumber - _beginMonthPadding <= 0)
                                          ? Colors.transparent
                                          : darkPrimaryColor.withOpacity(0.1),
                                  border: Border.all(color: Colors.grey),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                ),
                                child: Column(
                                  children: <Widget>[
                                    buildDayNumberWidget(dayNumber),
                                    buildDayEventInfoWidget(dayNumber, daysOff)
                                  ],
                                )));
                      }),
                    ),
                  ],
                );
              }),
        ],
      ),
    );
  }

  Align buildDayNumberWidget(int dayNumber) {
    if ((dayNumber - _beginMonthPadding) == DateTime.now().day &&
        dateTime.month == DateTime.now().month &&
        dateTime.year == DateTime.now().year) {
      // Add a circle around the current day
      return Align(
        alignment: Alignment.topLeft,
        child: Container(
          width: ScreenUtil().setWidth(110),
          height: ScreenUtil().setHeight(100),
          padding: EdgeInsets.all(5.0),
          decoration: BoxDecoration(),
          child: Text(
            (dayNumber - _beginMonthPadding).toString(),
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .headline6
                .copyWith(color: Colors.white, fontSize: 20.0),
          ),
        ),
      );
    } else {
      // No circle around the current day
      return Align(
        alignment: Alignment.topLeft,
        child: Container(
          width: ScreenUtil().setWidth(100),
          height: ScreenUtil().setHeight(100),
          padding: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 0.0),
          child: Text(
            dayNumber <= _beginMonthPadding
                ? ' '
                : (dayNumber - _beginMonthPadding).toString(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headline5.copyWith(
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
                      : textPrimaryColor,
                ),
          ),
        ),
      );
    }
  }

  Widget buildDayEventInfoWidget(int dayNumber, List vacations) {
    return Container(
      child: buildVacationInfoWidget(vacations[dayNumber - 1]),
    );
  }

  Widget buildVacationInfoWidget(List vacations) {
    List<Widget> vacationList = [];
    Color color = Colors.transparent;
    for (int i = 0; i < vacations.length; i++) {
      for (Employee emp in listWithEmployees) {
        if (emp.initial == vacations[i]) {
          color = convertColor(emp.empColor);
        }
      }

      Widget vacationText = Container(
        width: 150.0,
        decoration: BoxDecoration(
          color: color,
        ),
        child: Text(
          vacations[i],
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      );
      vacationList.add(vacationText);
    }

    return Column(
      children: vacationList,
    );
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
