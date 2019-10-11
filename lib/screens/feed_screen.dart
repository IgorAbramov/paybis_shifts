import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:paybis_com_shifts/models/employee.dart';
import 'package:paybis_com_shifts/models/progress.dart';
import 'package:paybis_com_shifts/screens/login_screen.dart';
import 'package:paybis_com_shifts/screens/shifts_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

//TODO show changes from Firebase Changes collections
//TODO show only last 50 changes with the possibility to see more

final feedScaffoldKey = new GlobalKey<ScaffoldState>();

class FeedScreen extends StatefulWidget {
  static const String id = 'feed_screen';
  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: feedScaffoldKey,
      appBar: AppBar(
        title: Text('Requests to review'),
      ),
      body: Container(
        child: StreamBuilder<QuerySnapshot>(
          stream: dbController.createAdminFeedStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return circularProgress();
            }
            final changes = snapshot.data.documents;
            List<FeedItem> feedItems = [];
            changes.forEach((doc) {
              feedItems.add(FeedItem.fromDocument(doc));
            });
            return ListView(children: feedItems);
          },
        ),
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
  final int number1;
  final int number2;
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
      this.number1,
      this.number2,
      this.emp1,
      this.emp2,
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
      number1: doc['number1'],
      number2: doc['number2'],
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
                    text: name1,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: ' $feedItemText ',
                  ),
                  TextSpan(
                    text: name2,
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
              color: Colors.lightBlueAccent.withOpacity(0.05),
              child: ListTile(
                leading: GestureDetector(
                  onTap: () {
                    dbController.changeShiftHolders(
                        docID1, docID2, number1, number2, emp1, emp2);
                    dbController.removeChangeRequestFromAdminFeed(id);
                    dbController.addChangeToRecentChanges(emp1, emp2, date1,
                        date2, shiftType1, shiftType2, 'Swap confirmed', true);
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
                  onTap: () {
                    dbController.removeChangeRequestFromAdminFeed(id);
                    dbController.addChangeToRecentChanges(emp1, emp2, date1,
                        date2, shiftType1, shiftType2, 'Swap cancelled', false);
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.red,
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
