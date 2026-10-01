// ignore_for_file: file_names
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:instant_doctor/constant/constants.dart';
import 'package:nb_utils/nb_utils.dart';

class StripeService extends GetxService {
  @override
  void onInit() {
    super.onInit();
    _initStripe();
  }

  void _initStripe() {
    final publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
    if (publishableKey.isEmpty || publishableKey.contains('REPLACE')) {
      log('⚠️ Stripe: STRIPE_PUBLISHABLE_KEY not set in .env');
      return;
    }
    Stripe.publishableKey = publishableKey;
    Stripe.merchantIdentifier = 'merchant.com.instantdoctor';
    log('✅ Stripe initialized');
  }

  /// Creates a PaymentIntent on the backend and presents the Stripe payment sheet.
  ///
  /// [amountInMinorUnits] — amount in the **smallest currency unit**
  ///   e.g. 999 = $9.99 USD, 999 = £9.99 GBP, 50000 = ₦50,000 NGN (zero-decimal for some)
  /// [currency] — ISO 4217 currency code, e.g. "usd", "gbp", "eur"
  ///
  /// Returns `true` on success, `false` on failure/cancellation.
  Future<bool> makeStripePayment({
    required BuildContext context,
    required int amountInMinorUnits,
    required String currency,
    String? customerEmail,
    String? description,
  }) async {
    try {
      // 1. Create PaymentIntent on the backend
      final clientSecret = await _createPaymentIntent(
        amount: amountInMinorUnits,
        currency: currency.toLowerCase(),
        customerEmail: customerEmail,
        description: description,
      );

      if (clientSecret == null) {
        toast('Payment setup failed. Please try again.');
        return false;
      }

      // 2. Initialize the payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Instant Doctor',
          billingDetailsCollectionConfiguration:
              const BillingDetailsCollectionConfiguration(
            email: CollectionMode.automatic,
          ),
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Color(0xFF00AEEF),
            ),
            shapes: PaymentSheetShape(
              borderRadius: 16,
            ),
          ),
        ),
      );

      // 3. Present the payment sheet to the user
      await Stripe.instance.presentPaymentSheet();

      // If we reach here, payment was successful
      log('✅ Stripe payment successful');
      return true;
    } on StripeException catch (e) {
      final code = e.error.code;
      if (code == FailureCode.Canceled) {
        log('ℹ️ Stripe: User cancelled payment');
        return false;
      }
      log('❌ Stripe error: ${e.error.message}');
      toast(e.error.message ?? 'Payment failed');
      return false;
    } catch (e) {
      log('❌ Stripe unexpected error: $e');
      toast('An unexpected error occurred');
      return false;
    }
  }

  /// Calls the Firebase backend to create a Stripe PaymentIntent.
  /// Returns the `client_secret` string, or null on failure.
  Future<String?> _createPaymentIntent({
    required int amount,
    required String currency,
    String? customerEmail,
    String? description,
  }) async {
    try {
      final url = Uri.parse('$FIREBASE_URL/payment/stripe-payment-intent');
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'amount': amount,
              'currency': currency,
              if (customerEmail != null) 'email': customerEmail,
              if (description != null) 'description': description,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['clientSecret'] as String?;
      } else {
        log('❌ Stripe backend error: ${response.statusCode} — ${response.body}');
        return null;
      }
    } catch (e) {
      log('❌ Stripe backend call failed: $e');
      return null;
    }
  }

  /// Converts a [double] price in major currency unit (e.g. 9.99)
  /// to the smallest unit (e.g. 999 for USD/GBP/EUR, 350000 for 3500 NGN) or keeps as-is for
  /// zero-decimal currencies (JPY, KRW, UGX, etc.).
  static int toMinorUnits(double amount, String currency) {
    const zeroDecimal = [
      'bif',
      'clp',
      'djf',
      'gnf',
      'jpy',
      'kmf',
      'krw',
      'mga',
      'pyg',
      'rwf',
      'ugx',
      'vnd',
      'vuv',
      'xaf',
      'xof',
      'xpf',
    ];
    if (zeroDecimal.contains(currency.toLowerCase())) {
      return amount.round();
    }
    return (amount * 100).round();
  }
}
