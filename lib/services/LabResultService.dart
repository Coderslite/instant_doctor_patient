// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instant_doctor/main.dart';
import 'package:instant_doctor/models/LabresultPricingModel.dart';
import 'package:instant_doctor/models/LapResultModel.dart';
import 'package:instant_doctor/services/GetUserId.dart';

class LabResultService {
  var labResultCol = db.collection("LabResults");
  var labResultPricingCol = db.collection("Charges");

  Future<void> uploadToResult({required List files}) async {
    var data = {
      "userId": userController.userId.value,
      "status": "Pending",
      "files": files,
      "createdAt": Timestamp.now(),
      "updateddAt": Timestamp.now(),
    };
    var res = await labResultCol.add(data);
    labResultCol.doc(res.id).update({
      "id": res.id,
    });
  }

  Stream<List<LabResultModel>> getUserLabResult() {
    var res = labResultCol
        .where('userId', isEqualTo: userController.userId.value)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((event) =>
            event.docs.map((e) => LabResultModel.fromJson(e.data())).toList());
    return res;
  }

  Future<void> deleteLabResult({required String id}) async {
    await labResultCol.doc(id).delete();
    return;
  }

  Future<void> updateOpened({required String id}) async {
    await labResultCol.doc(id).update({
      "opened": true,
    });
  }

  Future<LabresultPricingModel> getLabresultPrice() async {
    var ref = await labResultPricingCol.get();
    return LabresultPricingModel.fromJson(ref.docs.first.data());
  }
}
