import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:paybis_com_shifts/constants.dart';
import 'package:paybis_com_shifts/models/progress.dart';
import 'package:paybis_com_shifts/screens/login_screen.dart';

class RecentChangesScreen extends StatefulWidget {
  static const String id = 'recent_changes_screen';

  @override
  _RecentChangesScreenState createState() => _RecentChangesScreenState();
}

class _RecentChangesScreenState extends State<RecentChangesScreen> {
  int numberToList = 25;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recent Changes'),
      ),
      body: Container(
        child: StreamBuilder<QuerySnapshot>(
          stream: (employee.department == kAdmin)
              ? dbController.createRecentChangesStream(numberToList, '', false)
              : dbController.createRecentChangesStream(
                  numberToList, employee.initial, true),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return circularProgress();
            }
            final changes = snapshot.data.documents;
            List<Change> changesList = [];
            changes.forEach((doc) {
              changesList.add(Change.fromDocument(doc));
            });
            return ListView(children: changesList);
          },
        ),
      ),
    );
  }
}

class Change extends StatelessWidget {
  final String text;
  final Timestamp timestamp;
  final bool confirmed;

  Change({
    this.text,
    this.timestamp,
    this.confirmed,
  });

  factory Change.fromDocument(DocumentSnapshot doc) {
    return Change(
      text: doc['text'],
      timestamp: doc['timestamp'],
      confirmed: doc['confirmed'],
    );
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white54,
      child: ListTile(
        title: Text(
          text,
          style: TextStyle(color: confirmed ? Colors.green : accentColor),
        ),
        subtitle: Text(timestamp.toDate().toString()),
      ),
    );
  }
}
