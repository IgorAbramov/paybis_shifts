import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:paybis_com_shifts/models/event_model.dart';
import 'package:paybis_com_shifts/screens/event_creator_screen.dart';

class EventsView extends StatefulWidget {
  final DateTime _eventDate;

  EventsView(DateTime date) : _eventDate = date;

  @override
  State<StatefulWidget> createState() {
    return EventsViewState(_eventDate);
  }
}

class EventsViewState extends State<EventsView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DateTime _eventDate;

  EventsViewState(DateTime date) : _eventDate = date;

  Future<QuerySnapshot> _getEvents() async {
    FirebaseUser currentUser = await _auth.currentUser();

    if (currentUser != null) {
      QuerySnapshot events = await Firestore.instance
          .collection('calendar_events')
          .where('time',
              isGreaterThan: new DateTime(_eventDate.year, _eventDate.month,
                  _eventDate.day - 1, 23, 59, 59))
          .where('time',
              isLessThan: new DateTime(
                  _eventDate.year, _eventDate.month, _eventDate.day + 1))
          .where('email', isEqualTo: currentUser.email)
          .getDocuments();

      return events;
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        leading: new BackButton(),
        title: new Text(_eventDate.month.toString() +
            '/' +
            _eventDate.day.toString() +
            '/' +
            _eventDate.year.toString() +
            ' Events'),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _onFabClicked,
        child: new Icon(Icons.add),
      ),
      body: FutureBuilder(
          future: _getEvents(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return new LinearProgressIndicator();
              case ConnectionState.done:
              default:
                if (snapshot.hasError)
                  return new Text('Error: ${snapshot.error}');
                else {
                  return ListView(
                    children: snapshot.data.documents.map((document) {
                      DateTime _eventTime = document.data['time'];
                      var eventDateFormatter =
                          new DateFormat("MMMM d, yyyy 'at' h:mma");

                      return new GestureDetector(
                          onTap: () => _onCardClicked(document),
                          child: new Card(
                            color: Colors.amberAccent,
                            elevation: 10.0,
                            shape: Border.all(
                                color: Theme.of(context).indicatorColor),
                            child: new Row(
                              children: <Widget>[
                                new Expanded(
                                  child: new Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      new Container(
                                        padding: EdgeInsets.all(10.0),
                                        child: new Text(
                                          'Event: ' + document.data['name'],
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline5,
                                        ),
                                      ),
                                      new Container(
                                        padding: EdgeInsets.all(10.0),
                                        child: new Text(
                                            'Time: ' +
                                                eventDateFormatter
                                                    .format(_eventTime),
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline5),
                                      ),
                                      new Container(
                                        padding: EdgeInsets.all(10.0),
                                        child: new Text(
                                            'Summary: ' +
                                                document.data['summary'],
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline5),
                                      ),
                                    ],
                                  ),
                                ),
                                new Container(
                                    child: new IconButton(
                                        iconSize: 30.0,
                                        padding: EdgeInsets.all(5.0),
                                        icon: new Icon(Icons.delete),
                                        onPressed: () =>
                                            _deleteEvent(document))),
                              ],
                            ),
                          ));
                    }).toList(),
                  );
                }
            }
          }),
    );
  }

  void _onCardClicked(DocumentSnapshot document) {
    Event event = new Event(document.data['name'], document.data['summary'],
        document.data['time'], document.documentID);
    Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (BuildContext context) => new EventCreator(event)));
  }

  void _deleteEvent(DocumentSnapshot document) {
    setState(() {
      Firestore.instance
          .collection('calendar_events')
          .document(document.documentID)
          .delete();
    });
  }

  void _onFabClicked() {
    DateTime _createDateTime = new DateTime(_eventDate.year, _eventDate.month,
        _eventDate.day, DateTime.now().hour, DateTime.now().minute);

    Event _event = new Event("", "", _createDateTime, null);

    Navigator.push(
        context, MaterialPageRoute(builder: (context) => EventCreator(_event)));
  }
}
