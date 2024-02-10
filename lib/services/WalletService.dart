import 'package:get/get.dart';
import 'package:instant_doctor/main.dart';
import 'package:instant_doctor/services/BaseService.dart';
import 'package:instant_doctor/services/GetUserId.dart';
import 'package:instant_doctor/services/format_number.dart';
import 'package:nb_utils/nb_utils.dart';

import '../constant/constants.dart';
import 'TransactionService.dart';

class WalletService extends BaseService {
  var userCol = db.collection("Users");

  Future<void> topUp({required String userId, required int amount}) async {
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

  Future<int> getAvaibleBalance({required String userId}) async {
    var result = await userCol.doc(userId).get();
    var amount = result.data()!['amount'];
    if (amount != null) {
      return int.parse(amount.toString());
    } else {
      return 0;
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

  Future<bool> sendFunds(
      {required String email,
      required int amount,
      required String myId}) async {
    try {
      var balance = await getAvaibleBalance(userId: myId);
      if (balance > amount) {
        var user = await userService.getUserByEmail(email: email);
        var me =
            await userService.getUsername(userId: userController.userId.value);
        if (user != null) {
          var receiverBalance = user.amount ?? 0;
          var receiverToken = user.token;
          var newAmount = receiverBalance.toInt() + amount;
          userService.updateUserBalance(id: user.id!, amount: newAmount);
          debitUser(userId: myId, amount: amount);
          await notificationService.newNotification(
              userId: user.id!,
              type: NotificatonType.transaction,
              title: "Credit Alert of ${formatAmount(amount)} from $me",
              tokens: [receiverToken],
              isPushNotification: true);
          await transactionService.newTransaction(
              title:
                  "You sent ${formatAmount(amount)} to ${user.firstName} ${user.lastName}",
              userId: userController.userId.value,
              amount: amount,
              type: TransactionType.debit);
          await transactionService.newTransaction(
              title: "Received ${formatAmount(amount)} from $me",
              userId: user.id!,
              amount: amount,
              type: TransactionType.credit);
          return true;
        } else {
          toast("Invalid user");
          return false;
        }
      } else {
        toast("insufficient balance");
        return false;
      }
    } catch (er) {
      print(er);

      toast(er.toString());
      return false;
    }
  }
}
