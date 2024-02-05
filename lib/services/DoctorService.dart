import 'package:instant_doctor/services/BaseService.dart';

import '../main.dart';
import '../models/UserModel.dart';

class DoctorService extends BaseService {
  var userCol = db.collection("Users");

  Stream<UserModel> getDoc({required String docId}) {
    var result = userCol
        .doc(docId)
        .snapshots()
        .map((event) => UserModel.fromJson(event.data()!));
    return result;
  }

  Stream<List<UserModel>> getAllDocs() {
    var result = userCol.where('role', isEqualTo: 'Doctor').snapshots().map(
        (event) =>
            event.docs.map((e) => UserModel.fromJson(e.data())).toList());
    return result;
  }

  Stream<List<UserModel>> getTopDocs() {
    var result = userCol.where('role', isEqualTo: 'Doctor').snapshots().map(
        (event) =>
            event.docs.map((e) => UserModel.fromJson(e.data())).toList());
    return result;
  }
}
