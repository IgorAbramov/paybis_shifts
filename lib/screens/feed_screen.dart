import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:paybis_com_shifts/constants.dart';
import 'package:paybis_com_shifts/models/employee.dart';
import 'package:paybis_com_shifts/screens/login_screen.dart';
import 'package:paybis_com_shifts/screens/shifts_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

//TODO show only last 25 changes with the possibility to see more

final feedScaffoldKey = new GlobalKey<ScaffoldState>();
final feedScreenKey = new GlobalKey<_FeedScreenState>();

class FeedScreen extends StatefulWidget {
  static const String id = 'feed_screen';
  const FeedScreen({Key key}) : super(key: key);
  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  void rebuild() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: feedScaffoldKey,
      appBar: AppBar(
        title: Text('Requests to review'),
      ),
      body: Column(
        children: <Widget>[
          Container(
            child: StreamBuilder<QuerySnapshot>(
              stream: (employee.department == kSupportDepartment)
                  ? dbController.createSupportFeedStream()
                  : dbController.createAdminFeedStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return SizedBox(
                    height: 1.0,
                  );
                }
                final changes = snapshot.data.documents;
                List<FeedItem> feedItems = [];
                changes.forEach((doc) {
                  feedItems.add(FeedItem.fromDocument(doc));
                });
                return SingleChildScrollView(
                    child: Column(children: feedItems));
              },
            ),
          ),
          (employee.department == kSupportDepartment)
              ? Column(
                  children: <Widget>[
                    Divider(
                      color: secondaryColor,
                    ),
                    Center(
                      child: Text(
                        'Your pending Requests',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Divider(
                      color: secondaryColor,
                    ),
                    Container(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: dbController
                            .createEmployeePendingRequestFeedStream(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Container();
                          }
                          final changes = snapshot.data.documents;
                          List<FeedItem> feedItems = [];
                          changes.forEach((doc) {
                            feedItems.add(FeedItem.fromDocument(doc));
                          });
                          return SingleChildScrollView(
                              child: Column(children: feedItems));
                        },
                      ),
                    ),
                  ],
                )
              : SizedBox(
                  height: 1.0,
                ),
        ],
      ),
    );
  }
}

String feedItemText;
String name1;
String name2;
Color color1;
Color color2;

class FeedItem extends StatelessWidget {
  final String type;
  final String docID1;
  final String docID2;
  final String position1;
  final String position2;
  final String emp1;
  final String emp2;
  final String date1;
  final String date2;
  final String shiftType1;
  final String shiftType2;
  final String id;
  final Timestamp timestamp;
  final String message;

  FeedItem(
      {this.type,
      this.docID1,
      this.docID2,
      this.emp1,
      this.emp2,
      this.position1,
      this.position2,
      this.date1,
      this.date2,
      this.shiftType1,
      this.shiftType2,
      this.id,
      this.timestamp,
      this.message});

  factory FeedItem.fromDocument(DocumentSnapshot doc) {
    return FeedItem(
      type: doc['type'],
      docID1: doc['docID1'],
      docID2: doc['docID2'],
      position1: doc['position1'],
      position2: doc['position2'],
      emp1: doc['emp1'],
      emp2: doc['emp2'],
      date1: doc['date1'],
      date2: doc['date2'],
      shiftType1: doc['shiftType1'],
      shiftType2: doc['shiftType2'],
      id: doc.documentID,
      timestamp: doc['timestamp'],
      message: doc['message'],
    );
  }

  configureText() {
    if (type == 'changeRequest') {
      if (employee.initial == emp1) {
        feedItemText = 'want to change with';
      } else
        feedItemText = 'wants to change with';
    } else
      feedItemText = '';
  }

  initialsToName() {
    for (Employee emp in listWithEmployees) {
      if (emp.initial == emp1) {
        name1 = emp.name;
        color1 = convertColor(emp.empColor);
      }
      if (emp.initial == emp2) {
        name2 = emp.name;
        color2 = convertColor(emp.empColor);
      }
    }
  }

//  final GlobalKey<ExpansionTileState> expansionTile = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    configureText();
    initialsToName();

    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0),
      child: Container(
        color: Colors.white54,
        child: ExpansionTile(
          key: GlobalKey(),
          title: RichText(
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                    text: (employee.name == name1) ? 'You' : name1,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: ' $feedItemText ',
                  ),
                  TextSpan(
                    text: (employee.name == name2) ? 'You' : name2,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ]),
          ),
          leading: CircleAvatar(
            backgroundColor: color1,
            child: Text(emp1),
          ),
          trailing: CircleAvatar(
            backgroundColor: color2,
            child: Text(emp2),
          ),
          children: <Widget>[
            Container(
              color: lightPrimaryColor.withOpacity(0.05),
              child: ListTile(
                leading: (employee.department == kSupportDepartment &&
                        employee.initial == emp1)
                    ? SizedBox(
                        height: 1.0,
                      )
                    : GestureDetector(
                        onTap: () async {
                          Shift shift1 =
                              Shift(emp1, 8.0, position1, shiftType1);
                          Shift shift2 =
                              Shift(emp2, 8.0, position2, shiftType2);
                          if (employee.department == kAdmin ||
                              employee.department == kSuperAdmin) {
                            await dbController.changeShiftHolders(
                                docID1,
                                docID2,
                                shiftType1,
                                shiftType2,
                                shift1.buildMap(shift1.holder, shift1.hours,
                                    shift1.position, shift1.type),
                                shift2.buildMap(shift2.holder, shift2.hours,
                                    shift2.position, shift2.type));
                            await dbController.removeChangeRequestFromFeed(id);
                            await dbController.addChangeToRecentChanges(
                                emp1,
                                emp2,
                                date1,
                                date2,
                                shiftType1,
                                shiftType2,
                                'Swap confirmed',
                                true);
                          }
                          if (employee.department == kSupportDepartment &&
                              employee.initial == emp2) {
                            await dbController
                                .setChangeRequestStateToConfirmed(id);
                            for (Employee emp in listWithEmployees) {
                              if (emp.department == kAdmin ||
                                  emp.department == kSuperAdmin) {
                                dbController.addUserFeedItemToNotify(
                                    emp.id,
                                    'Exchange Request',
                                    '$emp1 wants to exchange with $emp2, please review');
                              }
                            }
                          }
                        },
                        child: CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Icon(Icons.check),
                        ),
                      ),
                title: Text(
                  "$message \n $date1 $shiftType1 ($emp1) to $date2 $shiftType2 ($emp2)",
                  style: TextStyle(
                    fontSize: 14.0,
                  ),
                ),
                subtitle: Text(
                  timeago.format(timestamp.toDate()),
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: GestureDetector(
                  onTap: () async {
                    await dbController.removeChangeRequestFromFeed(id);
                    await dbController.addChangeToRecentChanges(
                        emp1,
                        emp2,
                        date1,
                        date2,
                        shiftType1,
                        shiftType2,
                        'Swap cancelled',
                        false);
                  },
                  child: CircleAvatar(
                    backgroundColor: accentColor,
                    child: Icon(Icons.remove_circle),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
