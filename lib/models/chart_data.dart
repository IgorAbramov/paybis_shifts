import 'package:cloud_firestore/cloud_firestore.dart';

class SupportChartData {
  int year;
  int month;
  String name;
  String initial;
  int transactions;
  int verifications;
  int chats;

  SupportChartData({
    this.year,
    this.month,
    this.name,
    this.initial,
    this.transactions,
    this.verifications,
    this.chats,
  });

  Map buildMap(int year, int month, String name, String initial,
      int transactions, int verifications, int chats) {
    Map map = {
      'year': year,
      'month': month,
      'name': name,
      'initial': initial,
      'transactions': transactions,
      'verifications': verifications,
      'chats': chats,
    };

    return map;
  }

  factory SupportChartData.fromDocument(DocumentSnapshot doc) {
    return SupportChartData(
      year: doc['year'],
      month: doc['month'],
      name: doc['name'],
      initial: doc['initial'],
      transactions: doc['transactions'],
      verifications: doc['verifications'],
      chats: doc['chats'],
    );
  }
}
