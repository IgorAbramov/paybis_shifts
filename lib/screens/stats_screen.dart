import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:paybis_com_shifts/constants.dart';
import 'package:paybis_com_shifts/models/employee.dart';
import 'package:paybis_com_shifts/models/progress.dart';

import 'login_screen.dart';
import 'shifts_screen.dart';

List<Day> daysWithInfo = [];

class StatsScreen extends StatefulWidget {
  static const String id = 'stats_screen';
  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int amountOfShiftsThisMonth = 0;
  int nightShiftsCountThisMonth = 0;
  int morningShiftsCountThisMonth = 0;
  int eveningShiftsCountThisMonth = 0;
  double nightShiftHoursCountThisMonth = 0;
  double morningShiftHoursCountThisMonth = 0;
  double eveningShiftHoursCountThisMonth = 0;
  double nightSalary = 0;
  double morningSalary = 0;
  double eveningSalary = 0;
  double salary = 0;

  void getAllPersonalData(Employee employee) {
    amountOfShiftsThisMonth = 0;
    nightShiftsCountThisMonth = 0;
    morningShiftsCountThisMonth = 0;
    eveningShiftsCountThisMonth = 0;
    nightShiftHoursCountThisMonth = 0;
    morningShiftHoursCountThisMonth = 0;
    eveningShiftHoursCountThisMonth = 0;
    nightSalary = 0;
    morningSalary = 0;
    eveningSalary = 0;
    salary = 0;

    print(daysWithInfo.length);

    calculateAmountOfShifts(employee);
    calculateAmountOfNightShifts(employee);
    calculateAmountOfMorningShifts(employee);
    calculateAmountOfEveningShifts(employee);
    calculateSalaryThisMonth(employee);
  }

  @override
  void initState() {
    super.initState();
    daysWithInfo.clear();
  }

