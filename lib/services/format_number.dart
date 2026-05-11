import 'package:instant_doctor/services/GetUserId.dart';
import 'package:instant_doctor/services/IAPService.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

String formatAmount(int amount) {
  final iapService = Get.find<IAPService>();
  String formattedAmount = NumberFormat.decimalPattern().format(amount);
  final symbol = iapService.currentCurrency.toLowerCase() == 'ngn'
      ? '₦'
      : iapService.currentCurrency;
  return "$symbol$formattedAmount";
}

String formatAmountWithoutCurrency(int amount) {
  // Use NumberFormat to format the amount with thousand separators
  String formattedAmount = NumberFormat.decimalPattern().format(amount);
  return formattedAmount;
}
