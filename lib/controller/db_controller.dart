import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:paybis_com_shifts/constants.dart';
import 'package:paybis_com_shifts/models/employee.dart';
import 'package:paybis_com_shifts/screens/login_screen.dart';

final _fireStore = Firestore.instance;
final feedRef = Firestore.instance.collection('feed');
final String adminFeedDocID = 'T8dBZmU5meD1LfEgfEM3';
final _auth = FirebaseAuth.instance;

class DBController {
  Stream createDaysStream<QuerySnapshot>(int year, int month) {
    return _fireStore
        .collection(kDaysCollection)
        .where('month', isEqualTo: month)
        .where('year', isEqualTo: year)
        .orderBy('day', descending: false)
        .snapshots();
  }

  addMonth(Map dayMap) async {
    await _fireStore
        .collection(kDaysCollection)
        .document()
        .setData(Map<String, dynamic>.from(dayMap));
  }

  getDocument(String docID) async {
    return await _fireStore
        .collection(kDaysCollection)
        .document('$docID')
        .get();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    return _auth.sendPasswordResetEmail(email: email);
  }

//  updateHolderToNone(DocumentSnapshot documentSnapshot, int number) async {
//    return await _fireStore
//        .collection(kDaysCollection)
//        .document(documentSnapshot.documentID)
//        .updateData({'$number.holder': ''});
//  }

  deleteShift(
      DocumentSnapshot documentSnapshot, String shiftType, Map shift) async {
    await _fireStore
        .collection(kDaysCollection)
        .document(documentSnapshot.documentID)
        .updateData({
      '$shiftType': FieldValue.arrayRemove([shift])
    });
  }

//  updateHolder(
//      DocumentSnapshot documentSnapshot, int number, String choiceOfEmp) async {
//    return await _fireStore
//        .collection(kDaysCollection)
//        .document(documentSnapshot.documentID)
//        .updateData({'$number.holder': choiceOfEmp});
//  }

  updateShift(DocumentSnapshot documentSnapshot, String shiftType, Map oldShift,
      Map newShift) async {
    await _fireStore
        .collection(kDaysCollection)
        .document(documentSnapshot.documentID)
        .updateData({
      '$shiftType': FieldValue.arrayRemove([oldShift])
    });
    await _fireStore
        .collection(kDaysCollection)
        .document(documentSnapshot.documentID)
        .updateData({
      '$shiftType': FieldValue.arrayUnion([newShift])
    });
  }

  createShift(
      DocumentSnapshot documentSnapshot, String shiftType, Map shift) async {
    await _fireStore
        .collection(kDaysCollection)
        .document(documentSnapshot.documentID)
        .updateData({
      '$shiftType': FieldValue.arrayUnion([shift])
    });
  }

  createWholeShiftCopy(
      DocumentSnapshot documentSnapshot, List shifts, String shiftType) async {
    for (int i = 0; i < shifts.length; i++) {
      shifts[i]['type'] = shiftType;
      await _fireStore
          .collection(kDaysCollection)
          .document(documentSnapshot.documentID)
          .updateData({
        '$shiftType': FieldValue.arrayUnion([shifts[i]])
      });
    }
  }

//  updateHours(DocumentSnapshot documentSnapshot, int number, int hours) async {
//    return await _fireStore
//        .collection(kDaysCollection)
//        .document(documentSnapshot.documentID)
//        .updateData({'$number.hours': hours});
//  }

  updateHours(DocumentSnapshot documentSnapshot, String shiftType, Map shiftOld,
      Map shiftNew) async {
    await _fireStore
        .collection(kDaysCollection)
        .document(documentSnapshot.documentID)
        .updateData({
      '$shiftType': FieldValue.arrayRemove([shiftOld])
    });
    await _fireStore
        .collection(kDaysCollection)
        .document(documentSnapshot.documentID)
        .updateData({
      '$shiftType': FieldValue.arrayUnion([shiftNew])
    });
  }

  changeShiftHolders(String docID1, String docID2, String shiftType1,
      String shiftType2, Map shift1, Map shift2) async {
//    print(
//        'docID1: $docID1 ::: docID2: $docID2 ::: shiftType1: $shiftType1 ::: shiftType2: $shiftType2 ::: shift1: ${shift1.toString()} ::: shift2: ${shift2.toString()}');

    await _fireStore.collection(kDaysCollection).document(docID1).updateData({
      '$shiftType1': FieldValue.arrayRemove([shift1])
    });
    await _fireStore.collection(kDaysCollection).document(docID2).updateData({
      '$shiftType2': FieldValue.arrayRemove([shift2])
    });

    shift1['type'] = shiftType2;
    shift2['type'] = shiftType1;

    await _fireStore.collection(kDaysCollection).document(docID1).updateData({
      '$shiftType1': FieldValue.arrayUnion([shift2])
    });
    await _fireStore.collection(kDaysCollection).document(docID2).updateData({
      '$shiftType2': FieldValue.arrayUnion([shift1])
    });
  }

