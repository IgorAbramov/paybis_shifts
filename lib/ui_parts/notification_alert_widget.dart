import 'package:flutter/material.dart';

class NotificationAlertWidget extends StatelessWidget {
  final Color color;

  NotificationAlertWidget({this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9.0),
        color: color,
      ),
      height: 30.0,
      width: 20.0,
    );
  }
}
