import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderBoardData {
  String name;
  int for3months;
  int for6months;
  int for12months;

  LeaderBoardData({
    this.name,
    this.for3months,
    this.for6months,
    this.for12months,
  });

  Map buildMap(String name, int for3months, int for6months, int for12months) {
    Map map = {
      'name': name,
      'for3months': for3months,
      'for6months': for6months,
      'for12months': for12months,
    };

    return map;
  }

  factory LeaderBoardData.fromDocument(DocumentSnapshot doc) {
    return LeaderBoardData(
      name: doc['name'],
      for3months: doc['for3months'],
      for6months: doc['for6months'],
      for12months: doc['for12months'],
    );
  }
}
