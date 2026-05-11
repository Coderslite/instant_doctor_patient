import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/constant/constants.dart';
import 'package:instant_doctor/models/ReferralModel.dart';
import 'package:instant_doctor/services/BaseService.dart';
import 'package:instant_doctor/services/GetUserId.dart';
import 'package:instant_doctor/services/TransactionService.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';
import 'NotificationService.dart';
import 'UserService.dart';
import 'WalletService.dart';

class ReferralService extends BaseService {
  final walletService = Get.find<WalletService>();
  final notificationService = Get.find<NotificationService>();
  final userService = Get.find<UserService>();
  final transactionService = Get.find<TransactionService>();

  var refCol = db.collection("Referrals");

  Future<List<ReferralModel>> getReferrals() async {
    DateTime now = DateTime.now();
    DateTime startOfMonth = DateTime(now.year, now.month, 1);
    DateTime startOfNextMonth = (now.month == 12)
        ? DateTime(now.year + 1, 1, 1)
        : DateTime(now.year, now.month + 1, 1);
    var result = await refCol
        .where('referredBy', isEqualTo: userController.tag.value)
        .where('createdAt', isGreaterThanOrEqualTo: startOfMonth)
        .where('createdAt', isLessThan: startOfNextMonth)
        .orderBy('createdAt')
        .get();
    return result.docs.map((e) => ReferralModel.fromJson(e.data())).toList();
  }

  // When user signs up with referral code
  Future<void> newReferral({
    required String userId,
    required String referredBy,
  }) async {
    // Get the referrer's profile
    var referrer = await userService.getUserByTag(tag: referredBy);
    if (referrer == null) return;

    // Create referral record
    var data = {
      "userId": userId,
      "referredBy": referredBy,
      "status": "active",
      "signupBonusPaid": false,
      "totalCommissionEarned": 0,
      "createdAt": Timestamp.now(),
      "updatedAt": Timestamp.now(),
    };

    var docRef = await refCol.add(data);
    await refCol.doc(docRef.id).update({
      "id": docRef.id,
    });

    // Award ₦50 sign-up bonus
    // await _awardSignupBonus(referrer.id.validate(), referredUser);
  }

  // Award ₦50 for sign-up
  // Future<void> _awardSignupBonus(
  //     String referrerId, UserModel? referredUser) async {
  //   try {
  //     // Update referrer's balance
  //     await userService.userCol.doc(referrerId).update({
  //       "referralBalance": FieldValue.increment(0),
  //     });

  //     // Send notification
  //     await notificationService.newNotification(
  //       userId: referrerId,
  //       type: NotificationType.transaction,
  //       title:
  //           "You earned ₦50 for referring ${referredUser?.firstName ?? 'a new user'}",
  //     );
  //   } catch (e) {
  //     log("Error awarding signup bonus: $e");
  //   }
  // }

  // When referred user books an appointment and pays
  Future<void> awardAppointmentCommission({
    required String userId,
    required int appointmentAmount,
  }) async {
    try {
      var referralQuery = await refCol
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'active')
          .limit(1)
          .get();

      if (referralQuery.docs.isEmpty) return;

      var referralDoc = referralQuery.docs.first;
      var referralData = ReferralModel.fromJson(referralDoc.data());

      // Calculate 10% commission
      double commission = appointmentAmount * 0.10;

      // Update referral record
      await refCol.doc(referralDoc.id).update({
        "totalCommissionEarned": FieldValue.increment(commission.toInt()),
        "lastCommissionDate": Timestamp.now(),
        "updatedAt": Timestamp.now(),
      });

      // Get referrer's profile
      var referrer =
          await userService.getUserByTag(tag: referralData.referredBy!);
      if (referrer == null) return;

      // Get referred user's profile for notification
      var referredUser = await userService.getProfileById(userId: userId);

      // Update referrer's balance
      await userService.userCol.doc(referrer.id.validate()).update({
        "referralBalance": FieldValue.increment(commission.toInt()),
      });

      // Send notification
      await notificationService.newNotification(
        userId: referrer.id.validate(),
        type: NotificationType.transaction,
        title:
            "You earned ₦${commission.toStringAsFixed(2)} from ${referredUser.firstName ?? 'referred user'}'s appointment booking",
      );
    } catch (e) {
      log("Error awarding appointment commission: $e");
    }
  }

  // Get total earnings for a referrer
  Future<double> getTotalEarnings({required String referrerTag}) async {
    try {
      var result =
          await refCol.where('referredBy', isEqualTo: referrerTag).get();

      double total = 0;
      for (var doc in result.docs) {
        var data = ReferralModel.fromJson(doc.data());
        total += data.totalCommissionEarned ?? 0;
      }

      // Add ₦50 for each active referral
      var activeReferrals = result.docs.where((doc) {
        var data = ReferralModel.fromJson(doc.data());
        return data.status == 'active';
      }).length;

      total += (activeReferrals * 50.0);

      return total;
    } catch (e) {
      log("Error getting total earnings: $e");
      return 0.0;
    }
  }
}
