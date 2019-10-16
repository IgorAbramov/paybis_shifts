import 'package:flutter/material.dart';

const String kStats = 'Stats';
const String kSettings = 'Settings';
const String kLogOut = 'Log out';
const String kItDaysOff = 'IT days off';
const String kParking = 'Parking';
const String kSupportDaysOff = 'Support days off';
const String kChangeRequests = 'Change Requests';
const String kRecentChanges = 'Recent Changes';
const String kSupportDepartment = 'Support Department';
const String kITDepartment = 'IT Department';
const String kMarketingDepartment = 'Marketing Department';
const String kManagement = 'Management';
const String kAdmin = 'Admin';
const String kTrainee = 'Trainee';
const String kJuniorSupport = 'Junior Support';
const String kMiddleSupport = 'Middle Support';
const String kSeniorSupport = 'Senior Support';
const String kAMLCertifiedSupport = 'AML Sertified Support';
const String kTeamLeadSupport = 'Team Lead Support';

const List<String> kAdminChoicesPopupMenu = [
  kChangeRequests,
  kRecentChanges,
  kStats,
  kSupportDaysOff,
  kItDaysOff,
  kParking,
  kSettings,
  kLogOut
];

const List<String> kItChoicesPopupMenu = [kItDaysOff, kSettings, kLogOut];

const List<String> kEmployeeWithCarChoicesPopupMenu = [
  kStats,
  kRecentChanges,
  kSupportDaysOff,
  kParking,
  kSettings,
  kLogOut
];

const List<String> kEmployeeChoicesPopupMenu = [
  kStats,
  kRecentChanges,
  kSupportDaysOff,
  kSettings,
  kLogOut
];

const List<String> kEmployeeDepartmentTypes = [
  kSupportDepartment,
  kITDepartment,
  kMarketingDepartment,
  kManagement,
  kAdmin,
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
  color: textIconColor,
);

const TextStyle kDateFontStyle = TextStyle(
  fontSize: 11.0,
  fontWeight: FontWeight.bold,
  color: textPrimaryColor,
);

const TextStyle kButtonFontStyle = TextStyle(
  fontSize: 14.0,
  fontWeight: FontWeight.bold,
  color: textIconColor,
);

const kSendButtonTextStyle = TextStyle(
  color: primaryColor,
  fontWeight: FontWeight.bold,
  fontSize: 18.0,
);

const kPersonalPageDataTextStyle = TextStyle(
  color: textPrimaryColor,
  fontSize: 18.0,
);

const kMessageTextFieldDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  hintText: 'Type your message here...',
  border: InputBorder.none,
);

const kMessageContainerDecoration = BoxDecoration(
  border: Border(
    top: BorderSide(color: accentColor, width: 2.0),
  ),
);

const kTextFieldDecoration = InputDecoration(
  hintText: 'Enter the value.',
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: primaryColor, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: darkPrimaryColor, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
);

const Color darkPrimaryColor = Color(0xFF0288D1);
const Color lightPrimaryColor = Color(0xFFB3E5FC);
const Color primaryColor = Color(0xFF03A9F4);
const Color textIconColor = Color(0xFFFFFFFF);
const Color accentColor = Color(0xFFFF5252);
const Color textPrimaryColor = Color(0xFF212121);
const Color secondaryColor = Color(0xFF757575);
const Color dividerColor = Color(0xFFBDBDBD);
