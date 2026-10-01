// ignore_for_file: file_names
// IAPService has been refactored — in_app_purchase removed.
// This service now only provides local product metadata (name, duration, icon)
// for NON-appointment products (e.g. lab results).
// Appointment packages are now fetched dynamically from Firestore (AppointmentPricing).
// Currency + pricing is fully handled by PricingService.
// Payments are handled by StripeService and FlutterwaveService.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/services/PricingService.dart';

class IAPService extends GetxService {
  // Delegate currency to PricingService (single source of truth)
  String get currentCurrency => Get.find<PricingService>().userCurrency.value;

  // ── Package Metadata ─────────────────────────────────────────────────────
  // Only non-appointment product metadata is kept here.
  // Appointment packages (basic, standard, special) are now dynamic from Firebase.
  final Map<String, Map<String, dynamic>> productMetadata = {
    'lab_result_standard': {
      'name': 'Lab Interpretation',
      'duration': 0,
      'desc': 'Professional analysis of your medical laboratory results',
      'icon': Icons.biotech_rounded,
    },
  };

  Map<String, dynamic>? getMetadata(String productId) =>
      productMetadata[productId];
}
