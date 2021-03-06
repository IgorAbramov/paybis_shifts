import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:paybis_com_shifts/constants.dart';
import 'package:paybis_com_shifts/models/employee.dart';
import 'package:paybis_com_shifts/models/progress.dart';

import 'login_screen.dart';
import 'shifts_screen.dart';

String _markerInitials = '';
String _markerInfo = '';
ScrollController _scrollController;

class ItDaysOffScreen extends StatefulWidget {
  static const String id = 'it_days_off_screen';

  @override
  _ItDaysOffScreenState createState() => _ItDaysOffScreenState();
}

class _ItDaysOffScreenState extends State<ItDaysOffScreen> {
  final GlobalKey<ScaffoldState> itDaysOffScaffoldKey =
      GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Future.delayed(Duration(milliseconds: 50), () {
        if (dateTime.month == DateTime.now().month) {
          if (_scrollController.hasClients) {
            if (DateTime.now().day > 7) {
              _scrollController.animateTo((DateTime.now().day * 40).toDouble(),
                  duration: Duration(milliseconds: 300), curve: Curves.easeOut);
            }
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: itDaysOffScaffoldKey,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColorDark,
        title: Text('IT Days off'),
        actions: <Widget>[
          (employee.department == kAdmin || employee.department == kSuperAdmin)
              ? (_markerInitials == '' || _markerInitials == 'none')
                  ? IconButton(
                      icon: Icon(
                        Icons.edit,
                        color: Theme.of(context).textSelectionColor,
                      ),
                      onPressed: () {
                        showAdminMarkerAlertDialogITDaysOff(context);
                      },
                    )
                  : Material(
                      elevation: 5.0,
                      color: Theme.of(context).indicatorColor,
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
                            color: Theme.of(context).textSelectionColor,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    )
              : SizedBox(
                  height: 1.0,
                ),
        ],
      ),
//      floatingActionButton: InfoFloatingActionButton(),
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
                  decoration:
                      BoxDecoration(color: Theme.of(context).primaryColorDark),
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
                        'Vacations',
                        style: kHeaderFontStyle,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    TableCell(
                      child: Text(
                        'Sick leaves',
                        style: kHeaderFontStyle,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            ITDaysOffStream(year: dateTime.year, month: dateTime.month),
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
                        child: Text(
                          getMonthName(dateTime.month),
                          style: kButtonStyle,
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
      ),
    );
  }

  showAdminMarkerAlertDialogITDaysOff(
    BuildContext context,
  ) {
    bool unpaid = false;
    String info = '';
    final result = showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0))),
            content: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Center(
                    child: Text(
                      'Choose employee',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18.0),
                    ),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Wrap(
                    alignment: WrapAlignment.spaceEvenly,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: listMyITWidgets(context),
                  ),
                  Container(
                    width: 150.0,
                    child: CheckboxListTile(
                      title: Text('Unpaid'),
                      value: unpaid,
                      checkColor: Theme.of(context).textSelectionColor,
                      onChanged: (value) {
                        setState(() {
                          unpaid = value;
                          (unpaid) ? info = ' -' : info = '';
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        });
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
            _markerInfo = '';
          });
        } else
          setState(() {
            _markerInitials = choiceOfEmployee;
            _markerInfo = info;
          });
      }
    });
  }
}

class ITDaysOffStream extends StatelessWidget {
  final int month;
  final int year;

  ITDaysOffStream({@required this.year, @required this.month});

  @override
  Widget build(BuildContext context) {
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
          final bool dayIsHoliday = day.data['isHoliday'];
          final List nightShifts = day.data['night'];
          final List morningShifts = day.data['morning'];
          final List eveningShifts = day.data['evening'];
          currentDocument = day;
          final String dayDocumentID = day.documentID;

          List vacations = day.data['ITVacations'];
          List sickLeaves = day.data['ITSick'];

          final dayWithShifts = Day(dayDay, dayMonth, dayYear, dayIsHoliday,
              nightShifts, morningShifts, eveningShifts);

          final dayWithShiftsUI = Table(
            border: TableBorder.all(
              color: Theme.of(context).indicatorColor,
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
                      ? Theme.of(context).primaryColor.withOpacity(0.4)
                      : Theme.of(context).textSelectionColor,
                ),
                children: [
                  DateTableCellDaysOffIt(
                    day: dayWithShifts.day,
                    month: dayWithShifts.month,
                    year: dayWithShifts.year,
                  ),
                  TableCell(
                    child: Container(
                      color: Colors.green.withOpacity(0.3),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: listVacations(
                            dayWithShifts.day,
                            dayWithShifts.month,
                            dayWithShifts.year,
                            vacations,
                            dayDocumentID),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: listSickLeaves(
                          dayWithShifts.day,
                          dayWithShifts.month,
                          dayWithShifts.year,
                          sickLeaves,
                          dayDocumentID),
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
            controller: _scrollController,
            children: daysWithShifts,
          ),
        );
      },
    );
  }

