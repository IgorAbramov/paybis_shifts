import 'package:flutter/material.dart';

class Employee {
  String name;
  Color color;
  String empColor;
  String initial;
  String email;
  String department;
  String position;
  String id;

  Employee(
      {this.name,
      this.color,
      this.initial,
      this.email,
      this.id,
      this.empColor,
      this.department,
      this.position});

  Map buildMap(String name, String email, String initial, String empColor,
      String department, String position) {
    Map map = {
      'name': name,
      'email': email,
      'initial': initial,
      'color': empColor,
      'department': department,
      'position': position
    };

    return map;
  }
}
