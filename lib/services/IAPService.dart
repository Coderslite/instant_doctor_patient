import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:nb_utils/nb_utils.dart';

class IAPService extends GetxService {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  // Callback when purchase is successful
  Function(PurchaseDetails)? onPurchaseSuccess;
  // Callback when purchase fails or is cancelled
  Function? onPurchaseError;

  RxBool isAvailable = false.obs;
  RxList<ProductDetails> products = <ProductDetails>[].obs;
  RxList<PurchaseDetails> purchases = <PurchaseDetails>[].obs;
  RxString storeCurrency = 'USD'.obs;

  String get currentCurrency => storeCurrency.value;

  @override
  void onInit() {
    super.onInit();
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;
    _subscription =
        purchaseUpdated.listen((List<PurchaseDetails> purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (Object error) {
      log("🍎 IAP Error: $error");
    });
    initStoreInfo();
  }

  Future<void> initStoreInfo() async {
    final bool isAvailableResult = await _inAppPurchase.isAvailable();
    print("🍎 IAP Store Available: $isAvailableResult");
    isAvailable.value = isAvailableResult;
    if (isAvailableResult) {
      // Auto-load default products
      await loadProducts([
        'appointment_basic',
        'appointment_standard',
        'appointment_special',
        'lab_result_standard'
      ]);
    }
  }

  Future<void> loadProducts(List<String> productIds) async {
    final ProductDetailsResponse response =
        await _inAppPurchase.queryProductDetails(productIds.toSet());
    if (response.error == null) {
      products.value = response.productDetails;
      print("🍎 IAP Products Loaded: ${products.length}");
      for (var p in products) {
        print("🍎 IAP Product: ${p.id} | Price: ${p.price}");
      }
      if (products.isNotEmpty) {
        storeCurrency.value = products.first.currencyCode;
      }
    }
  }

  String getProductPrice(String productId) {
    final product = products.firstWhereOrNull((p) => p.id == productId);
    return product?.price ?? "---";
  }

  double getProductRawPrice(String productId) {
    final product = products.firstWhereOrNull((p) => p.id == productId);
    return product?.rawPrice ?? 0.0;
  }

  Future<void> buyProduct(String productId) async {
    final product = products.firstWhereOrNull((p) => p.id == productId);
    if (product != null) {
      final PurchaseParam purchaseParam =
          PurchaseParam(productDetails: product);
      await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
    } else {
      log("🍎 Product $productId not found in store");
      toast("Product not found in Store");
    }
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Show loading if needed
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          log("🍎 Purchase Error: ${purchaseDetails.error}");
          onPurchaseError?.call();
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          onPurchaseSuccess?.call(purchaseDetails);
        }
        if (purchaseDetails.pendingCompletePurchase) {
          _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }
  }

  @override
  void onClose() {
    _subscription.cancel();
    super.onClose();
  }

  final Map<String, Map<String, dynamic>> productMetadata = {
    'appointment_basic': {
      'name': 'Basic',
      'duration': 30 * 60, // 30 minutes
      'desc': 'Standard consultation for quick check-ups',
      'icon': Icons.chat_bubble_outline_rounded,
    },
    'appointment_standard': {
      'name': 'Standard',
      'duration': 60 * 60, // 1 hour
      'desc': 'Detailed discussion and symptom review',
      'icon': Icons.video_call_rounded,
    },
    'appointment_special': {
      'name': 'Special',
      'duration': 90 * 60, // 1.5 hours
      'desc': 'Extended care for complex health concerns',
      'icon': Icons.health_and_safety_rounded,
    },
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
