import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:paybis_com_shifts/constants.dart';
import 'package:paybis_com_shifts/models/progress.dart';
import 'package:paybis_com_shifts/ui_parts/calendar_widgets.dart';

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
  String parkingStatus = 'free';
  int _beginMonthPadding = 0;

  CalendarState() {
    setMonthPadding();
  }

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIOverlays([]);
    super.initState();
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
          title: FittedBox(
              fit: BoxFit.contain,
              child: Text(
                getMonthName(dateTime.month) + " " + dateTime.year.toString(),
              )),
          actions: <Widget>[
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
              List emptyDay = [];
              List mgmt = [];
              List itcs = [];
              List vacations = [];
              for (int i = 0; i < _beginMonthPadding; i++) {
                mgmt.add(emptyDay);
                itcs.add(emptyDay);
                vacations.add(emptyDay);
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
                final List nightShifts = day.data['night'];
                final List morningShifts = day.data['morning'];
                final List eveningShifts = day.data['evening'];
                currentDocument = day;
//
                if (employee.hasCar) {
                  List mgmtDay = day.data['mgmt'];
                  List itcsDay = day.data['itcs'];
                  if (mgmtDay != null) {
                    mgmt.add(mgmtDay);
                  } else
                    mgmt.add(emptyDay);
                  if (itcsDay != null) {
                    itcs.add(itcsDay);
                  } else
                    itcs.add(emptyDay);
                }
                List vacation = [];
                if (employee.department == kSupportDepartment) {
                  vacation = day.data['vacations'];
                }
                if (employee.department == kITDepartment) {
                  vacation = day.data['ITVacations'];
                }
                if (vacation != null) {
                  vacations.add(vacation);
                } else
                  vacations.add(emptyDay);

                final dayWithShifts = Day(dayDay, dayMonth, dayYear,
                    dayIsHoliday, nightShifts, morningShifts, eveningShifts);

                if (!daysWithShiftsForCountThisMonth.contains(dayWithShifts) &&
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
                              style: kHeaderFontStyle.copyWith(
                                  fontSize: 18, color: Colors.black))),
                      Expanded(
                          child: Text('Tue',
                              textAlign: TextAlign.center,
                              style: kHeaderFontStyle.copyWith(
                                  fontSize: 18, color: Colors.black))),
                      Expanded(
                          child: Text('Wed',
                              textAlign: TextAlign.center,
                              style: kHeaderFontStyle.copyWith(
                                  fontSize: 18, color: Colors.black))),
                      Expanded(
                          child: Text('Thu',
                              textAlign: TextAlign.center,
                              style: kHeaderFontStyle.copyWith(
                                  fontSize: 18, color: Colors.black))),
                      Expanded(
                          child: Text('Fri',
                              textAlign: TextAlign.center,
                              style: kHeaderFontStyle.copyWith(
                                  fontSize: 18, color: Colors.black))),
                      Expanded(
                          child: Text('Sat',
                              textAlign: TextAlign.center,
                              style: kHeaderFontStyle.copyWith(
                                  fontSize: 18, color: accentColor))),
                      Expanded(
                          child: Text('Sun',
                              textAlign: TextAlign.center,
                              style: kHeaderFontStyle.copyWith(
                                  fontSize: 18, color: accentColor))),
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
                                  ((employee.hasCar) &&
                                          mgmt.length > index &&
                                          vacations.length > index)
                                      ? buildDayEventInfoWidget(
                                          dayNumber,
                                          mgmt[index],
                                          itcs[index],
                                          vacations[index])
                                      : (!employee.hasCar &&
                                              vacations.length > index)
                                          ? buildDayEventInfoWidget(
                                              dayNumber,
                                              emptyDay,
                                              emptyDay,
                                              vacations[index])
                                          : buildDayEventInfoWidget(dayNumber,
                                              emptyDay, emptyDay, emptyDay)
                                ],
                              )));
                    }),
                  )
                ],
              );
            }));
  }

  Align buildDayNumberWidget(int dayNumber) {
    if ((dayNumber - _beginMonthPadding) == DateTime.now().day &&
        dateTime.month == DateTime.now().month &&
        dateTime.year == DateTime.now().year) {
      // Add a circle around the current day
      return Align(
        alignment: Alignment.topLeft,
        child: Container(
          width: ScreenUtil().setWidth(120),
          height: ScreenUtil().setHeight(110),
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
          width: ScreenUtil().setWidth(110),
          height: ScreenUtil().setHeight(110),
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

  Widget buildDayEventInfoWidget(
      int dayNumber, List mgmt, List itcs, List vacations) {
    int shiftCount = 0;
    List<String> shifts = [];
    DateTime eventDate;
    bool vacationStatus = false;
    parkingStatus = 'free';

    if (employee.department == kSupportDepartment) {
      for (Day day in daysWithShiftsForCountThisMonth) {
        for (int i = 0; i < day.night.length; i++) {
          if (day.night[i].containsValue(employee.initial) &&
              day.month == dateTime.month &&
              day.day == dayNumber - _beginMonthPadding) {
            shiftCount++;
            shifts.add(kNight);
          }
        }
        for (int i = 0; i < day.morning.length; i++) {
          if (day.morning[i].containsValue(employee.initial) &&
              day.month == dateTime.month &&
              day.day == dayNumber - _beginMonthPadding) {
            shiftCount++;
            shifts.add(kMorning);
          }
        }
        for (int i = 0; i < day.evening.length; i++) {
          if (day.evening[i].containsValue(employee.initial) &&
              day.month == dateTime.month &&
              day.day == dayNumber - _beginMonthPadding) {
            shiftCount++;
            shifts.add(kEvening);
          }
        }
      }
    }

    if (mgmt != null) {
      if (mgmt.length >= 0) {
        for (int i = 0; i < mgmt.length; i++) {
          String mgmtConverted = mgmt[i];
          List<String> splitted = mgmtConverted.split(' ');
          if (splitted[0] == employee.initial) {
            parkingStatus = 'reserved';
          }
        }
      }
    }
    if (itcs != null) {
      if (itcs.length >= 0) {
        for (int i = 0; i < itcs.length; i++) {
          String itcsConverted = itcs[i];
          List<String> splitted = itcsConverted.split(' ');
          if (splitted[0] == employee.initial) {
            parkingStatus = 'reserved';
          }
        }
      }
    }
    if (itcs != null && mgmt != null) {
      if (mgmt.isNotEmpty && itcs.isNotEmpty) {
        if (parkingStatus == 'free' && mgmt.length == 3 && itcs.length >= 4) {
          parkingStatus = 'busy';
        }
      }
    }
    if (vacations != null) {
      if (vacations.length >= 0) {
        for (int i = 0; i < vacations.length; i++) {
          if (vacations[i] == employee.initial) {
            vacationStatus = true;
          }
        }
      }
    }

    if (employee.department == kSupportDepartment && shiftCount > 0) {
      return Expanded(
        child: FittedBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: (shifts[0] == 'Night')
                    ? const EdgeInsets.only(right: 15.0)
                    : const EdgeInsets.only(left: 0.0),
                child: Text(
                  shifts[0],
                  maxLines: 1,
                  style: TextStyle(
                      fontSize: 13.0,
                      color: textPrimaryColor,
                      fontWeight: FontWeight.bold,
                      background: Paint()..color = Colors.transparent),
                ),
              ),
              (shiftCount == 2)
                  ? Padding(
                      padding: (shifts[1] == 'Night')
                          ? const EdgeInsets.only(right: 15.0)
                          : const EdgeInsets.only(left: 0.0),
                      child: Text(
                        shifts[1],
                        maxLines: 1,
                        style: TextStyle(
                            fontSize: 13.0,
                            color: textPrimaryColor,
                            fontWeight: FontWeight.bold,
                            background: Paint()..color = Colors.transparent),
                      ))
                  : SizedBox(
                      height: 1.0,
                    ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  (employee.hasCar &&
                          parkingStatus == 'reserved' &&
                          (((dayNumber - _beginMonthPadding) >=
                                      DateTime.now().day &&
                                  dateTime.month == DateTime.now().month &&
                                  (dayNumber - _beginMonthPadding) <=
                                      DateTime.now().day + 7) ||
                              (dateTime.month > DateTime.now().month &&
                                  (dayNumber - _beginMonthPadding) < 7)))
                      ? ParkingWidget(Colors.lightGreenAccent)
                      : SizedBox(
                          height: 1.0,
                        ),
                  (employee.hasCar &&
                          parkingStatus == 'free' &&
                          (((dayNumber - _beginMonthPadding) >=
                                      DateTime.now().day &&
                                  dateTime.month == DateTime.now().month &&
                                  (dayNumber - _beginMonthPadding) <=
                                      DateTime.now().day + 7) ||
                              (dateTime.month > DateTime.now().month &&
                                  (dayNumber - _beginMonthPadding) < 7)))
                      ? ParkingWidget(Colors.yellowAccent)
                      : SizedBox(
                          height: 1.0,
                        ),
                  (employee.hasCar &&
                          parkingStatus == 'busy' &&
                          (((dayNumber - _beginMonthPadding) >=
                                      DateTime.now().day &&
                                  dateTime.month == DateTime.now().month &&
                                  (dayNumber - _beginMonthPadding) <=
                                      DateTime.now().day + 7) ||
                              (dateTime.month > DateTime.now().month &&
                                  (dayNumber - _beginMonthPadding) < 7)))
                      ? ParkingWidget(Colors.red)
                      : SizedBox(
                          height: 1.0,
                        ),
                  (vacationStatus)
                      ? VacationWidget()
                      : SizedBox(
                          height: 1.0,
                        ),
                ],
              ),
            ],
          ),
        ),
      );
    } else if ((shiftCount == 0 && vacationStatus) ||
        employee.department == kITDepartment ||
        employee.department == kMarketingDepartment ||
        employee.department == kManagement ||
        employee.department == kITAdmin) {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                (employee.department != kSupportDepartment &&
                        employee.hasCar &&
                        parkingStatus == 'reserved' &&
                        (((dayNumber - _beginMonthPadding) >=
                                    DateTime.now().day &&
                                dateTime.month == DateTime.now().month &&
                                (dayNumber - _beginMonthPadding) <=
                                    DateTime.now().day + 7) ||
                            (dateTime.month > DateTime.now().month &&
                                (dayNumber - _beginMonthPadding) < 7)))
                    ? FittedBox(
                        fit: BoxFit.fill,
                        child: ParkingWidget(Colors.lightGreenAccent))
                    : SizedBox(
                        height: 1.0,
                      ),
                (employee.department != kSupportDepartment &&
                        employee.hasCar &&
                        parkingStatus == 'free' &&
                        (((dayNumber - _beginMonthPadding) >=
                                    DateTime.now().day &&
                                dateTime.month == DateTime.now().month &&
                                (dayNumber - _beginMonthPadding) <=
                                    DateTime.now().day + 7) ||
                            (dateTime.month > DateTime.now().month &&
                                (dayNumber - _beginMonthPadding) < 7)))
                    ? FittedBox(
                        fit: BoxFit.fill,
                        child: ParkingWidget(Colors.yellowAccent))
                    : SizedBox(
                        height: 1.0,
                      ),
                (employee.department != kSupportDepartment &&
                        employee.hasCar &&
                        parkingStatus == 'busy' &&
                        (((dayNumber - _beginMonthPadding) >=
                                    DateTime.now().day &&
                                dateTime.month == DateTime.now().month &&
                                (dayNumber - _beginMonthPadding) <=
                                    DateTime.now().day + 7) ||
                            (dateTime.month > DateTime.now().month &&
                                (dayNumber - _beginMonthPadding) < 7)))
                    ? FittedBox(
                        fit: BoxFit.fill, child: ParkingWidget(Colors.red))
                    : SizedBox(
                        height: 1.0,
                      ),
                (vacationStatus)
                    ? VacationWidget()
                    : SizedBox(
                        height: 1.0,
                      ),
              ],
            ),
          ],
        ),
      );
    } else {
      return Container();
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
