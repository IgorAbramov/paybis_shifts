import 'package:flutter/material.dart';
import 'package:paybis_com_shifts/constants.dart';

import 'login_screen.dart';
import 'shifts_screen.dart';

class PersonalPanelScreen extends StatefulWidget {
  static const String id = 'personal_panel_screen';
  @override
  _PersonalPanelScreenState createState() => _PersonalPanelScreenState();
}

class _PersonalPanelScreenState extends State<PersonalPanelScreen> {
  int amountOfShiftsThisMonth = 0;
//  int amountOfShiftsLastMonth = 0;
  int nightShiftsCountThisMonth = 0;
  int morningShiftsCountThisMonth = 0;
  int eveningShiftsCountThisMonth = 0;
  double nightShiftHoursCountThisMonth = 0;
  double morningShiftHoursCountThisMonth = 0;
  double eveningShiftHoursCountThisMonth = 0;
  double salary = 0;

  void getAllPersonalData() {
    amountOfShiftsThisMonth = 0;
    nightShiftsCountThisMonth = 0;
    morningShiftsCountThisMonth = 0;
    eveningShiftsCountThisMonth = 0;
    salary = 0;

    print(daysWithShiftsForCountThisMonth.length);

    calculateAmountOfShifts();
    calculateAmountOfNightShifts();
    calculateAmountOfMorningShifts();
    calculateAmountOfEveningShifts();
    calculateSalaryThisMonth();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    getAllPersonalData();
    return Scaffold(
      appBar: AppBar(
        title: Text('Hi ${employee.name}! Stats for $selectedMonth.19'),
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
                    style: TextStyle(color: Colors.blue, fontSize: 22.0),
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
            RichText(
              text: TextSpan(
                text: 'Salary: ',
                style: kPersonalPageDataTextStyle,
                children: <TextSpan>[
                  TextSpan(
                    text: ' ${salary.toStringAsFixed(2)}',
                    style: TextStyle(color: Colors.blue, fontSize: 22.0),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  calculateAmountOfShifts() {
    for (Day day in daysWithShiftsForCountThisMonth) {
      if (day.s1.containsValue(employee.initial) && day.month == selectedMonth)
        amountOfShiftsThisMonth++;
      if (day.s2.containsValue(employee.initial) && day.month == selectedMonth)
        amountOfShiftsThisMonth++;
      if (day.s3.containsValue(employee.initial) && day.month == selectedMonth)
        amountOfShiftsThisMonth++;
      if (day.s4.containsValue(employee.initial) && day.month == selectedMonth)
        amountOfShiftsThisMonth++;
      if (day.s5.containsValue(employee.initial) && day.month == selectedMonth)
        amountOfShiftsThisMonth++;
      if (day.s6.containsValue(employee.initial) && day.month == selectedMonth)
        amountOfShiftsThisMonth++;
      if (day.s7.containsValue(employee.initial) && day.month == selectedMonth)
        amountOfShiftsThisMonth++;
      if (day.s8.containsValue(employee.initial) && day.month == selectedMonth)
        amountOfShiftsThisMonth++;
      if (day.s9.containsValue(employee.initial) && day.month == selectedMonth)
        amountOfShiftsThisMonth++;
    }
  }

  calculateAmountOfNightShifts() {
    for (Day day in daysWithShiftsForCountThisMonth) {
      if (day.s1.containsValue(employee.initial) &&
          day.month == selectedMonth &&
          day.s1.containsValue('night')) nightShiftsCountThisMonth++;
      if (day.s2.containsValue(employee.initial) &&
          day.month == selectedMonth &&
          day.s2.containsValue('night')) nightShiftsCountThisMonth++;
      if (day.s3.containsValue(employee.initial) &&
          day.month == selectedMonth &&
          day.s3.containsValue('night')) nightShiftsCountThisMonth++;
      if (day.s4.containsValue(employee.initial) &&
          day.month == selectedMonth &&
          day.s4.containsValue('night')) nightShiftsCountThisMonth++;
      if (day.s5.containsValue(employee.initial) &&
          day.month == selectedMonth &&
          day.s5.containsValue('night')) nightShiftsCountThisMonth++;
      if (day.s6.containsValue(employee.initial) &&
          day.month == selectedMonth &&
          day.s6.containsValue('night')) nightShiftsCountThisMonth++;
      if (day.s7.containsValue(employee.initial) &&
          day.month == selectedMonth &&
          day.s7.containsValue('night')) nightShiftsCountThisMonth++;
      if (day.s8.containsValue(employee.initial) &&
          day.month == selectedMonth &&
          day.s8.containsValue('night')) nightShiftsCountThisMonth++;
      if (day.s9.containsValue(employee.initial) &&
          day.month == selectedMonth &&
          day.s9.containsValue('night')) nightShiftsCountThisMonth++;
    }
  }

  calculateAmountOfMorningShifts() {
    for (Day day in daysWithShiftsForCountThisMonth) {
      if (day.s1.containsValue(employee.initial) &&
          day.month == selectedMonth &&
          day.s1.containsValue('morning')) morningShiftsCountThisMonth++;
      if (day.s2.containsValue(employee.initial) &&
          day.month == selectedMonth &&
          day.s2.containsValue('morning')) morningShiftsCountThisMonth++;
      if (day.s3.containsValue(employee.initial) &&
          day.month == selectedMonth &&
          day.s3.containsValue('morning')) morningShiftsCountThisMonth++;
      if (day.s4.containsValue(employee.initial) &&
          day.month == selectedMonth &&
          day.s4.containsValue('morning')) morningShiftsCountThisMonth++;
      if (day.s5.containsValue(employee.initial) &&
          day.month == selectedMonth &&
          day.s5.containsValue('morning')) morningShiftsCountThisMonth++;
      if (day.s6.containsValue(employee.initial) &&
          day.month == selectedMonth &&
          day.s6.containsValue('morning')) morningShiftsCountThisMonth++;
      if (day.s7.containsValue(employee.initial) &&
          day.month == selectedMonth &&
          day.s7.containsValue('morning')) morningShiftsCountThisMonth++;
      if (day.s8.containsValue(employee.initial) &&
          day.month == selectedMonth &&
          day.s8.containsValue('morning')) morningShiftsCountThisMonth++;
      if (day.s9.containsValue(employee.initial) &&
          day.month == selectedMonth &&
          day.s9.containsValue('morning')) morningShiftsCountThisMonth++;
    }
  }

  calculateAmountOfEveningShifts() {
    for (Day day in daysWithShiftsForCountThisMonth) {
      if (day.s1.containsValue(employee.initial) &&
          day.month == selectedMonth &&
          day.s1.containsValue('evening')) eveningShiftsCountThisMonth++;
      if (day.s2.containsValue(employee.initial) &&
          day.month == selectedMonth &&
          day.s2.containsValue('evening')) eveningShiftsCountThisMonth++;
      if (day.s3.containsValue(employee.initial) &&
          day.month == selectedMonth &&
          day.s3.containsValue('evening')) eveningShiftsCountThisMonth++;
      if (day.s4.containsValue(employee.initial) &&
          day.month == selectedMonth &&
          day.s4.containsValue('evening')) eveningShiftsCountThisMonth++;
      if (day.s5.containsValue(employee.initial) &&
          day.month == selectedMonth &&
          day.s5.containsValue('evening')) eveningShiftsCountThisMonth++;
      if (day.s6.containsValue(employee.initial) &&
          day.month == selectedMonth &&
          day.s6.containsValue('evening')) eveningShiftsCountThisMonth++;
      if (day.s7.containsValue(employee.initial) &&
          day.month == selectedMonth &&
          day.s7.containsValue('evening')) eveningShiftsCountThisMonth++;
      if (day.s8.containsValue(employee.initial) &&
          day.month == selectedMonth &&
          day.s8.containsValue('evening')) eveningShiftsCountThisMonth++;
      if (day.s9.containsValue(employee.initial) &&
          day.month == selectedMonth &&
          day.s9.containsValue('evening')) eveningShiftsCountThisMonth++;
    }
  }

  calculateAmountOfHoursEveningShifts() {}

  calculateSalaryThisMonth() {
    if (employee.position == kJuniorSupport) {
      salary = ((eveningShiftsCountThisMonth + morningShiftsCountThisMonth) *
              8 *
              kJuniorSupportSalary[0]) +
          (nightShiftsCountThisMonth * 8 * kJuniorSupportSalary[1]);
    } else if (employee.position == kMiddleSupport) {
      salary = ((eveningShiftsCountThisMonth + morningShiftsCountThisMonth) *
              8 *
              kMiddleSupportSalary[0]) +
          (nightShiftsCountThisMonth * 8 * kMiddleSupportSalary[1]);
    } else if (employee.position == kSeniorSupport) {
      salary = ((eveningShiftsCountThisMonth + morningShiftsCountThisMonth) *
              8 *
              kSeniorSupportSalary[0]) +
          (nightShiftsCountThisMonth * 8 * kSeniorSupportSalary[1]);
    } else if (employee.position == kAMLCertifiedSupport) {
      salary = ((eveningShiftsCountThisMonth + morningShiftsCountThisMonth) *
              8 *
              kAMLCertifiedSupportSalary[0]) +
          (nightShiftsCountThisMonth * 8 * kAMLCertifiedSupportSalary[1]);
    } else if (employee.position == kTeamLeadSupport) {
      salary = ((eveningShiftsCountThisMonth + morningShiftsCountThisMonth) *
              8 *
              kTeamLeadSupportSalary[0]) +
          (nightShiftsCountThisMonth * 8 * kTeamLeadSupportSalary[1]);
    }
  }
}
