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

  Future<void> updatePrescription(
      {required Map<String, dynamic> data, required String prescribeId}) async {
    prescribeCol.doc(prescribeId).update(data);
  }

  Future<void> deletePrescription({required String prescribeId}) async {
    prescribeCol.doc(prescribeId).delete();
  }
}
