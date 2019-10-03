import 'package:flutter/material.dart';

const String kPersonalPanel = 'Personal panel';
const String kSettings = 'Settings';
const String kLogOut = 'Log out';
const String kItVacations = 'IT Vacations';
const String kSupportVacations = 'Support Vacations';
const String kChangesLog = 'Changes Log';
const String kSupportDepartment = 'Support Department';
const String kITDepartment = 'IT Department';
const String kMarketingDepartment = 'Marketing Department';
const String kManagement = 'Management';
const String kTrainee = 'Trainee';
const String kJuniorSupport = 'Junior Support';
const String kMiddleSupport = 'Middle Support';
const String kSeniorSupport = 'Senior Support';
const String kAMLCertifiedSupport = 'AML Sertified Support';
const String kTeamLeadSupport = 'Team Lead Support';

const List<String> kAdminChoicesPopupMenu = [
  kSettings,
  kSupportVacations,
  kItVacations,
  kChangesLog,
  kLogOut
];

const List<String> kEmployeeChoicesPopupMenu = [
  kPersonalPanel,
  kSupportVacations,
  kItVacations,
  kChangesLog,
  kLogOut
];

const List<String> kEmployeeDepartmentTypes = [
  kSupportDepartment,
  kITDepartment,
  kMarketingDepartment,
  kManagement
];

const List<String> kSupportPositionsChoices = [
  kTrainee,
  kJuniorSupport,
  kMiddleSupport,
  kSeniorSupport,
  kAMLCertifiedSupport,
  kTeamLeadSupport
];

const List<double> kJuniorSupportSalary = [4.0, 6.0];
const List<double> kMiddleSupportSalary = [5.1, 7.65];
const List<double> kSeniorSupportSalary = [6.2, 9.3];
const List<double> kAMLCertifiedSupportSalary = [7.06, 10.59];
const List<double> kTeamLeadSupportSalary = [8.5, 12.75];

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