  void updateData(selectedDoc, newValues) {
    Firestore.instance
        .collection(kDaysCollection)
        .document(selectedDoc)
        .updateData(newValues)
        .catchError((e) {
      print(e);
    });
  }

  void deleteData(docId) {
    Firestore.instance
        .collection(kDaysCollection)
        .document(docId)
        .delete()
        .catchError((e) {
      print(e);
    });
  }

  void createUser(Map emp) async {
    await _fireStore
        .collection(kUsersCollection)
        .document()
        .setData(Map<String, dynamic>.from(emp));
  }

  void deleteUser(String email) async {
    final docs = await _fireStore
        .collection(kUsersCollection)
        .where('email', isEqualTo: email)
        .getDocuments();
    for (var doc in docs.documents) {
      await _fireStore
          .collection(kUsersCollection)
          .document(doc.documentID)
          .delete()
          .catchError((e) {
        print(e);
      });
    }
  }

  void changeUser(String email, Map emp) async {
    final docs = await _fireStore
        .collection(kUsersCollection)
        .where('email', isEqualTo: email)
        .getDocuments();
    for (var doc in docs.documents) {
      await _fireStore
          .collection(kUsersCollection)
          .document(doc.documentID)
          .updateData(Map<String, dynamic>.from(emp))
          .catchError((e) {
        print(e);
      });
    }
  }

  void deleteMonth() async {
    final docs = await _fireStore
        .collection(kDaysCollection)
        .where('month', isEqualTo: 1)
        .getDocuments();

    for (var doc in docs.documents) {
      print(doc.data);
      await _fireStore
          .collection(kDaysCollection)
          .document(doc.documentID)
          .delete()
          .catchError((e) {
        print(e);
      });
    }
  }

//  void addHoursToDays() async {
//    final docs = await _fireStore
//        .collection(kDaysCollection)
//        .where('year', isEqualTo: 2019)
//        .getDocuments();
//
//    for (var doc in docs.documents) {
//      for (int i = 1; i < 10; i++) {
//        await _fireStore
//            .collection(kDaysCollection)
//            .document(doc.documentID)
//            .updateData({'$i.hours': 8}).catchError((e) {
//          print(e);
//        });
//      }
//    }
//  }

  getUsers(List<Employee> list) async {
    final users = await _fireStore.collection(kUsersCollection).getDocuments();
    for (var user in users.documents) {
      list.add(Employee(
        email: user.data['email'],
        name: user.data['name'],
        initial: user.data['initial'],
        empColor: user.data['color'],
        department: user.data['department'],
        position: user.data['position'],
        hasCar: user.data['hasCar'],
        carInfo: user.data['carInfo'],
        cardId: user.data['cardId'],
        id: user.documentID,
      ));
    }
    return list;
  }

