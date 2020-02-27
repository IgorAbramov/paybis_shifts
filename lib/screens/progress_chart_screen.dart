import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:paybis_com_shifts/models/chart_data.dart';
import 'package:paybis_com_shifts/models/employee.dart';
import 'package:paybis_com_shifts/models/progress.dart';
import 'package:paybis_com_shifts/screens/login_screen.dart';
import 'package:paybis_com_shifts/ui_parts/progress_chart.dart';

import '../constants.dart';

List<SupportChartData> chartData = [];
bool _isLoading = true;

class ProgressChartScreen extends StatefulWidget {
  static const String id = 'progress_chart_screen';
  @override
  _ProgressChartScreenState createState() => _ProgressChartScreenState();
}

class _ProgressChartScreenState extends State<ProgressChartScreen> {
  String selectedEmp = listWithEmployees.first.name;

  DropdownButton<String> androidDropdownName() {
    List<DropdownMenuItem<String>> dropdownItems = [];
    for (Employee emp in listWithEmployees) {
      if (emp.department == kSupportDepartment) {
        var newItem = DropdownMenuItem(
          child: Text(emp.name),
          value: emp.name,
        );
        dropdownItems.add(newItem);
      }
    }
    return DropdownButton<String>(
        value: selectedEmp,
        items: dropdownItems,
        onChanged: (value) {
          setState(() {
            selectedEmp = value;
            getAllStatsForOne();
          });
        });
  }

  CupertinoPicker iOSPickerName() {
    List<Text> pickerItems = [];
    for (Employee emp in listWithEmployees) {
      if (emp.department == kSupportDepartment) {
        pickerItems.add(Text(emp.name));
      }
    }

    return CupertinoPicker(
      backgroundColor: Theme.of(context).textSelectionColor,
      itemExtent: 32.0,
      onSelectedItemChanged: (selectedIndex) {
        setState(() {
          selectedEmp = listWithEmployees[selectedIndex].name;
          getAllStatsForOne();
        });
      },
      children: pickerItems,
    );
  }

  Future getAllStatsForOne() async {
    setState(() {
      _isLoading = true;
    });
    chartData.clear();

    await dbController.getProgressDataForOne(chartData, selectedEmp);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    if (employee.department == kSupportDepartment) {
      selectedEmp = employee.name;
    }
    getAllStatsForOne();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColorDark,
        title: FittedBox(child: Text('Monthly progress chart')),
      ),
      body: (!_isLoading)
          //If is not Loading
          ? (chartData != null || chartData.length != 0)
              //If chartData is good to go
              ? (employee.department == kSuperAdmin ||
                      employee.department == kAdmin)
                  // If User is Admin
                  ? Column(
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: Container(
                            height: 120.0,
                            alignment: Alignment.center,
                            padding: EdgeInsets.only(bottom: 30.0),
                            color: Theme.of(context).textSelectionColor,
                            child: androidDropdownName(),
                          ),
                        ),
                        Expanded(
                          flex: 7,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: ProgressChart.withData(chartData),
                          ),
                        )
                      ],
                    )
                  //If User is not Admin
                  : Padding(
                      padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                      child: ProgressChart.withData(chartData),
                    )
              //If chartData is not Good to go
              : Center(
                  child: Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Text('No data yet :)'),
                ))
          // IF is Loading
          : circularProgress(),
    );
  }
}
