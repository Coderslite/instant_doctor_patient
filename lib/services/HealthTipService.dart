import 'package:instant_doctor/main.dart';
import 'package:instant_doctor/models/HealthTipModel.dart';
import 'package:instant_doctor/services/BaseService.dart';

class HealthTipService extends BaseService {
  var healthCol = db.collection("HealthTips");

  Stream<List<HealthTipModel>> getHealthTips({required String type}) {
    var healthRef = healthCol.where('type', isEqualTo: type).snapshots();
    var res = healthRef.map((event) =>
        event.docs.map((e) => HealthTipModel.fromJson(e.data())).toList());
    return res;
  }

  Stream<List<HealthTipModel>> getHealthTipsByCategory(
      {required String category}) {
    var healthRef =
        healthCol.where('category', isEqualTo: category).snapshots();
    var res = healthRef.map((event) =>
        event.docs.map((e) => HealthTipModel.fromJson(e.data())).toList());
    return res;
  }

  Future<void> tipView({required String tipId, required int newView}) async {
    await healthCol.doc(tipId).update({
      "views": newView,
    });
  }
}
