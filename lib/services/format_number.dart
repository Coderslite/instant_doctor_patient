import 'package:instant_doctor/services/PricingService.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

String formatAmount(int amount) {
  final pricingService = Get.find<PricingService>();
  String formattedAmount = NumberFormat.decimalPattern().format(amount);
  final currency = pricingService.userCurrency.value;
  final symbol = currency.toLowerCase() == 'ngn'
      ? '₦'
      : currency.toLowerCase() == 'ghs'
          ? '₵'
          : currency.toLowerCase() == 'gbp'
              ? '£'
              : currency.toLowerCase() == 'eur'
                  ? '€'
                  : currency.toLowerCase() == 'inr'
                      ? '₹'
                      : currency.toLowerCase() == 'jpy' ||
                              currency.toLowerCase() == 'cny'
                          ? '¥'
                          : '$currency ';
  return "$symbol$formattedAmount";
}

String formatAmountWithoutCurrency(int amount) {
  String formattedAmount = NumberFormat.decimalPattern().format(amount);
  return formattedAmount;
}
