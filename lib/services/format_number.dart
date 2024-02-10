import 'package:intl/intl.dart';

String formatAmount(int amount) {
  // Use NumberFormat to format the amount with thousand separators
  String formattedAmount = NumberFormat.decimalPattern().format(amount);
  return "NGN" + formattedAmount;
}
