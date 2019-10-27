import 'package:flutter/material.dart';

class VacationWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 25.0,
      width: 25.0,
      decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.all(Radius.circular(7.0))),
      child: Icon(
        Icons.brightness_high,
        color: Colors.yellowAccent,
        size: 20.0,
      ),
    );
  }
}

class ParkingWidget extends StatelessWidget {
  final Color color;

  ParkingWidget(this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 25.0,
      width: 25.0,
      decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.all(Radius.circular(7.0))),
      child: Icon(
        Icons.directions_car,
        color: color,
        size: 20.0,
      ),
    );
  }
}
