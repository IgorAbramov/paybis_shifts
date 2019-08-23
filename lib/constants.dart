import 'package:flutter/material.dart';
import 'package:paybis_com_shifts/models/employee.dart';

final Employee stefan =
    Employee(name: 'Стефан', color: Colors.indigo, initial: 'SN');
final Employee vova = Employee(
    name: 'Вова',
    color: Colors.green,
    initial: 'VJ',
    salaryNight: 12.75,
    salaryRegular: 8.5);
final Employee ira = Employee(
    name: 'Ира',
    color: Colors.deepOrange,
    initial: 'IP',
    salaryNight: 12.75,
    salaryRegular: 8.5);
final Employee aleksandra =
    Employee(name: 'Александра', color: Colors.purple, initial: 'ALA');
final Employee kiril = Employee(
    name: 'Кирилл',
    color: Colors.grey,
    initial: 'KT',
    salaryNight: 10.59,
    salaryRegular: 7.06);
final Employee rodion =
    Employee(name: 'Родион', color: Colors.pink, initial: 'RF');
final Employee igor = Employee(
    name: 'Игорь',
    color: Colors.blue,
    initial: 'IA',
    email: 'igor.paybis@gmail.com',
    salaryNight: 10.59,
    salaryRegular: 7.06);
final Employee aleksey = Employee(
    name: 'Алексей',
    color: Colors.brown,
    initial: 'AK',
    salaryNight: 10.59,
    salaryRegular: 7.06);
final Employee lyosha =
    Employee(name: 'Лёша', color: Colors.red, initial: 'DA');
final Employee diana = Employee(
    name: 'Диана',
    color: Colors.orange,
    initial: 'DO',
    salaryNight: 12.75,
    salaryRegular: 8.5);
final Employee alyona =
    Employee(name: 'Алёна', color: Colors.cyan, initial: 'AA');
final Employee oskar =
    Employee(name: 'Оскар', color: Colors.lightGreen, initial: 'OZ');
final Employee sergey =
    Employee(name: 'Сергей', color: Colors.amber, initial: 'SJ');
final Employee anton =
    Employee(name: 'Антон', color: Colors.teal, initial: 'ANT');
final Employee none =
    Employee(name: 'никто', color: Colors.black, initial: '+');

final List<Employee> employees = [
  vova,
  kiril,
  lyosha,
  stefan,
  alyona,
  ira,
  igor,
  aleksandra,
  diana,
  aleksey,
  rodion,
  oskar,
  sergey,
  anton
];

const String kPersonalPanel = 'Personal panel';
const String kSettings = 'Settings';
const String kLogOut = 'Log out';
const String kItVacations = 'IT Vacations';
const String kSupportVacations = 'Support Vacations';
const String kChangesLog = 'Changes Log';

const List<String> kChoicesPopupMenu = [
  kPersonalPanel,
  kSettings,
  kSupportVacations,
  kItVacations,
  kChangesLog,
  kLogOut
];

const TextStyle kHeaderFontStyle = TextStyle(
  fontSize: 18.0,
  fontWeight: FontWeight.bold,
  color: Colors.white,
);

const TextStyle kDateFontStyle = TextStyle(
  fontSize: 11.0,
  fontWeight: FontWeight.bold,
  color: Colors.black,
);

const kSendButtonTextStyle = TextStyle(
  color: Colors.lightBlueAccent,
  fontWeight: FontWeight.bold,
  fontSize: 18.0,
);

const kPersonalPageDataTextStyle = TextStyle(
  color: Colors.black,
  fontSize: 18.0,
);

const kMessageTextFieldDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  hintText: 'Type your message here...',
  border: InputBorder.none,
);

const kMessageContainerDecoration = BoxDecoration(
  border: Border(
    top: BorderSide(color: Colors.lightBlueAccent, width: 2.0),
  ),
);

const kTextFieldDecoration = InputDecoration(
  hintText: 'Enter the value.',
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.lightBlueAccent, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.lightBlueAccent, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
);
