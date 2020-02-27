import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:paybis_com_shifts/constants.dart';
import 'package:paybis_com_shifts/models/chart_data.dart';
import 'package:paybis_com_shifts/models/employee.dart';
import 'package:paybis_com_shifts/models/progress.dart';
import 'package:paybis_com_shifts/screens/login_screen.dart';
import 'package:paybis_com_shifts/screens/shifts_screen.dart';
import 'package:paybis_com_shifts/ui_parts/rounded_button.dart';
import 'package:paybis_com_shifts/ui_parts/stacked_bar_chart.dart';

bool _editMode = false;
List<SupportChartData> _inputChartDataList = [];
List<SupportChartData> chartData = [];
bool _isLoading = true;

class BonusStatsChartScreen extends StatefulWidget {
  static const String id = 'bonus_stats_chart_screen';
  @override
  _BonusStatsChartScreenState createState() => _BonusStatsChartScreenState();
}

class _BonusStatsChartScreenState extends State<BonusStatsChartScreen> {
  @override
  void initState() {
    _editMode = false;
    super.initState();
    getMonthlyStats();
  }

  Future getMonthlyStats() async {
    setState(() {
      _isLoading = true;
    });
    chartData.clear();
    await dbController.getMonthlyStatsDataForAll(
        chartData, dateTime.year, dateTime.month);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColorDark,
        title: FittedBox(
            fit: BoxFit.fill,
            child: Text(
              'Stats for ${getMonthName(dateTime.month)}',
            )),
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.chevron_left,
                color: Theme.of(context).textSelectionColor,
              ),
              onPressed: () {
                setState(() {
                  _editMode = false;
                  previousMonthSelected();
                  getMonthlyStats();
                });
              }),
          IconButton(
              icon: Icon(
                Icons.chevron_right,
                color: Theme.of(context).textSelectionColor,
              ),
              onPressed: () {
                setState(() {
                  _editMode = false;
                  nextMonthSelected();
                  getMonthlyStats();
                });
              }),
        ],
      ),
      body: (!_isLoading)
          ? (!_editMode)
              ? (chartData == null || chartData.length == 0)
                  ? (employee.department == kSuperAdmin)
                      ? Center(
                          child: RoundedButton(
                            color: Theme.of(context).primaryColorDark,
                            title: 'Input bonus stats',
                            onPressed: () {
                              setState(() {
                                _editMode = true;
                              });
                            },
                          ),
                        )
                      : Center(
                          child: Padding(
                          padding: const EdgeInsets.all(28.0),
                          child: Text('No data yet :)'),
                        ))
                  : Padding(
                      padding: const EdgeInsets.only(
                          top: 10.0, bottom: 20.0, left: 10.0, right: 5.0),
                      child: StackedBarChart.withData(chartData),
                    )
              : Column(
                  children: <Widget>[
                    Table(
                      border: TableBorder.all(
                        color: secondaryColor,
                      ),
                      columnWidths: {
                        0: FlexColumnWidth(1),
                        1: FlexColumnWidth(.8),
                        2: FlexColumnWidth(.8),
                        3: FlexColumnWidth(.8),
                      },
                      children: [
                        TableRow(
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColorDark,
                          ),
                          children: [
                            TableCell(
                              child: Text(
                                'Name',
                                style: kButtonStyle,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            TableCell(
                              child: Text(
                                kTransactions,
                                style: kButtonStyle,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            TableCell(
                              child: Text(
                                kVerifications,
                                style: kButtonStyle,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            TableCell(
                              child: Text(
                                kChats,
                                style: kButtonStyle,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    Expanded(
                      child: ListView(
                        children: inputBonusStats(context),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 16.0, right: 4.0, top: 8.0, bottom: 8.0),
                            child: Material(
                              elevation: 5.0,
                              color: Theme.of(context).primaryColorDark,
                              borderRadius: BorderRadius.circular(15.0),
                              child: MaterialButton(
                                onPressed: () {
                                  openUpdateStatsConfirmationAlertBox(context);
                                },
                                child: Text(
                                  'Submit data',
                                  style: kButtonStyle,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
          : circularProgress(),
    );
  }
}

List<Widget> inputBonusStats(BuildContext context) {
  List<Widget> list = [];
  int i = 0;
  _inputChartDataList.clear();
  for (Employee emp in listWithEmployees) {
    if (emp.department == kSupportDepartment) {
      _inputChartDataList.add(SupportChartData(
        year: dateTime.year,
        month: dateTime.month,
        name: emp.name,
        initial: emp.initial,
        transactions: 0,
        verifications: 0,
        chats: 0,
      ));
      int transactions = 0;
      int verifications = 0;
      int chats = 0;
      list.add(
        Row(
          children: <Widget>[
            Expanded(
              flex: 10,
              child: Container(
                height: 20.0,
                child: Center(
                  child: Text(
                    emp.name,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 8,
              child: TextField(
                maxLength: 3,
                keyboardType: TextInputType.number,
                decoration: kStatsTextFieldDecoration.copyWith(
                  hintText: '',
                ),
                onChanged: (value) {
                  _inputChartDataList
                      .where((element) => element.name == emp.name)
                      .first
                      .transactions = int.parse(value);
                },
              ),
            ),
            Expanded(
              flex: 8,
              child: TextField(
                maxLength: 3,
                keyboardType: TextInputType.number,
                decoration: kStatsTextFieldDecoration.copyWith(
                  hintText: '',
                ),
                onChanged: (value) {
                  _inputChartDataList
                      .where((element) => element.name == emp.name)
                      .first
                      .verifications = int.parse(value);
                },
              ),
            ),
            Expanded(
              flex: 8,
              child: TextField(
                maxLength: 3,
                keyboardType: TextInputType.number,
                decoration: kStatsTextFieldDecoration.copyWith(
                  hintText: '',
                ),
                onChanged: (value) {
                  _inputChartDataList
                      .where((element) => element.name == emp.name)
                      .first
                      .chats = int.parse(value);
                },
              ),
            ),
          ],
        ),
      );
      i++;
    }
  }
  return list;
}

openUpdateStatsConfirmationAlertBox(BuildContext context) {
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Center(
                    child: Text(
                      'Are you sure?',
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(64),
                      ),
                    ),
                  ),
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
                        onTap: () async {
                          Navigator.pop(context);
                          Navigator.pop(context);
                          _editMode = false;
                          await dbController
                              .addMonthlyStatsData(_inputChartDataList);
                          await dbController.updateLeaderBoard();
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
                          Navigator.pop(context);
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
