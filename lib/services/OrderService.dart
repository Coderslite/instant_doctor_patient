import 'dart:math';

import 'package:get/get.dart';
import 'package:instant_doctor/constant/constants.dart';
import 'package:instant_doctor/models/DrugModel.dart';
import 'package:instant_doctor/services/GetUserId.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';
import '../models/OrderModel.dart';
import 'DrugService.dart';
import 'NotificationService.dart';

class OrderService {
  final drugService = Get.find<DrugService>();
  final notificationService = Get.find<NotificationService>();

  var orderCol = db.collection("Orders");

  Future<String> generateUniqueTrackingId() async {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    String generateCode() {
      final rand = Random();
      return List.generate(8, (index) => chars[rand.nextInt(chars.length)])
          .join();
    }

    String trackingId = generateCode();
    bool exists = true;

    // Keep generating until it doesn't exist
    while (exists) {
      final snapshot =
          await orderCol.where("trackingId", isEqualTo: trackingId).get();
      if (snapshot.docs.isEmpty) {
        exists = false;
      } else {
        trackingId = generateCode(); // Try again
      }
    }

    return trackingId;
  }

  Future<void> newOrder({required OrderModel order}) async {
    var res = await orderCol.add(order.toJson());
    await orderCol.doc(res.id).update({"id": res.id});
    // transactionService.newTransaction(
    //     title: "Your purchase was success",
    //     userId: userController.userId.value,
    //     amount: order.totalAmount.validate(),
    //     type: TransactionType.debit);
    notificationService.newNotification(
        userId: userController.userId.value,
        type: NotificationType.transaction,
        title: "Your purchase was success");
  }

  Stream<List<OrderModel>> getMyOrders() {
    var ref = orderCol
        .where('userId', isEqualTo: userController.userId.value)
        .orderBy('createdAt', descending: true)
        .snapshots();
    return ref.map((event) =>
        event.docs.map((e) => OrderModel.fromJson(e.data())).toList());
  }

  Stream<OrderModel> getMyOrderById({required String orderId}) {
    var ref = orderCol.doc(orderId).snapshots();
    return ref.map((event) => OrderModel.fromJson(event.data()!));
  }

  Stream<List<OrderModel>> getMyPendOrders() {
    var ref = orderCol
        .where('userId', isEqualTo: userController.userId.value)
        .where('status', isEqualTo: 'Pending')
        .snapshots();
    return ref.map((event) =>
        event.docs.map((e) => OrderModel.fromJson(e.data())).toList());
  }

  Future<void> updatePharmacyEarning(
      {required String orderId, required int pharmacyEarning}) async {
    orderCol.doc(orderId).update({
      "pharmacyEarning": pharmacyEarning,
    });
  }

  Future<void> updateQuantity(
      {required String itemId, required int qty}) async {
    var res = await drugService.drugCol.doc(itemId).get();

    int currentQty = DrugModel.fromJson(res.data()!).remaining.validate();

    int newQty = (currentQty - qty) < 1 ? 0 : currentQty - qty;

    await drugService.drugCol.doc(itemId).update({
      "remaining": newQty,
    });
  }
}
