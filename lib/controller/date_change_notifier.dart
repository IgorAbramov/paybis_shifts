import 'package:flutter/material.dart';

class DateChangeNotifier with ChangeNotifier {
  DateTime _dateTime;

  DateChangeNotifier(this._dateTime);

  DateTime get dateTime => _dateTime;
  set dateTime(DateTime value) {
    _dateTime = value;
    notifyListeners();
  }
}
