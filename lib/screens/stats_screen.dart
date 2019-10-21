import 'package:flutter/material.dart';
import 'package:paybis_com_shifts/constants.dart';
import 'package:paybis_com_shifts/models/employee.dart';

import 'login_screen.dart';
import 'shifts_screen.dart';

class StatsScreen extends StatefulWidget {
  static const String id = 'stats_screen';
  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int amountOfShiftsThisMonth = 0;
//  int amountOfShiftsLastMonth = 0;
  int nightShiftsCountThisMonth = 0;
  int morningShiftsCountThisMonth = 0;
  int eveningShiftsCountThisMonth = 0;
  double nightShiftHoursCountThisMonth = 0;
  double morningShiftHoursCountThisMonth = 0;
  double eveningShiftHoursCountThisMonth = 0;
  double salary = 0;

  void getAllPersonalData(Employee employee) {
    amountOfShiftsThisMonth = 0;
    nightShiftsCountThisMonth = 0;
    morningShiftsCountThisMonth = 0;
    eveningShiftsCountThisMonth = 0;
    nightShiftHoursCountThisMonth = 0;
    morningShiftHoursCountThisMonth = 0;
    eveningShiftHoursCountThisMonth = 0;
    salary = 0;

//    print(daysWithShiftsForCountThisMonth.length);

    calculateAmountOfShifts(employee);
    calculateAmountOfNightShifts(employee);
    calculateAmountOfMorningShifts(employee);
    calculateAmountOfEveningShifts(employee);
    calculateSalaryThisMonth(employee);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (employee.department != kSuperAdmin) getAllPersonalData(employee);

    return (employee.department == kSuperAdmin)
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
                        decoration: BoxDecoration(color: darkPrimaryColor),
                        children: [
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
                        ],
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListView(
                      children: listStatsObjects(),
                    ),
                  ),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  RichText(
                    text: TextSpan(
                      text: 'Amount of shifts: ',
                      style: kPersonalPageDataTextStyle,
                      children: <TextSpan>[
                        TextSpan(
                          text: ' $amountOfShiftsThisMonth',
                          style: TextStyle(
                              color: darkPrimaryColor, fontSize: 22.0),
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
                          style: TextStyle(
                              color: darkPrimaryColor, fontSize: 22.0),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  int index = 2;

  calculateAmountOfShifts(Employee employee) {
    for (Day day in daysWithShiftsForCountThisMonth) {
      if (day.s1.containsValue(employee.initial) && day.month == dateTime.month)
        amountOfShiftsThisMonth++;
      if (day.s2.containsValue(employee.initial) && day.month == dateTime.month)
        amountOfShiftsThisMonth++;
      if (day.s3.containsValue(employee.initial) && day.month == dateTime.month)
        amountOfShiftsThisMonth++;
      if (day.s4.containsValue(employee.initial) && day.month == dateTime.month)
        amountOfShiftsThisMonth++;
      if (day.s5.containsValue(employee.initial) && day.month == dateTime.month)
        amountOfShiftsThisMonth++;
      if (day.s6.containsValue(employee.initial) && day.month == dateTime.month)
        amountOfShiftsThisMonth++;
      if (day.s7.containsValue(employee.initial) && day.month == dateTime.month)
        amountOfShiftsThisMonth++;
      if (day.s8.containsValue(employee.initial) && day.month == dateTime.month)
        amountOfShiftsThisMonth++;
      if (day.s9.containsValue(employee.initial) && day.month == dateTime.month)
        amountOfShiftsThisMonth++;
    }
  }

  calculateAmountOfNightShifts(Employee employee) {
    for (Day day in daysWithShiftsForCountThisMonth) {
      if (day.s1.containsValue(employee.initial) &&
          day.month == dateTime.month &&
          day.s1.containsValue('night')) {
        nightShiftsCountThisMonth++;
        nightShiftHoursCountThisMonth =
            nightShiftHoursCountThisMonth + day.s1['hours'];
      }
      if (day.s2.containsValue(employee.initial) &&
          day.month == dateTime.month &&
          day.s2.containsValue('night')) {
        nightShiftsCountThisMonth++;
        nightShiftHoursCountThisMonth =
            nightShiftHoursCountThisMonth + day.s2['hours'];
      }
      if (day.s3.containsValue(employee.initial) &&
          day.month == dateTime.month &&
          day.s3.containsValue('night')) {
        nightShiftsCountThisMonth++;
        nightShiftHoursCountThisMonth =
            nightShiftHoursCountThisMonth + day.s3['hours'];
      }
      if (day.s4.containsValue(employee.initial) &&
          day.month == dateTime.month &&
          day.s4.containsValue('night')) {
        nightShiftsCountThisMonth++;
        nightShiftHoursCountThisMonth =
            nightShiftHoursCountThisMonth + day.s4['hours'];
      }
      if (day.s5.containsValue(employee.initial) &&
          day.month == dateTime.month &&
          day.s5.containsValue('night')) {
        nightShiftsCountThisMonth++;
        nightShiftHoursCountThisMonth =
            nightShiftHoursCountThisMonth + day.s5['hours'];
      }
      if (day.s6.containsValue(employee.initial) &&
          day.month == dateTime.month &&
          day.s6.containsValue('night')) {
        nightShiftsCountThisMonth++;
        nightShiftHoursCountThisMonth =
            nightShiftHoursCountThisMonth + day.s6['hours'];
      }
      if (day.s7.containsValue(employee.initial) &&
          day.month == dateTime.month &&
          day.s7.containsValue('night')) {
        nightShiftsCountThisMonth++;
        nightShiftHoursCountThisMonth =
            nightShiftHoursCountThisMonth + day.s7['hours'];
      }
      if (day.s8.containsValue(employee.initial) &&
          day.month == dateTime.month &&
          day.s8.containsValue('night')) {
        nightShiftsCountThisMonth++;
        nightShiftHoursCountThisMonth =
            nightShiftHoursCountThisMonth + day.s8['hours'];
      }
      if (day.s9.containsValue(employee.initial) &&
          day.month == dateTime.month &&
          day.s9.containsValue('night')) {
        nightShiftsCountThisMonth++;
        nightShiftHoursCountThisMonth =
            nightShiftHoursCountThisMonth + day.s9['hours'];
      }
    }
  }

  calculateAmountOfMorningShifts(Employee employee) {
    for (Day day in daysWithShiftsForCountThisMonth) {
      if (day.s1.containsValue(employee.initial) &&
          day.month == dateTime.month &&
          day.s1.containsValue('morning')) {
        morningShiftsCountThisMonth++;

        morningShiftHoursCountThisMonth =
            morningShiftHoursCountThisMonth + day.s1['hours'];
      }
      if (day.s2.containsValue(employee.initial) &&
          day.month == dateTime.month &&
          day.s2.containsValue('morning')) {
        morningShiftsCountThisMonth++;

        morningShiftHoursCountThisMonth =
            morningShiftHoursCountThisMonth + day.s2['hours'];
      }
      if (day.s3.containsValue(employee.initial) &&
          day.month == dateTime.month &&
          day.s3.containsValue('morning')) {
        morningShiftsCountThisMonth++;

        morningShiftHoursCountThisMonth =
            morningShiftHoursCountThisMonth + day.s3['hours'];
      }
      if (day.s4.containsValue(employee.initial) &&
          day.month == dateTime.month &&
          day.s4.containsValue('morning')) {
        morningShiftsCountThisMonth++;

        morningShiftHoursCountThisMonth =
            morningShiftHoursCountThisMonth + day.s4['hours'];
      }
      if (day.s5.containsValue(employee.initial) &&
          day.month == dateTime.month &&
          day.s5.containsValue('morning')) {
        morningShiftsCountThisMonth++;

        morningShiftHoursCountThisMonth =
            morningShiftHoursCountThisMonth + day.s5['hours'];
      }
      if (day.s6.containsValue(employee.initial) &&
          day.month == dateTime.month &&
          day.s6.containsValue('morning')) {
        morningShiftsCountThisMonth++;

        morningShiftHoursCountThisMonth =
            morningShiftHoursCountThisMonth + day.s6['hours'];
      }
      if (day.s7.containsValue(employee.initial) &&
          day.month == dateTime.month &&
          day.s7.containsValue('morning')) {
        morningShiftsCountThisMonth++;

        morningShiftHoursCountThisMonth =
            morningShiftHoursCountThisMonth + day.s7['hours'];
      }
      if (day.s8.containsValue(employee.initial) &&
          day.month == dateTime.month &&
          day.s8.containsValue('morning')) {
        morningShiftsCountThisMonth++;

        morningShiftHoursCountThisMonth =
            morningShiftHoursCountThisMonth + day.s8['hours'];
      }
      if (day.s9.containsValue(employee.initial) &&
          day.month == dateTime.month &&
          day.s9.containsValue('morning')) {
        morningShiftsCountThisMonth++;

        morningShiftHoursCountThisMonth =
            morningShiftHoursCountThisMonth + day.s9['hours'];
      }
    }
  }

  calculateAmountOfEveningShifts(Employee employee) {
    for (Day day in daysWithShiftsForCountThisMonth) {
      if (day.s1.containsValue(employee.initial) &&
          day.month == dateTime.month &&
          day.s1.containsValue('evening')) {
        eveningShiftsCountThisMonth++;

        eveningShiftHoursCountThisMonth =
            eveningShiftHoursCountThisMonth + day.s1['hours'];
      }
      if (day.s2.containsValue(employee.initial) &&
          day.month == dateTime.month &&
          day.s2.containsValue('evening')) {
        eveningShiftsCountThisMonth++;

        eveningShiftHoursCountThisMonth =
            eveningShiftHoursCountThisMonth + day.s2['hours'];
      }
      if (day.s3.containsValue(employee.initial) &&
          day.month == dateTime.month &&
          day.s3.containsValue('evening')) {
        eveningShiftsCountThisMonth++;

        eveningShiftHoursCountThisMonth =
            eveningShiftHoursCountThisMonth + day.s3['hours'];
      }
      if (day.s4.containsValue(employee.initial) &&
          day.month == dateTime.month &&
          day.s4.containsValue('evening')) {
        eveningShiftsCountThisMonth++;

        eveningShiftHoursCountThisMonth =
            eveningShiftHoursCountThisMonth + day.s4['hours'];
      }
      if (day.s5.containsValue(employee.initial) &&
          day.month == dateTime.month &&
          day.s5.containsValue('evening')) {
        eveningShiftsCountThisMonth++;

        eveningShiftHoursCountThisMonth =
            eveningShiftHoursCountThisMonth + day.s5['hours'];
      }
      if (day.s6.containsValue(employee.initial) &&
          day.month == dateTime.month &&
          day.s6.containsValue('evening')) {
        eveningShiftsCountThisMonth++;

        eveningShiftHoursCountThisMonth =
            eveningShiftHoursCountThisMonth + day.s6['hours'];
      }
      if (day.s7.containsValue(employee.initial) &&
          day.month == dateTime.month &&
          day.s7.containsValue('evening')) {
        eveningShiftsCountThisMonth++;

        eveningShiftHoursCountThisMonth =
            eveningShiftHoursCountThisMonth + day.s7['hours'];
      }
      if (day.s8.containsValue(employee.initial) &&
          day.month == dateTime.month &&
          day.s8.containsValue('evening')) {
        eveningShiftsCountThisMonth++;

        eveningShiftHoursCountThisMonth =
            eveningShiftHoursCountThisMonth + day.s8['hours'];
      }
      if (day.s9.containsValue(employee.initial) &&
          day.month == dateTime.month &&
          day.s9.containsValue('evening')) {
        eveningShiftsCountThisMonth++;

        eveningShiftHoursCountThisMonth =
            eveningShiftHoursCountThisMonth + day.s9['hours'];
      }
    }
  }

  calculateSalaryThisMonth(Employee employee) {
    if (employee.position == kJuniorSupport) {
      salary =
          ((eveningShiftHoursCountThisMonth + morningShiftHoursCountThisMonth) *
                  kJuniorSupportSalary[0]) +
              (nightShiftHoursCountThisMonth * kJuniorSupportSalary[1]);
    } else if (employee.position == kMiddleSupport) {
      salary =
          ((eveningShiftHoursCountThisMonth + morningShiftHoursCountThisMonth) *
                  kMiddleSupportSalary[0]) +
              (nightShiftHoursCountThisMonth * kMiddleSupportSalary[1]);
    } else if (employee.position == kSeniorSupport) {
      salary =
          ((eveningShiftHoursCountThisMonth + morningShiftHoursCountThisMonth) *
                  kSeniorSupportSalary[0]) +
              (nightShiftHoursCountThisMonth * kSeniorSupportSalary[1]);
    } else if (employee.position == kAMLCertifiedSupport) {
      salary =
          ((eveningShiftHoursCountThisMonth + morningShiftHoursCountThisMonth) *
                  kAMLCertifiedSupportSalary[0]) +
              (nightShiftHoursCountThisMonth * kAMLCertifiedSupportSalary[1]);
    } else if (employee.position == kTeamLeadSupport) {
      salary =
          ((eveningShiftHoursCountThisMonth + morningShiftHoursCountThisMonth) *
                  kTeamLeadSupportSalary[0]) +
              (nightShiftHoursCountThisMonth * kTeamLeadSupportSalary[1]);
    }
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

//      Row(
//        children: <Widget>[
//          Text(
//            name,
//          ),
//          Text('${salary.toStringAsFixed(2)}'),
//          Text('s. $amountOfShifts'),
//          Column(children: <Widget>[
//            Text('n. $amountOfNightShifts'),
//            Text('h. $nightHours'),
//          ]),
//          Column(children: <Widget>[
//            Text('m. $amountOfMorningShifts'),
//            Text('h. $morningHours'),
//          ]),
//          Column(children: <Widget>[
//            Text('e. $amountOfEveningShifts'),
//            Text('h. $eveningHours'),
//          ]),
//        ],
//      ),
    );
  }

  @override
  Widget build1(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(top: 2.0),
        child: DataTable(
          onSelectAll: (b) {},
          columns: <DataColumn>[
            DataColumn(
              label: Text(
                name,
                style: kButtonFontStyle,
                textAlign: TextAlign.center,
              ),
              numeric: false,
              onSort: (i, b) {},
            ),
            DataColumn(
              label: Text(
                '${salary.toStringAsFixed(2)}',
                style: kButtonFontStyle,
                textAlign: TextAlign.center,
              ),
              numeric: true,
              onSort: (i, b) {},
            ),
            DataColumn(
              label: Column(children: <Widget>[
                Text(
                  '$amountOfNightShifts',
                  style: kButtonFontStyle,
                ),
                Text(
                  '($nightHours)',
                  style: kButtonFontStyle,
                ),
              ]),
              numeric: true,
              onSort: (i, b) {},
            ),
            DataColumn(
              label: Column(children: <Widget>[
                Text(
                  '$amountOfMorningShifts',
                  style: kButtonFontStyle,
                ),
                Text(
                  '($morningHours)',
                  style: kButtonFontStyle,
                ),
              ]),
              numeric: true,
              onSort: (i, b) {},
            ),
            DataColumn(
              label: Column(children: <Widget>[
                Text(
                  '$amountOfEveningShifts',
                  style: kButtonFontStyle,
                ),
                Text(
                  '($eveningHours)',
                  style: kButtonFontStyle,
                ),
              ]),
              numeric: true,
              onSort: (i, b) {},
            ),
          ],
          rows: <DataRow>[],
        ),
      ),

//      Row(
//        children: <Widget>[
//          Text(
//            name,
//          ),
//          Text('${salary.toStringAsFixed(2)}'),
//          Text('s. $amountOfShifts'),
//          Column(children: <Widget>[
//            Text('n. $amountOfNightShifts'),
//            Text('h. $nightHours'),
//          ]),
//          Column(children: <Widget>[
//            Text('m. $amountOfMorningShifts'),
//            Text('h. $morningHours'),
//          ]),
//          Column(children: <Widget>[
//            Text('e. $amountOfEveningShifts'),
//            Text('h. $eveningHours'),
//          ]),
//        ],
//      ),
    );
  }
}
