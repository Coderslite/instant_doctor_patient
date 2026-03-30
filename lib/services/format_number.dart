import 'package:instant_doctor/services/GetUserId.dart';
import 'package:intl/intl.dart';

String formatAmount(int amount) {
  String formattedAmount = NumberFormat.decimalPattern().format(amount);
  final symbol =
      userController.currency.value.toLowerCase() == 'ngn' ? '₦' : '\$';
  return "$symbol$formattedAmount";
}

String formatAmountWithoutCurrency(int amount) {
  // Use NumberFormat to format the amount with thousand separators
  String formattedAmount = NumberFormat.decimalPattern().format(amount);
  return formattedAmount;
}
