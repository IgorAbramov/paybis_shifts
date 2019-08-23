import 'package:cloud_firestore/cloud_firestore.dart';

final _fireStore = Firestore.instance;

class DBController {
  Stream createStream<QuerySnapshot>(int month) {
    return _fireStore
        .collection('days')
        .where('month', isEqualTo: month)
        .orderBy('day', descending: false)
        .snapshots();
  }

  getDocument(String docID) async {
    return await _fireStore.collection('days').document('$docID').get();
  }

  updateHolderToNone(DocumentSnapshot documentSnapshot, int number) async {
    return await _fireStore
        .collection('days')
        .document(documentSnapshot.documentID)
        .updateData({'$number.holder': ''});
  }

  updateHolder(
      DocumentSnapshot documentSnapshot, int number, String choiceOfEmp) async {
    return await _fireStore
        .collection('days')
        .document(documentSnapshot.documentID)
        .updateData({'$number.holder': choiceOfEmp});
  }

  void updateData(selectedDoc, newValues) {
    Firestore.instance
        .collection('days')
        .document(selectedDoc)
        .updateData(newValues)
        .catchError((e) {
      print(e);
    });
  }

  void deleteData(docId) {
    Firestore.instance
        .collection('days')
        .document(docId)
        .delete()
        .catchError((e) {
      print(e);
    });
  }

  void getDays() async {
//    final days = await _fireStore
//        .collection('days')
//        .where('month', isEqualTo: '${_dateTime.month.toString()}')
//        .getDocuments();
//    for (var day in days.documents) {}
//    print(_dateTime.month.toString());
  }

  void daysStream() async {
//    await for (var snapshot in _fireStore
//        .collection('days')
//        .where('month', isEqualTo: '${_dateTime.month.toString()}')
//        .snapshots()) {
////      for (var day in snapshot.documents) {}
//    }
  }
}
