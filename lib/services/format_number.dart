import 'package:intl/intl.dart';

String formatAmount(int amount) {
  // Use NumberFormat to format the amount with thousand separators
  return NumberFormat.currency(symbol: '').format(amount);
}