  Stream createAdminFeedStream<QuerySnapshot>() {
    return feedRef
        .document(adminFeedDocID)
        .collection(kFeedItemsCollection)
        .where('confirmed', isEqualTo: true)
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Stream createSupportFeedStream<QuerySnapshot>() {
    return feedRef
        .document(adminFeedDocID)
        .collection(kFeedItemsCollection)
        .where('emp2', isEqualTo: employee.initial)
        .where('confirmed', isEqualTo: false)
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Stream createEmployeePendingRequestFeedStream<QuerySnapshot>() {
    return feedRef
        .document(adminFeedDocID)
        .collection(kFeedItemsCollection)
        .where('emp1', isEqualTo: employee.initial)
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  addChangeRequestToFeed(
    String docID1,
    String docID2,
    String position1,
    String position2,
    String emp1,
    String emp2,
    String date1,
    String date2,
    String shiftType1,
    String shiftType2,
    String message,
    bool confirmed,
  ) {
    feedRef
        .document(adminFeedDocID)
        .collection(kFeedItemsCollection)
        .document("$emp1$emp2$docID1")
        .setData({
      "type": "changeRequest",
      "docID1": docID1,
      "docID2": docID2,
      "position1": position1,
      "position2": position2,
      "emp1": emp1,
      "emp2": emp2,
      "date1": date1,
      "date2": date2,
      "shiftType1": shiftType1,
      "shiftType2": shiftType2,
      "confirmed": confirmed,
      "timestamp": DateTime.now(),
      "message": message,
    });
  }

  setChangeRequestStateToConfirmed(String id) async {
    await feedRef
        .document(adminFeedDocID)
        .collection(kFeedItemsCollection)
        .document(id)
        .updateData({'confirmed': true});
  }

  removeChangeRequestFromFeed(String id) async {
    await feedRef
        .document(adminFeedDocID)
        .collection(kFeedItemsCollection)
        .document(id)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  Stream createRecentChangesStream<QuerySnapshot>(
      int numberToList, String emp, bool personal) {
    return personal
        ? feedRef
            .document(adminFeedDocID)
            .collection(kChangesCollection)
            .where('emps', arrayContains: emp)
            .orderBy('timestamp', descending: true)
            .limit(numberToList)
            .snapshots()
        : feedRef
            .document(adminFeedDocID)
            .collection(kChangesCollection)
            .orderBy('timestamp', descending: true)
            .limit(numberToList)
            .snapshots();
  }

  addChangeToRecentChanges(String emp1, String emp2, String date1, String date2,
      String shiftType1, String shiftType2, String message, bool confirmed) {
    List emps = [emp1, emp2];
    Map<String, dynamic> change = {
      'emps': emps,
      'text': '$message $emp1 $date1 $shiftType1 with $emp2 $date2 $shiftType2',
      'confirmed': confirmed,
      'timestamp': DateTime.now()
    };
    feedRef
        .document(adminFeedDocID)
        .collection(kChangesCollection)
        .document()
        .setData(Map<String, dynamic>.from(change));
  }

  addVacation(String docID, String holder) async {
    await _fireStore.collection(kDaysCollection).document(docID).updateData({
      'vacations': FieldValue.arrayUnion([holder])
    });
  }

  removeVacation(String docID, String holder) async {
    await _fireStore.collection(kDaysCollection).document(docID).updateData({
      'vacations': FieldValue.arrayRemove([holder])
    });
  }

  addSickLeave(String docID, String holder) async {
    await _fireStore.collection(kDaysCollection).document(docID).updateData({
      'sick': FieldValue.arrayUnion([holder])
    });
  }

  removeSickLeave(String docID, String holder) async {
    await _fireStore.collection(kDaysCollection).document(docID).updateData({
      'sick': FieldValue.arrayRemove([holder])
    });
  }

  addITVacation(String docID, String holder) async {
    await _fireStore.collection(kDaysCollection).document(docID).updateData({
      'ITVacations': FieldValue.arrayUnion([holder])
    });
  }

  removeITVacation(String docID, String holder) async {
    await _fireStore.collection(kDaysCollection).document(docID).updateData({
      'ITVacations': FieldValue.arrayRemove([holder])
    });
  }

  addITSickLeave(String docID, String holder) async {
    await _fireStore.collection(kDaysCollection).document(docID).updateData({
      'ITSick': FieldValue.arrayUnion([holder])
    });
  }

  removeITSickLeave(String docID, String holder) async {
    await _fireStore.collection(kDaysCollection).document(docID).updateData({
      'ITSick': FieldValue.arrayRemove([holder])
    });
  }

  addParkingMGMT(String docID, String holder) async {
    await _fireStore.collection(kDaysCollection).document(docID).updateData({
      'mgmt': FieldValue.arrayUnion([holder])
    });
  }

  removeParkingMGMT(String docID, String holder) async {
    await _fireStore.collection(kDaysCollection).document(docID).updateData({
      'mgmt': FieldValue.arrayRemove([holder])
    });
  }

  addParkingItCs(String docID, String holder) async {
    await _fireStore.collection(kDaysCollection).document(docID).updateData({
      'itcs': FieldValue.arrayUnion([holder])
    });
  }

  removeParkingItCs(String docID, String holder) async {
    await _fireStore.collection(kDaysCollection).document(docID).updateData({
      'itcs': FieldValue.arrayRemove([holder])
    });
  }

  addAbsenceShift(String docID, String holder, String shiftType) async {
    await _fireStore.collection(kDaysCollection).document(docID).updateData({
      'abscent$shiftType': FieldValue.arrayUnion([holder])
    });
  }

  removeAbsenceShift(String docID, String holder, String shiftType) async {
    await _fireStore.collection(kDaysCollection).document(docID).updateData({
      'abscent$shiftType': FieldValue.arrayRemove([holder])
    });
  }

  changeHolidayStatus(String docID, bool isHoliday) async {
    await _fireStore
        .collection(kDaysCollection)
        .document(docID)
        .updateData({'isHoliday': isHoliday});
  }
}
