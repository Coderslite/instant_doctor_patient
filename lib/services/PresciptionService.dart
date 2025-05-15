import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';
import '../models/PrescriptionModel.dart';

class PresciptionService {
  var prescribeCol = db.collection("Prescription");

  Stream<List<Prescriptionmodel>> getUserPrescription(
      {required String appointmentId}) {
    var ref = prescribeCol
        .where('appointmentId', isEqualTo: appointmentId)
        .orderBy('createdAt', descending: true)
        .snapshots();
    return ref.map((event) =>
        event.docs.map((e) => Prescriptionmodel.fromJson(e.data())).toList());
  }

  newPrescription(
      {required String appointmentId,
      required String userId,
      required String docId,
      required String prescription}) async {
    var data = {
      "appointmentId": appointmentId,
      "userId": userId,
      "doctorId": docId,
      "prescription": prescription,
      "createdAt": Timestamp.now(),
      "seen": false,
    };
    var id = await prescribeCol.add(data);
    updatePrescription(prescribeId: id.id, data: {
      "id": id.id,
    });
  }

  Future<void> updatePrescription(
      {required Map<String, dynamic> data, required String prescribeId}) async {
    prescribeCol.doc(prescribeId).update(data);
  }

  Future<void> deletePrescription({required String prescribeId}) async {
    prescribeCol.doc(prescribeId).delete();
  }
}
