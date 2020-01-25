import 'package:cloud_firestore/cloud_firestore.dart';
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
  bool hasCar;
  String carInfo;
  String cardId;

  Employee(
      {this.name,
      this.color,
      this.initial,
      this.email,
      this.id,
      this.empColor,
      this.department,
      this.position,
      this.hasCar,
      this.carInfo,
      this.cardId});

  Map buildMap(
      String id,
      String name,
      String email,
      String initial,
      String empColor,
      String department,
      String position,
      bool hasCar,
      String carInfo,
      String cardId) {
    Map map = {
      'id': id,
      'name': name,
      'email': email,
      'initial': initial,
      'color': empColor,
      'department': department,
      'position': position,
      'hasCar': hasCar,
      'carInfo': carInfo,
      'cardId': cardId,
    };

    return map;
  }

  factory Employee.fromDocument(DocumentSnapshot doc) {
    return Employee(
      id: doc['id'],
      email: doc['email'],
      name: doc['name'],
      initial: doc['initial'],
      empColor: doc['color'],
      department: doc['department'],
      position: doc['position'],
      hasCar: doc['hasCar'],
      carInfo: doc['carInfo'],
      cardId: doc['cardId'],
    );
  }
}
