import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paybis_com_shifts/models/employee.dart';
import 'package:paybis_com_shifts/screens/feed_screen.dart';

final _fireStore = Firestore.instance;
final feedRef = Firestore.instance.collection('feed');
final String adminFeedDocID = 'T8dBZmU5meD1LfEgfEM3';

class DBController {
  Stream createStream<QuerySnapshot>(int month) {
    return _fireStore
        .collection('days')
        .where('month', isEqualTo: month)
        .orderBy('day', descending: false)
        .snapshots();
  }

  addMonth(Map dayMap) async {
    await _fireStore
        .collection('days')
        .document()
        .setData(Map<String, dynamic>.from(dayMap));
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

  updateHours(DocumentSnapshot documentSnapshot, int number, int hours) async {
    return await _fireStore
        .collection('days')
        .document(documentSnapshot.documentID)
        .updateData({'$number.hours': hours});
  }

  changeShiftHolders(String docID1, String docID2, int number1, int number2,
      String emp1, String emp2) async {
    await _fireStore
        .collection('days')
        .document(docID1)
        .updateData({'$number1.holder': emp2});
    await _fireStore
        .collection('days')
        .document(docID2)
        .updateData({'$number2.holder': emp1});
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

  void createUser(Map emp) async {
    await _fireStore
        .collection('users')
        .document()
        .setData(Map<String, dynamic>.from(emp));
  }

  void deleteUser(String email) async {
    final docs = await _fireStore
        .collection('users')
        .where('email', isEqualTo: email)
        .getDocuments();
    for (var doc in docs.documents) {
      await _fireStore
          .collection('users')
          .document(doc.documentID)
          .delete()
          .catchError((e) {
        print(e);
      });
    }
  }

  void changeUser(String email, Map emp) async {
    //TODO implement change User logic
    final docs = await _fireStore
        .collection('users')
        .where('email', isEqualTo: email)
        .getDocuments();
    for (var doc in docs.documents) {
      await _fireStore
          .collection('users')
          .document(doc.documentID)
          .updateData(Map<String, dynamic>.from(emp))
          .catchError((e) {
        print(e);
      });
    }
  }

  void deleteFiles() async {
    final docs = await _fireStore
        .collection('days')
        .where('month', isEqualTo: 10)
        .getDocuments();

    for (var doc in docs.documents) {
      print(doc.data);
      await _fireStore
          .collection('days')
          .document(doc.documentID)
          .delete()
          .catchError((e) {
        print(e);
      });
    }
  }

//  void addHoursToDays() async {
//    final docs = await _fireStore
//        .collection('days')
//        .where('year', isEqualTo: 2019)
//        .getDocuments();
//
//    for (var doc in docs.documents) {
//      for (int i = 1; i < 10; i++) {
//        await _fireStore
//            .collection('days')
//            .document(doc.documentID)
//            .updateData({'$i.hours': 8}).catchError((e) {
//          print(e);
//        });
//      }
//    }
//  }

  getUsers(List<Employee> list) async {
    final users = await _fireStore.collection('users').getDocuments();
    for (var user in users.documents) {
      list.add(Employee(
        email: user.data['email'],
        name: user.data['name'],
        initial: user.data['initial'],
        empColor: user.data['color'],
        department: user.data['department'],
        position: user.data['position'],
        id: user.documentID,
      ));
    }
//    for (var emp in list) {
//      print(emp.email);
//      print(emp.name);
//      print(emp.empColor);
//      print(emp.id);
//      print(emp.initial);
//    }
    return list;
  }

  void daysStream() async {
//    await for (var snapshot in _fireStore
//        .collection('days')
//        .where('month', isEqualTo: '${_dateTime.month.toString()}')
//        .snapshots()) {
////      for (var day in snapshot.documents) {}
//    }
  }

  getAdminFeed() async {
    QuerySnapshot snapshot = await feedRef
        .document(adminFeedDocID)
        .collection('feedItems')
        .orderBy('timestamp', descending: true)
        .getDocuments();
    List<FeedItem> feedItems = [];
    snapshot.documents.forEach((doc) {
      feedItems.add(FeedItem.fromDocument(doc));
    });
    return feedItems;
  }

  Stream createAdminFeedStream<QuerySnapshot>() {
    return feedRef
        .document(adminFeedDocID)
        .collection('feedItems')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  addChangeRequestToAdminFeed(
      String docID1,
      String docID2,
      int number1,
      int number2,
      String emp1,
      String emp2,
      String date1,
      String date2,
      String shiftType1,
      String shiftType2,
      String message) {
    feedRef
        .document(adminFeedDocID)
        .collection('feedItems')
        .document("$emp1$emp2$number1$number2")
        .setData({
      "type": "changeRequest",
      "docID1": docID1,
      "docID2": docID2,
      "number1": number1,
      "number2": number2,
      "emp1": emp1,
      "emp2": emp2,
      "date1": date1,
      "date2": date2,
      "shiftType1": shiftType1,
      "shiftType2": shiftType2,
      "timestamp": DateTime.now(),
      "message": message,
    });
  }

  removeChangeRequestFromAdminFeed(String id) async {
    await feedRef
        .document(adminFeedDocID)
        .collection('feedItems')
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
            .collection('changes')
            .where('emps', arrayContains: emp)
            .orderBy('timestamp', descending: true)
            .limit(numberToList)
            .snapshots()
        : feedRef
            .document(adminFeedDocID)
            .collection('changes')
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
        .collection('changes')
        .document()
        .setData(Map<String, dynamic>.from(change));
  }
}
