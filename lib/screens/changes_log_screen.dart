import 'package:flutter/material.dart';

class ChangesLogScreen extends StatefulWidget {
  static const String id = 'changes_log_screen';
  @override
  _ChangesLogScreenState createState() => _ChangesLogScreenState();
}

class _ChangesLogScreenState extends State<ChangesLogScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Changes Log'),
      ),
      body: Column(
        children: <Widget>[
          //TODO show changes from Firebase Changes collections
          //TODO show only last 50 changes with the possibility to see more
        ],
      ),
    );
  }
}
