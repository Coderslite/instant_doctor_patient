import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:nb_utils/nb_utils.dart';
import '../main.dart';

class PricingService extends GetxService {
  // ── Base Prices (USD) - Fetched from Firestore ────────────────────────
  final RxMap<String, double> basePrices = <String, double>{}.obs;

  // ── State ────────────────────────────────────────────────────────────────
  RxString userCountry = 'US'.obs;
  RxString userCurrency = 'USD'.obs;
  RxDouble exchangeRate = 1.0.obs;
  RxBool isLoading = false.obs;

  // List of African country codes for the 50% discount
  final List<String> africanCountries = [
    'DZ', 'AO', 'BJ', 'BW', 'BF', 'BI', 'CV', 'CM', 'CF', 'TD', 'KM', 'CD',
    'CG', 'DJ', 'EG', 'GQ', 'ER', 'SZ', 'ET', 'GA', 'GM', 'GH', 'GN', 'GW',
    'CI', 'KE', 'LS', 'LR', 'LY', 'MG', 'MW', 'ML', 'MR', 'MU', 'MA', 'MZ',
    'NA', 'NE', 'NG', 'RW', 'ST', 'SN', 'SC', 'SL', 'SO', 'ZA', 'SS', 'SD',
    'TZ', 'TG', 'TN', 'UG', 'ZM', 'ZW'
  ];

  @override
  void onInit() {
    super.onInit();
    initPricing();
    _listenToFirestorePrices();
  }

  void _listenToFirestorePrices() {
    db.collection('AppConfig').doc('Prices').snapshots().listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null) {
          data.forEach((key, value) {
            basePrices[key] = (value as num).toDouble();
          });
          print("🔥 Firestore Prices Updated: $basePrices");
        }
      }
    }, onError: (e) {
      log('Firestore Pricing Error: $e');
    });
  }

  Future<void> initPricing() async {
    isLoading.value = true;
    try {
      // 1. Detect Country Automatically (Multiple Sources)
      try {
        final locationResponse =
            await http.get(Uri.parse('https://ipapi.co/json/'))
                .timeout(const Duration(seconds: 5));
        if (locationResponse.statusCode == 200) {
          final locData = json.decode(locationResponse.body);
          // Try 'country' or 'country_code'
          userCountry.value = locData['country'] ?? locData['country_code'] ?? 'US';
          print("🌍 Source 1 (IPAPI) Detected: ${userCountry.value}");
        } else {
          // Try Source 2: ip-api.com
          final locResp2 = await http.get(Uri.parse('http://ip-api.com/json'))
              .timeout(const Duration(seconds: 5));
          if (locResp2.statusCode == 200) {
            final locData2 = json.decode(locResp2.body);
            userCountry.value = locData2['countryCode'] ?? 'US';
            print("🌍 Source 2 (IP-API) Detected: ${userCountry.value}");
          } else {
            throw Exception("IP Lookups failed");
          }
        }
      } catch (e) {
        // Fallback 3: Device Locale
        userCountry.value = Get.deviceLocale?.countryCode ?? 'US';
        print("🌍 Source 3 (Locale) Fallback: ${userCountry.value}");
      }

      // 2. Map Currency
      userCurrency.value = _getCurrencyFromCountry(userCountry.value);
      print("💰 Initial Currency Mapped: ${userCurrency.value}");

      // 3. Fetch Exchange Rate (Free API: open.er-api.com)
      final response =
          await http.get(Uri.parse('https://open.er-api.com/v6/latest/USD'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rates = data['rates'] as Map<String, dynamic>;

        // Determine currency from country (Simplified mapping)
        userCurrency.value = _getCurrencyFromCountry(userCountry.value);
        exchangeRate.value = (rates[userCurrency.value] ?? 1.0).toDouble();
        print(
            "💰 Currency: ${userCurrency.value} | Rate: ${exchangeRate.value}");
      }
    } catch (e) {
      log('Pricing Init Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  String _getCurrencyFromCountry(String countryCode) {
    Map<String, String> mapping = {
      // Africa
      'NG': 'NGN', 'GH': 'GHS', 'KE': 'KES', 'ZA': 'ZAR', 'TZ': 'TZS',
      'UG': 'UGX', 'RW': 'RWF', 'EG': 'EGP',
      // Europe
      'GB': 'GBP', 'DE': 'EUR', 'FR': 'EUR', 'IT': 'EUR', 'ES': 'EUR',
      'NL': 'EUR', 'IE': 'EUR', 'CH': 'CHF',
      // Americas
      'US': 'USD', 'CA': 'CAD', 'BR': 'BRL', 'MX': 'MXN',
      // Asia/Oceania
      'JP': 'JPY', 'CN': 'CNY', 'IN': 'INR', 'AU': 'AUD', 'NZ': 'NZD',
      'SG': 'SGD', 'MY': 'MYR', 'KR': 'KRW',
      // Middle East
      'AE': 'AED', 'SA': 'SAR', 'QA': 'QAR', 'TR': 'TRY'
    };
    return mapping[countryCode] ?? 'USD';
  }

  // ── Price Calculation Logic ──────────────────────────────────────────────

  /// Calculates the final price for a specific product ID
  /// Applies African discount (50%) and current exchange rate
  double getFinalPrice(String productId) {
    double price = basePrices[productId] ?? 0.0;

    // Apply 50% discount for African countries
    if (africanCountries.contains(userCountry.value)) {
      price = price * 0.5;
    }

    // Apply exchange rate
    return price * exchangeRate.value;
  }

  String getFormattedPrice(String productId) {
    final price = getFinalPrice(productId);
    // Formatting based on currency
    if (userCurrency.value == 'NGN') return '₦${price.toStringAsFixed(0)}';
    if (userCurrency.value == 'GHS') return '₵${price.toStringAsFixed(2)}';
    if (userCurrency.value == 'JPY') return '¥${price.toStringAsFixed(0)}';
    if (userCurrency.value == 'EUR') return '€${price.toStringAsFixed(2)}';
    if (userCurrency.value == 'GBP') return '£${price.toStringAsFixed(2)}';
    if (userCurrency.value == 'INR') return '₹${price.toStringAsFixed(0)}';
    if (userCurrency.value == 'CNY') return '¥${price.toStringAsFixed(2)}';
    return '${userCurrency.value} ${price.toStringAsFixed(2)}';
  }

  bool isAfrican() => africanCountries.contains(userCountry.value);
}
