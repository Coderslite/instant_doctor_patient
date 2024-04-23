// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instant_doctor/constant/constants.dart';
import 'package:instant_doctor/models/ReferralModel.dart';
import 'package:instant_doctor/services/BaseService.dart';
import 'package:instant_doctor/services/TransactionService.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';

class ReferralService extends BaseService {
  var refCol = db.collection("Referrals");
  Future<List<ReferralModel>> getReferrals({required String tag}) async {
    var result = await refCol
        .where('referredBy', isEqualTo: tag)
        .orderBy('createdAt')
        .get();
    var res = result.docs.map((e) => ReferralModel.fromJson(e.data())).toList();
    return res;
  }

  Future<void> newReferral(
      {required String userId, required String referredBy}) async {
    var data = {
      "userId": userId,
      "referredBy": referredBy,
      "createdAt": Timestamp.now(),
    };

    var docRef = await refCol.add(data);
    await refCol.doc(docRef.id).update({
      "id": docRef.id,
    });
    var userProf = await userService.getUserByTag(tag: referredBy);
    var referree = await userService.getProfileById(userId: userId);
    var availableAmount =
        await walletService.getAvaibleBalance(userId: userProf!.id.validate());
    await userService.userCol.doc(userId).update({
      "amount": availableAmount + 500,
    });
    transactionService.newTransaction(
        title: "Earn NGN 500 Referral Bonus",
        userId: userProf.id.validate(),
        amount: 500,
        type: TransactionType.credit);
    notificationService.newNotification(
      userId: userProf.id.validate(),
      type: NotificatonType.transaction,
      title:
          "You have earned NGN 500 for referring ${referree.firstName} ${referree.lastName}",
      isPushNotification: true,
      tokens: [userProf.token],
    );
    return;
  }
}
