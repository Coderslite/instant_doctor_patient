import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instant_doctor/main.dart';
import 'package:instant_doctor/models/AnonymousModel.dart';
import 'package:instant_doctor/services/CustomMailService.dart';
import 'package:instant_doctor/services/GetUserId.dart';

class AnonymousService {
  var anonymousCol = db.collection("AnonymousQuestions");
  Stream<List<AnonymousModel>> getAnonymous() {
    var res = anonymousCol
        .where('userId', isEqualTo: userController.userId.value)
        .orderBy('createdAt', descending: false)
        .snapshots();
    return res.map((event) =>
        event.docs.map((e) => AnonymousModel.fromJson(e.data())).toList());
  }

  Future<void> addAnonymous({required String question}) async {
    var data = {
      "question": question,
      "answer": "",
      "userId": userController.userId.value,
      "status": "pending",
      "createdAt": Timestamp.now(),
    };
    var res = await anonymousCol.add(data);
    anonymousCol.doc(res.id).update({
      "id": res.id,
    });
    await sendCustomMail(activityName: 'Anonymous');
  }

  Future<void> deleteAnonymous({required String id}) async {
    await anonymousCol.doc(id).delete();
  }
}