  listVacations(
      int day, int month, int year, List vacations, String documentID) {
    List<ITDayOffRoundButton> list = [];
    if (vacations != null) {
      if (vacations.length > 0 || vacations.isEmpty) {
        for (int i = 0; i < vacations.length; i++) {
          String vacationsConverted = vacations[i];
          List<String> splitted = vacationsConverted.split(' ');
          list.add(ITDayOffRoundButton(
            day: day,
            month: month,
            year: year,
            text: splitted[0],
            unpaid: (splitted.length == 2) ? splitted[1] : '',
            documentID: documentID,
            number: i,
            type: 'vacation',
          ));
        }
        if (list.length < 3)
          list.add(ITDayOffRoundButton(
            day: day,
            month: month,
            year: year,
            text: '',
            documentID: documentID,
            unpaid: '',
            number: 0,
            type: 'vacation',
          ));
        return list;
      }
    } else
      list.add(ITDayOffRoundButton(
        day: day,
        month: month,
        year: year,
        text: '',
        documentID: documentID,
        unpaid: '',
        number: 0,
        type: 'vacation',
      ));
    return list;
  }

  listSickLeaves(
      int day, int month, int year, List sickLeaves, String documentID) {
    List<ITDayOffRoundButton> list = [];
    if (sickLeaves != null) {
      if (sickLeaves.length >= 0) {
        for (int i = 0; i < sickLeaves.length; i++) {
          String sickLeavesConverted = sickLeaves[i];
          List<String> splitted = sickLeavesConverted.split(' ');
          list.add(ITDayOffRoundButton(
            day: day,
            month: month,
            year: year,
            text: splitted[0],
            documentID: documentID,
            unpaid: (splitted.length == 2) ? splitted[1] : '',
            number: i,
            type: 'sickLeave',
          ));
        }
        if (list.length < 6)
          list.add(ITDayOffRoundButton(
            day: day,
            month: month,
            year: year,
            text: '',
            documentID: documentID,
            unpaid: '',
            number: 0,
            type: 'sickLeave',
          ));
        return list;
      }
    } else
      list.add(ITDayOffRoundButton(
        day: day,
        month: month,
        year: year,
        text: '',
        documentID: documentID,
        unpaid: '',
        number: 0,
        type: 'sickLeave',
      ));
    return list;
  }
}

class ITDayOffRoundButton extends StatefulWidget {
  final int day;
  final int month;
  final int year;
  final String text;
  final String documentID;
  final int number;
  final String type;
  final String unpaid;

  ITDayOffRoundButton({
    @required this.day,
    @required this.month,
    @required this.year,
    @required this.text,
    @required this.documentID,
    @required this.number,
    @required this.type,
    this.unpaid,
  }) : super();

  @override
  _DayOffRoundButtonState createState() => _DayOffRoundButtonState();
}

class _DayOffRoundButtonState extends State<ITDayOffRoundButton> {
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
    Color color = Theme.of(context).primaryColor;

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
        color = convertColor(emp.empColor);
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

                ? Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).textSelectionColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color:
                              Theme.of(context).indicatorColor.withOpacity(0.1),
                          spreadRadius: 1.0,
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () {
                        setState(() async {
                          if (_markerInitials == '') {
                            showAdminAlertDialogDaysOff(
                                context, documentID, widget.type, widget.text);
                          } else if (_markerInitials == 'none') {
                          } else {
                            if (widget.type == 'vacation') {
                              await dbController.addITVacation(
                                  documentID, '$_markerInitials$_markerInfo');
                            }

                            if (widget.type == 'sickLeave') {
                              await dbController.addITSickLeave(
                                  documentID, '$_markerInitials$_markerInfo');
                            }
                          }
                        });
                      },
                      color: Theme.of(context).indicatorColor,
                      icon: Icon(Icons.add),
                      padding: EdgeInsets.all(0.0),
                    ),
                  )

                //If Emp is chosen

                : Tooltip(
                    message: (widget.unpaid == '')
                        ? '${getEmployeeName(widget.text)}\nPaid'
                        : '${getEmployeeName(widget.text)}\nUnpaid',
                    child: MaterialButton(
                      onPressed: () {
                        setState(() async {
                          if (_markerInitials == '' ||
                              _markerInitials == 'none') {
                            if (widget.type == 'vacation') {
                              if (widget.unpaid == '') {
                                dbController.removeITVacation(
                                    documentID, '${widget.text}');
                              } else
                                dbController.removeITVacation(documentID,
                                    '${widget.text} ${widget.unpaid}');
                            }
                            if (widget.type == 'sickLeave') {
                              if (widget.unpaid == '') {
                                dbController.removeITSickLeave(
                                    documentID, '${widget.text}');
                              } else
                                dbController.removeITSickLeave(documentID,
                                    '${widget.text} ${widget.unpaid}');
                            }
                          } else {
                            if (widget.text == _markerInitials) {
                            } else {
                              if (widget.type == 'vacation') {
                                await dbController.addITVacation(
                                    documentID, '$_markerInitials$_markerInfo');
                              }

                              if (widget.type == 'sickLeave') {
                                await dbController.addITSickLeave(
                                    documentID, '$_markerInitials$_markerInfo');
                              }
                            }
                          }
                        });
                      },
                      color: color,
                      shape: CircleBorder(),
                      child: Text(
                        widget.text,
                        style: TextStyle(
                          fontSize: isLong ? 13.0 : 16.0,
                          color: (widget.unpaid == '')
                              ? Theme.of(context).textSelectionColor
                              : Theme.of(context).accentColor,
                        ),
                      ),
                      padding: EdgeInsets.all(0.0),
                      minWidth: 10.0,
                    ),
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

                    color: Theme.of(context).primaryColor,
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

                //If Emp is chosen
                : Tooltip(
                    message: (widget.unpaid == '')
                        ? '${getEmployeeName(widget.text)}\nPaid'
                        : '${getEmployeeName(widget.text)}\nUnpaid',
                    child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 1.8),
                        child: Material(
                            color: (employee != null)
                                ? (widget.text == employee.initial)
                                    ? Theme.of(context).indicatorColor
                                    : color.withOpacity(0)
                                : color.withOpacity(0),
                            borderRadius: BorderRadius.circular(15.0),
                            child: MaterialButton(
                              onPressed: () {},
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
                                child: Text(
                                  widget.text,
                                  style: TextStyle(
                                    fontSize: isLong ? 13.0 : 16.0,
                                    color: (widget.unpaid == '')
                                        ? Theme.of(context).textSelectionColor
                                        : Theme.of(context).accentColor,
                                  ),
                                ),
                              ),
                              padding: EdgeInsets.all(0.0),
                              minWidth: 10.0,
                            ))),
                  ));
  }
}

class DateTableCellDaysOffIt extends StatelessWidget {
  final int day;
  final int month;
  final int year;

  DateTableCellDaysOffIt(
      {@required this.day, @required this.month, @required this.year});

  @override
  Widget build(BuildContext context) {
    int weekDay = weekdayCheck(day, month, year);
    bool isWeekend = false;

    if (weekDay == 6 || weekDay == 7) isWeekend = true;
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            '$day.',
            style: TextStyle(
              fontSize: 11.0,
              fontWeight: FontWeight.bold,
              color: isWeekend
                  ? Theme.of(context).accentColor
                  : Theme.of(context).indicatorColor,
            ),
          ),
          Text(
            '$month',
            style: TextStyle(
              fontSize: 11.0,
              fontWeight: FontWeight.bold,
              color: isWeekend
                  ? Theme.of(context).accentColor
                  : Theme.of(context).indicatorColor,
            ),
          ),
        ],
      ),
    );
  }
}

showAdminAlertDialogDaysOff(
  BuildContext context,
  String docID,
  String type,
  String title,
) {
  bool unpaid = false;
  String info = '';
  final result = showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
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
                  children: listMyITWidgets(context),
                ),
                Container(
                  width: 150.0,
                  child: CheckboxListTile(
                    title: Text('Unpaid'),
                    value: unpaid,
                    checkColor: Theme.of(context).textSelectionColor,
                    onChanged: (value) {
                      setState(() {
                        unpaid = value;
                        (unpaid) ? info = ' -' : info = '';
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      });
    },
  );
  result.then((result) async {
    if (result == null || result == '') {
      result = '+';
    } else {
      String choiceOfEmployee = result.toString();

      if (type == 'vacation') {
        if (choiceOfEmployee == 'none') {
          await dbController.removeITVacation(docID, title);
        } else
          await dbController.addITVacation(docID, '$choiceOfEmployee$info');
      }
      if (type == 'sickLeave') {
        if (choiceOfEmployee == 'none') {
          await dbController.removeITSickLeave(docID, title);
        } else
          await dbController.addITSickLeave(docID, '$choiceOfEmployee$info');
      }
    }
  });
}

List<Widget> listMyITWidgets(BuildContext context) {
  List<Widget> list = List();
  for (Employee emp in listWithEmployees) {
    if (emp.department == kITDepartment) {
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
                fontSize: (emp.name.length <= 7)
                    ? ScreenUtil().setSp(40)
                    : ScreenUtil().setSp(34),
                color: Theme.of(context).textSelectionColor,
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
