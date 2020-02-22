import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:paybis_com_shifts/models/leader_board_data.dart';
import 'package:paybis_com_shifts/screens/login_screen.dart';

bool _isLoading = true;
List<LeaderBoardData> listWithLeaderBoardData = [];
int forHowManyMonths = 3;
final List<int> options = [3, 6, 12];

class LeaderBoardScreen extends StatefulWidget {
  static const String id = 'leader_board_screen';

  @override
  _LeaderBoardScreenState createState() => _LeaderBoardScreenState();
}

class _LeaderBoardScreenState extends State<LeaderBoardScreen> {
  DropdownButton<int> androidDropdownMonths() {
    List<DropdownMenuItem<int>> dropdownItems = [];
    for (int option in options) {
      var newItem = DropdownMenuItem(
        child: Text('$option'),
        value: option,
      );
      dropdownItems.add(newItem);
    }
    return DropdownButton<int>(
        value: forHowManyMonths,
        items: dropdownItems,
        onChanged: (value) {
          setState(() {
            forHowManyMonths = value;
            getAllLeaders();
          });
        });
  }

  CupertinoPicker iOSPickerMonths() {
    List<Text> pickerItems = [];
    for (int option in options) {
      pickerItems.add(Text('$option'));
    }

    return CupertinoPicker(
      backgroundColor: Theme.of(context).textSelectionColor,
      itemExtent: 32.0,
      onSelectedItemChanged: (selectedIndex) {
        setState(() {
          forHowManyMonths = options[selectedIndex];
          getAllLeaders();
        });
      },
      children: pickerItems,
    );
  }

  Future getAllLeaders() async {
    setState(() {
      _isLoading = true;
    });
    listWithLeaderBoardData.clear();

    await dbController.getLeaderBoardStatsData(
        listWithLeaderBoardData, forHowManyMonths);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getAllLeaders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColorDark,
        title: FittedBox(
            child:
                Text('Top performers for the last $forHowManyMonths months')),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
              flex: 1,
              child:
                  Platform.isIOS ? iOSPickerMonths() : androidDropdownMonths()),
          Expanded(
            flex: 8,
            child: ListView(
              children: listLeadersWidgets(context),
            ),
          ),
        ],
      ),
    );
  }
}

List<Widget> listLeadersWidgets(BuildContext context) {
  List<Widget> list = List();
  int i = 0;
  for (LeaderBoardData leader in listWithLeaderBoardData) {
    i++;
    list.add(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
        child: Container(
          width: double.infinity,
          height: 30.0,
          decoration: BoxDecoration(
            color: (listWithLeaderBoardData.indexOf(leader) > 2)
                ? (listWithLeaderBoardData.indexOf(leader) >=
                        (listWithLeaderBoardData.length - 3))
                    ? Theme.of(context).accentColor
                    : Theme.of(context).primaryColorDark
                : Colors.green,
          ),
          child: Center(
            child: Text(
              (forHowManyMonths != 3)
                  ? (forHowManyMonths != 6)
                      ? '$i. ${leader.name} - ${leader.for12months}'
                      : '$i. ${leader.name} - ${leader.for6months}'
                  : '$i. ${leader.name} - ${leader.for3months}',
              style: TextStyle(
                fontSize: 17.0,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textSelectionColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
  return list;
}
