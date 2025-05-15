// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instant_doctor/main.dart';
import 'package:instant_doctor/models/HealthTipModel.dart';
import 'package:instant_doctor/services/BaseService.dart';
import 'package:instant_doctor/services/GetUserId.dart';

class HealthTipService extends BaseService {
  var healthCol = db.collection("HealthTips");
  var healthCatCol = db.collection("HealthTipsCategory");

  Stream<List<HealthTipModel>> getHealthTips({required String category}) {
    var healthRef =
        healthCol.where('category', isEqualTo: category).snapshots();
    var res = healthRef.map((event) =>
        event.docs.map((e) => HealthTipModel.fromJson(e.data())).toList());
    return res;
  }

  Future<List<HealthTipModel>> getHealthTipsByCategory(
      {required String categoryId}) async {
    var healthRef =
        await healthCol.where('categoryId', isEqualTo: categoryId).get();
    var res =
        healthRef.docs.map((e) => HealthTipModel.fromJson(e.data())).toList();
    return res;
  }

  Future<List<HealthTipModel>> getRelatedHealthTips({
    required String categoryId,
    required String healthTipId,
  }) async {
    var healthRef =
        await healthCol.where('categoryId', isEqualTo: categoryId).get();

    // Map results, filter out the specified healthTipId, and limit to 5
    var res = healthRef.docs
        .map((e) => HealthTipModel.fromJson(e.data()))
        .where((tip) => tip.id != healthTipId) // Exclude the current health tip
        .take(5) // Limit to 5 results
        .toList();

    return res;
  }

  Future<List<HealthTipsCategoryModel>> getHealthTipsCategory() async {
    var res = await healthCatCol.get();
    return res.docs
        .map((e) => HealthTipsCategoryModel.fromJson(e.data()))
        .toList();
  }

// likes tips
  Future<void> likeTip({required String healthTipId}) async {
    if (await isLiked(healthTipId: healthTipId)) {
      unlikeTip(healthTipId: healthTipId);
      return;
    } else {
      await healthCol
          .doc(healthTipId)
          .collection("likes")
          .doc(userController.userId.value)
          .set({
        "userId": userController.userId.value,
        "createdAt": Timestamp.now()
      });
    }
  }

  Future<void> unlikeTip({required String healthTipId}) async {
    await healthCol
        .doc(healthTipId)
        .collection("likes")
        .doc(userController.userId.value)
        .delete();
  }

  Future<bool> isLiked({required String healthTipId}) async {
    var ref = await healthCol
        .doc(healthTipId)
        .collection("likes")
        .where('userId', isEqualTo: userController.userId.value)
        .get();

    return ref.docs.isNotEmpty;
  }

  // views
  Future<void> viewHealthTip({required String healthTipId}) async {
    await healthCol
        .doc(healthTipId)
        .collection("views")
        .doc(userController.userId.value)
        .set({
      "userId": userController.userId.value,
      "createdAt": Timestamp.now()
    });
  }

  Stream<int> getViewCount({required String healthTipId}) {
    var ref = healthCol
        .doc(healthTipId)
        .collection("views")
        .where('userId', isEqualTo: userController.userId.value)
        .snapshots();

    var res = ref.map((event) => event.docs.length);
    return res;
  }

  // get articles count
  Stream<int> getArticleCount({required String categoryId}) {
    var healthRef =
        healthCol.where('categoryId', isEqualTo: categoryId).snapshots();
    var res = healthRef.map((event) => event.docs.length);
    return res;
  }
}