  @override
  Widget build(BuildContext context) {
    if (employee.department != kSuperAdmin || employee.department != kAdmin)
      getAllPersonalData(employee);

    return (employee.department == kSuperAdmin || employee.department == kAdmin)
        ? Scaffold(
            appBar: AppBar(
              title: Text('Stats for ${getMonthName(dateTime.month)}'),
            ),
            body: Container(
              child: Column(
                children: <Widget>[
                  Table(
                    border: TableBorder.all(
                      color: secondaryColor,
                    ),
                    columnWidths: (employee.department == kSuperAdmin)
                        ? {
                            0: FlexColumnWidth(1),
                            1: FlexColumnWidth(1),
                            2: FlexColumnWidth(0.6),
                            3: FlexColumnWidth(0.8),
                            4: FlexColumnWidth(0.8),
                            5: FlexColumnWidth(0.8),
                          }
                        : {
                            0: FlexColumnWidth(1),
                            1: FlexColumnWidth(0.6),
                            2: FlexColumnWidth(0.8),
                            3: FlexColumnWidth(0.8),
                            4: FlexColumnWidth(0.8),
                          },
                    children: [
                      TableRow(
                        decoration: BoxDecoration(color: darkPrimaryColor),
                        children: (employee.department == kSuperAdmin)
                            ? [
                                TableCell(
                                  child: Text(
                                    'Name',
                                    style: kButtonFontStyle,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                TableCell(
                                  child: Text(
                                    'Salary',
                                    style: kButtonFontStyle,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                TableCell(
                                  child: Text(
                                    'Shifts',
                                    style: kButtonFontStyle,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                TableCell(
                                  child: Text(
                                    'Nights',
                                    style: kButtonFontStyle,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                TableCell(
                                  child: Text(
                                    'Mornings',
                                    style: kButtonFontStyle,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                TableCell(
                                  child: Text(
                                    'Evenings',
                                    style: kButtonFontStyle,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ]
                            : [
                                TableCell(
                                  child: Text(
                                    'Name',
                                    style: kButtonFontStyle,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                TableCell(
                                  child: Text(
                                    'Shifts',
                                    style: kButtonFontStyle,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                TableCell(
                                  child: Text(
                                    'Nights',
                                    style: kButtonFontStyle,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                TableCell(
                                  child: Text(
                                    'Mornings',
                                    style: kButtonFontStyle,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                TableCell(
                                  child: Text(
                                    'Evenings',
                                    style: kButtonFontStyle,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                      ),
                    ],
                  ),
                  StreamBuilder<QuerySnapshot>(
                      stream: dbController.createDaysStream(
                          dateTime.year, dateTime.month),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return circularProgress();
                        }
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
                          final String dayDocumentID = day.documentID;

                          final dayWithInfo = Day(
                              dayDay,
                              dayMonth,
                              dayYear,
                              dayIsHoliday,
                              nightShifts,
                              morningShifts,
                              eveningShifts);

//                          print(dayWithInfo);

                          if (!daysWithInfo.contains(dayWithInfo) &&
                              daysWithInfo.length <
                                  getNumberOfDaysInMonth(
                                      dateTime.month, dateTime.year))
                            daysWithInfo.add(dayWithInfo);
                        }
                        return Expanded(
                          child: ListView(
                            children: (employee.department == kSuperAdmin)
                                ? listStatsObjects()
                                : listStatsObjectsWithoutSalary(),
                          ),
                        );
                      }),
                ],
              ),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              title: Text(
                  'Hi ${employee.name}! Stats for ${getMonthName(dateTime.month)}'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(15.0),
              child: StreamBuilder<QuerySnapshot>(
                  stream: dbController.createDaysStream(
                      dateTime.year, dateTime.month),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return circularProgress();
                    }
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
                      final String dayDocumentID = day.documentID;

                      final dayWithInfo = Day(
                          dayDay,
                          dayMonth,
                          dayYear,
                          dayIsHoliday,
                          nightShifts,
                          morningShifts,
                          eveningShifts);

                      if (daysWithInfo.contains(dayWithInfo) ||
                          daysWithInfo.length ==
                              getNumberOfDaysInMonth(
                                  dateTime.month, dateTime.year)) {
                        daysWithInfo.clear();
                      }
                      if (!daysWithInfo.contains(dayWithInfo) &&
                          daysWithInfo.length <
                              getNumberOfDaysInMonth(
                                  dateTime.month, dateTime.year))
                        daysWithInfo.add(dayWithInfo);
                    }
                    return listStatsForEmp();
                  }),
            ),
          );
  }

  int index = 2;

  calculateAmountOfShifts(Employee employee) {
    for (Day day in daysWithInfo) {
      for (int i = 0; i < day.night.length; i++) {
        if (day.night[i].containsValue(employee.initial) &&
            day.month == dateTime.month) amountOfShiftsThisMonth++;
      }
      for (int i = 0; i < day.morning.length; i++) {
        if (day.morning[i].containsValue(employee.initial) &&
            day.month == dateTime.month) amountOfShiftsThisMonth++;
      }
      for (int i = 0; i < day.evening.length; i++) {
        if (day.evening[i].containsValue(employee.initial) &&
            day.month == dateTime.month) amountOfShiftsThisMonth++;
      }
    }
  }

  calculateAmountOfNightShifts(Employee employee) {
    for (Day day in daysWithInfo) {
      for (int i = 0; i < day.night.length; i++) {
        if (day.night[i].containsValue(employee.initial)) {
          nightShiftsCountThisMonth++;
          if (day.isHoliday) {
            nightShiftHoursCountThisMonth =
                nightShiftHoursCountThisMonth + (day.night[i]['hours']) * 2;
            nightSalary = nightSalary +
                2 *
                    calculateSalary(day.night[i]['hours'].toDouble(),
                        day.night[i]['position'], day.night[i]['type']);
          } else {
            nightShiftHoursCountThisMonth =
                nightShiftHoursCountThisMonth + day.night[i]['hours'];
            nightSalary = nightSalary +
                calculateSalary(day.night[i]['hours'].toDouble(),
                    day.night[i]['position'], day.night[i]['type']);
          }
        }
      }
    }
  }

  calculateAmountOfMorningShifts(Employee employee) {
    for (Day day in daysWithInfo) {
      for (int i = 0; i < day.morning.length; i++) {
        if (day.morning[i].containsValue(employee.initial)) {
          morningShiftsCountThisMonth++;
          if (day.isHoliday) {
            morningShiftHoursCountThisMonth = morningShiftHoursCountThisMonth +
                (day.morning[i]['hours'].toDouble()) * 2;
            morningSalary = morningSalary +
                2 *
                    calculateSalary(day.morning[i]['hours'].toDouble(),
                        day.morning[i]['position'], day.morning[i]['type']);
          } else {
            morningShiftHoursCountThisMonth =
                morningShiftHoursCountThisMonth + day.morning[i]['hours'];
            morningSalary = morningSalary +
                calculateSalary(day.morning[i]['hours'].toDouble(),
                    day.morning[i]['position'], day.morning[i]['type']);
          }
        }
      }
    }
  }

  calculateAmountOfEveningShifts(Employee employee) {
    for (Day day in daysWithInfo) {
      for (int i = 0; i < day.evening.length; i++) {
        if (day.evening[i].containsValue(employee.initial)) {
          eveningShiftsCountThisMonth++;
          if (day.isHoliday) {
            eveningShiftHoursCountThisMonth =
                eveningShiftHoursCountThisMonth + (day.evening[i]['hours']) * 2;
            eveningSalary = eveningSalary +
                2 *
                    calculateSalary(day.evening[i]['hours'].toDouble(),
                        day.evening[i]['position'], day.evening[i]['type']);
          } else {
            eveningShiftHoursCountThisMonth =
                eveningShiftHoursCountThisMonth + day.evening[i]['hours'];
            eveningSalary = eveningSalary +
                calculateSalary(day.evening[i]['hours'].toDouble(),
                    day.evening[i]['position'], day.evening[i]['type']);
          }
        }
      }
    }
  }

  double calculateSalary(double hours, String position, String shiftType) {
    double addSalary;
    if (position == kJuniorSupport) {
      if (shiftType == kNight)
        return addSalary = hours * kJuniorSupportSalary[1];
      else
        return addSalary = hours * kJuniorSupportSalary[0];
    } else if (position == kMiddleSupport) {
      if (shiftType == kNight)
        return addSalary = hours * kMiddleSupportSalary[1];
      else
        return addSalary = hours * kMiddleSupportSalary[0];
    } else if (position == kSeniorSupport) {
      if (shiftType == kNight)
        return addSalary = hours * kSeniorSupportSalary[1];
      else
        return addSalary = hours * kSeniorSupportSalary[0];
    } else if (position == kAMLCertifiedSupport) {
      if (shiftType == kNight)
        return addSalary = hours * kAMLCertifiedSupportSalary[1];
      else
        return addSalary = hours * kAMLCertifiedSupportSalary[0];
    } else if (position == kTeamLeadSupport) {
      if (shiftType == kNight)
        return addSalary = hours * kTeamLeadSupportSalary[1];
      else
        return addSalary = hours * kTeamLeadSupportSalary[0];
    }
  }

  calculateSalaryThisMonth(Employee employee) {
//    print('evening: $eveningSalary');
//    print('morning: $morningSalary');
//    print('night: $nightSalary');
    salary = eveningSalary + nightSalary + morningSalary;
  }

  List<StatsObject> listStatsObjects() {
    List<StatsObject> list = List<StatsObject>();

    for (Employee emp in listWithEmployees) {
      if (emp.department == kSupportDepartment) {
        getAllPersonalData(emp);

        StatsObject statsObject = StatsObject(
            emp.name,
            salary,
            nightShiftHoursCountThisMonth,
            morningShiftHoursCountThisMonth,
            eveningShiftHoursCountThisMonth,
            amountOfShiftsThisMonth,
            nightShiftsCountThisMonth,
            eveningShiftsCountThisMonth,
            morningShiftsCountThisMonth);
        list.add(statsObject);
      }
    }

    return list;
  }

  List<StatsObjectWithoutSalary> listStatsObjectsWithoutSalary() {
    List<StatsObjectWithoutSalary> list = List<StatsObjectWithoutSalary>();

    for (Employee emp in listWithEmployees) {
      if (emp.department == kSupportDepartment) {
        getAllPersonalData(emp);

        StatsObjectWithoutSalary statsObject = StatsObjectWithoutSalary(
            emp.name,
            nightShiftHoursCountThisMonth,
            morningShiftHoursCountThisMonth,
            eveningShiftHoursCountThisMonth,
            amountOfShiftsThisMonth,
            nightShiftsCountThisMonth,
            eveningShiftsCountThisMonth,
            morningShiftsCountThisMonth);
        list.add(statsObject);
      }
    }

    return list;
  }

  Widget listStatsForEmp() {
    getAllPersonalData(employee);

    StatsForTheEmp statsObjectForEmp = StatsForTheEmp(
        employee.name,
        salary,
        nightShiftHoursCountThisMonth,
        morningShiftHoursCountThisMonth,
        eveningShiftHoursCountThisMonth,
        amountOfShiftsThisMonth,
        nightShiftsCountThisMonth,
        morningShiftsCountThisMonth,
        eveningShiftsCountThisMonth);

    return statsObjectForEmp;
  }
}

class StatsForTheEmp extends StatelessWidget {
  final String name;
  final double salary;
  final double eveningShiftHoursCountThisMonth;
  final double morningShiftHoursCountThisMonth;
  final double nightShiftHoursCountThisMonth;
  final int amountOfShiftsThisMonth;
  final int nightShiftsCountThisMonth;
  final int morningShiftsCountThisMonth;
  final int eveningShiftsCountThisMonth;

  StatsForTheEmp(
      this.name,
      this.salary,
      this.nightShiftHoursCountThisMonth,
      this.morningShiftHoursCountThisMonth,
      this.eveningShiftHoursCountThisMonth,
      this.amountOfShiftsThisMonth,
      this.nightShiftsCountThisMonth,
      this.morningShiftsCountThisMonth,
      this.eveningShiftsCountThisMonth);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        RichText(
          text: TextSpan(
            text: 'Amount of shifts: ',
            style: kPersonalPageDataTextStyle,
            children: <TextSpan>[
              TextSpan(
                text: ' $amountOfShiftsThisMonth',
                style: TextStyle(color: darkPrimaryColor, fontSize: 22.0),
              ),
            ],
          ),
        ),
        Text('Amount of night shifts: $nightShiftsCountThisMonth',
            style: kPersonalPageDataTextStyle),
        Text('Amount of morning shifts: $morningShiftsCountThisMonth',
            style: kPersonalPageDataTextStyle),
        Text('Amount of evening shifts: $eveningShiftsCountThisMonth',
            style: kPersonalPageDataTextStyle),
        Text(
            'Amount of evening and morning hours: ${eveningShiftHoursCountThisMonth + morningShiftHoursCountThisMonth}',
            style: kPersonalPageDataTextStyle),
        Text('Amount of night hours: $nightShiftHoursCountThisMonth',
            style: kPersonalPageDataTextStyle),
        RichText(
          text: TextSpan(
            text: 'Salary: ',
            style: kPersonalPageDataTextStyle,
            children: <TextSpan>[
              TextSpan(
                text: ' ${salary.toStringAsFixed(2)}',
                style: TextStyle(color: darkPrimaryColor, fontSize: 22.0),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class StatsObject extends StatelessWidget {
  final String name;
  final double salary;
  final double nightHours;
  final double morningHours;
  final double eveningHours;
  final int amountOfShifts;
  final int amountOfNightShifts;
  final int amountOfEveningShifts;
  final int amountOfMorningShifts;

  StatsObject(
      this.name,
      this.salary,
      this.nightHours,
      this.morningHours,
      this.eveningHours,
      this.amountOfShifts,
      this.amountOfNightShifts,
      this.amountOfEveningShifts,
      this.amountOfMorningShifts);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(top: 2.0),
        child: Table(
          border: TableBorder.all(
            color: secondaryColor,
          ),
          columnWidths: {
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(0.6),
            3: FlexColumnWidth(0.8),
            4: FlexColumnWidth(0.8),
            5: FlexColumnWidth(0.8),
          },
          children: [
            TableRow(
              decoration:
                  BoxDecoration(color: darkPrimaryColor.withOpacity(0.7)),
              children: [
                TableCell(
                  child: Text(
                    name,
                    style: kButtonFontStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
                TableCell(
                  child: Text(
                    '${salary.toStringAsFixed(2)}',
                    style: kButtonFontStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
                TableCell(
                  child: Text(
                    '$amountOfShifts',
                    style: kButtonFontStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
                TableCell(
                  child: Column(children: <Widget>[
                    Text(
                      '$amountOfNightShifts',
                      style: kButtonFontStyle,
                    ),
                    Text(
                      '($nightHours)',
                      style: kButtonFontStyle,
                    ),
                  ]),
                ),
                TableCell(
                  child: Column(children: <Widget>[
                    Text(
                      '$amountOfMorningShifts',
                      style: kButtonFontStyle,
                    ),
                    Text(
                      '($morningHours)',
                      style: kButtonFontStyle,
                    ),
                  ]),
                ),
                TableCell(
                  child: Column(children: <Widget>[
                    Text(
                      '$amountOfEveningShifts',
                      style: kButtonFontStyle,
                    ),
                    Text(
                      '($eveningHours)',
                      style: kButtonFontStyle,
                    ),
                  ]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class StatsObjectWithoutSalary extends StatelessWidget {
  final String name;
  final double nightHours;
  final double morningHours;
  final double eveningHours;
  final int amountOfShifts;
  final int amountOfNightShifts;
  final int amountOfEveningShifts;
  final int amountOfMorningShifts;

  StatsObjectWithoutSalary(
      this.name,
      this.nightHours,
      this.morningHours,
      this.eveningHours,
      this.amountOfShifts,
      this.amountOfNightShifts,
      this.amountOfEveningShifts,
      this.amountOfMorningShifts);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(top: 2.0),
        child: Table(
          border: TableBorder.all(
            color: secondaryColor,
          ),
          columnWidths: {
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(0.6),
            2: FlexColumnWidth(0.8),
            3: FlexColumnWidth(0.8),
            4: FlexColumnWidth(0.8),
          },
          children: [
            TableRow(
              decoration:
                  BoxDecoration(color: darkPrimaryColor.withOpacity(0.7)),
              children: [
                TableCell(
                  child: Text(
                    name,
                    style: kButtonFontStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
                TableCell(
                  child: Text(
                    '$amountOfShifts',
                    style: kButtonFontStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
                TableCell(
                  child: Column(children: <Widget>[
                    Text(
                      '$amountOfNightShifts',
                      style: kButtonFontStyle,
                    ),
                    Text(
                      '($nightHours)',
                      style: kButtonFontStyle,
                    ),
                  ]),
                ),
                TableCell(
                  child: Column(children: <Widget>[
                    Text(
                      '$amountOfMorningShifts',
                      style: kButtonFontStyle,
                    ),
                    Text(
                      '($morningHours)',
                      style: kButtonFontStyle,
                    ),
                  ]),
                ),
                TableCell(
                  child: Column(children: <Widget>[
                    Text(
                      '$amountOfEveningShifts',
                      style: kButtonFontStyle,
                    ),
                    Text(
                      '($eveningHours)',
                      style: kButtonFontStyle,
                    ),
                  ]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
