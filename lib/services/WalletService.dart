import 'package:instant_doctor/main.dart';
import 'package:instant_doctor/services/BaseService.dart';
import 'package:nb_utils/nb_utils.dart';

import '../constant/constants.dart';
import 'TransactionService.dart';

class WalletService extends BaseService {
  var userCol = db.collection("Users");

  Future<void> topUp({required String userId, required double amount}) async {
    var availableAmount = await getAvaibleBalance(userId: userId);
    await userCol.doc(userId).update({
      "amount": availableAmount + amount,
    });
    await transactionService.newTransaction(
        title: "Wallet Top Up",
        userId: userId,
        type: TransactionType.credit,
        amount: amount.toInt());
    var token = await userService.getUserToken(userId: userId);
    await notificationService.newNotification(
        userId: userId,
        type: NotificatonType.transaction,
        title: "Your top up of NGN $amount was successful",
        tokens: [token],
        isPushNotification: true);
  }

  Future<double> getAvaibleBalance({required String userId}) async {
    var result = await userCol.doc(userId).get();
    var amount = result.data()!['amount'];
    if (amount != null) {
      return double.parse(amount.toString());
    } else {
      return 0.0;
    }
  }

  Future<bool> debitUser({required String userId, required int amount}) async {
    try {
      var currentAmount = await getAvaibleBalance(userId: userId);
      var newBalance = currentAmount - amount;
      if (newBalance >= 0) {
        await userCol.doc(userId).update({
          "amount": newBalance,
        });
        return true;
      } else {
        toast("Insufficient Balance");
        return false;
      }
    } catch (err) {
      return false;
    }
  }
}
