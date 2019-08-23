import 'package:flutter/material.dart';

class Employee {
  String name;
  MaterialColor color;
  String initial;
  int workingHours;
  String email;
  double salaryNight;
  double salaryRegular;

  Employee(
      {this.name,
      this.color,
      this.initial,
      this.email,
      this.salaryNight,
      this.salaryRegular});
}
