import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
// IAP removed as per user request
import 'package:instant_doctor/constant/PaymentConfig.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/constant/constants.dart';
import 'package:instant_doctor/controllers/BookingController.dart';
import 'package:instant_doctor/controllers/LabResultController.dart';
import 'package:instant_doctor/controllers/OrderController.dart';
import 'package:instant_doctor/controllers/PaymentController.dart';
import 'package:instant_doctor/controllers/UserController.dart';
import 'package:instant_doctor/models/AppointmentModel.dart';
import 'package:instant_doctor/services/GetUserId.dart';
import 'package:instant_doctor/services/IAPService.dart';
import 'package:instant_doctor/services/PricingService.dart';
import 'package:instant_doctor/services/UserService.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pay/pay.dart';

import '../component/PremiumButton.dart';

handleShowPaymentOption(BuildContext context,
    {required AppointmentModel appointment}) async {
  final bookingController = Get.find<BookingController>();
  final paymentController = Get.find<PaymentController>();
  final iapService = Get.find<IAPService>();
  final pricingService = Get.find<PricingService>();

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) {
      return Container(
        decoration: const BoxDecoration(
          color: pageGray,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Premium Header ───────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              decoration: const BoxDecoration(
                color: obsidian,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.account_balance_wallet_rounded,
                            color: white, size: 20),
                      ),
                      const SizedBox(width: 16),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Choose Payment',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            'Select your preferred method',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: const Icon(Icons.close_rounded, color: white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Obx(() {
              if (paymentController.isLoading.value) {
                return const SizedBox(
                  height: 100,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Processing Payment...',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                child: Column(
                  children: [
                    // 1. Native One-Tap Payments (Global)
                    if (Platform.isIOS)
                      Builder(builder: (builderContext) {
                        final String displayAmount = pricingService
                            .getFinalPrice(appointment.package.validate())
                            .toStringAsFixed(2);
                        final String displayCurrency =
                            pricingService.userCurrency.value;

                        // Dynamically update the config JSON with the correct currency and country
                        String dynamicAppleConfig = defaultApplePayConfigString
                            .replaceAll('"USD"', '"$displayCurrency"');

                        // if (displayCurrency == 'NGN') {
                        //   dynamicAppleConfig = dynamicAppleConfig.replaceAll('"US"', '"NG"');
                        // }

                        return ApplePayButton(
                          buttonProvider: PayProvider.apple_pay,
                          paymentConfiguration:
                              PaymentConfiguration.fromJsonString(
                                  dynamicAppleConfig),
                          paymentItems: [
                            PaymentItem(
                              label: 'Medical Consultation',
                              amount: displayAmount,
                              status: PaymentItemStatus.final_price,
                            )
                          ],
                          style: ApplePayButtonStyle.whiteOutline,
                          width: double.infinity,
                          height: 56,
                          type: ApplePayButtonType.buy,
                          margin: const EdgeInsets.only(bottom: 16),
                          onPaymentResult: (result) async {
                            log("Payment Result from apple: $result");
                            // Don't pop yet, let the loader show in this sheet
                            await paymentController.chargeNativePayment(
                              context: context,
                              amount: (double.parse(displayAmount)).toInt(),
                              currency: displayCurrency,
                              paymentFor: PaymentFor.appointment,
                              productId: appointment.id,
                              paymentToken: result,
                            );
                            // Only pop after successful chargeNativePayment or handle inside chargeNativePayment
                          },
                          loadingIndicator:
                              const Center(child: CircularProgressIndicator()),
                          onError: (error) {
                            print("🍎 APPLE PAY DIAGNOSTIC: $error");
                          },
                        );
                      })
                    else if (Platform.isAndroid)
                      Builder(builder: (builderContext) {
                        final String productId = appointment.package.validate();
                        final String displayPrice = iapService.getProductPrice(productId);
                        final double rawPrice = iapService.getProductRawPrice(productId);

                        return PremiumButton(
                          onTap: () async {
                            await paymentController.makeInAppPurchase(
                              context: context,
                              productId: productId,
                              paymentFor: PaymentFor.appointment,
                              amount: rawPrice.toInt(),
                              currency: pricingService.userCurrency.value,
                              isTrial: false,
                            );
                          },
                          text: "Pay $displayPrice with Google Play",
                        );
                      }),

                    const SizedBox(height: 8),
 
                    // Regional Option (Backup for Africa)
                    if (pricingService.isAfrican())
                      _PaymentOptionCard(
                        title: 'Local Card Payment',
                        subtitle: 'Pay via Flutterwave/Card',
                        imagePath: 'assets/images/flutterwave.png',
                        onTap: () async {
                          Navigator.pop(sheetContext);
                          final userInfo = await Get.find<UserService>()
                              .getProfileById(
                                  userId: userController.userId.value);
                          final String productId = appointment.package.validate();
                          final double amount = Platform.isAndroid 
                              ? iapService.getProductRawPrice(productId)
                              : pricingService.getFinalPrice(productId);

                          paymentController.makeFlutterwavePayment(
                            email: userInfo.email.validate(),
                            context: context,
                            amount: amount.toInt(),
                            currency: pricingService.userCurrency.value,
                            paymentFor: PaymentFor.appointment,
                            productId: appointment.id,
                          );
                        },
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
      );
    },
  );
}

class _PaymentOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData? icon;
  final String? imagePath;
  final Color? color;
  final VoidCallback onTap;

  const _PaymentOptionCard({
    required this.title,
    required this.subtitle,
    this.icon,
    this.imagePath,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: border),
          boxShadow: [
            BoxShadow(
              color: obsidian.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: (color ?? kPrimary).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: imagePath != null
                  ? Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Image.asset(imagePath!, fit: BoxFit.contain),
                    )
                  : Icon(icon, color: color ?? kPrimary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: boldTextStyle(size: 15, color: ink)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: secondaryTextStyle(size: 11, color: slate)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: border, size: 24),
          ],
        ),
      ),
    );
  }
}

handleShowPaymentOptionBook(BuildContext context) async {
  // This method seems redundant if it calls handleBookAppointment which then calls handleShowPaymentOption
  // But I'll keep it updated just in case it's used directly
  final bookingController = Get.find<BookingController>();
  final iapService = Get.find<IAPService>();
  showModalBottomSheet(
      context: context,
      backgroundColor: context.scaffoldBackgroundColor,
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (supportedAfricanCurrencies
                  .contains(iapService.currentCurrency))
                PremiumButton(
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    try {
                      bookingController.isLoading.value = true;
                      await bookingController.handleBookAppointment(
                          isTrial: false,
                          doctorId: '',
                          isPaystack: false,
                          context: context);
                    } finally {
                      bookingController.isLoading.value = false;
                    }
                  },
                  text: "Flutterwave",
                ),
            ],
          ),
        );
      });
}

handleShowPaymentOptionLab(BuildContext context,
    {required int amount, required String email}) async {
  final paymentController = Get.find<PaymentController>();
  final labResultController = Get.find<LabResultController>();
  final iapService = Get.find<IAPService>();
  final pricingService = Get.find<PricingService>();

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) {
      return Container(
        decoration: const BoxDecoration(
          color: pageGray,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Premium Header ───────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              decoration: const BoxDecoration(
                color: obsidian,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Lab Results Analysis',
                                style: boldTextStyle(size: 20, color: white)),
                            const SizedBox(height: 4),
                            Text('Get your results interpreted by a doctor',
                                style: secondaryTextStyle(
                                    color: white.withOpacity(0.5), size: 12)),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(sheetContext),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child:
                              const Icon(Icons.close, color: white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // ── Payment Options ──────────────────────────────────────────────
            Obx(() {
              if (paymentController.isLoading.value) {
                return const SizedBox(
                  height: 100,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Processing Results...',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // 1. Native One-Tap Payments (Global)
                    if (Platform.isIOS)
                      Builder(builder: (builderContext) {
                        // Use base price (USD) and apply 50% African discount manually
                        double priceInUSD =
                            pricingService.basePrices['lab_result_standard'] ??
                                5.0;
                        if (pricingService.isAfrican()) priceInUSD *= 0.5;
                        final String displayAmount =
                            priceInUSD.toStringAsFixed(2);

                        // Forcing USD for maximum compatibility on real devices
                        String dynamicAppleConfig = defaultApplePayConfigString;

                        return ApplePayButton(
                          paymentConfiguration:
                              PaymentConfiguration.fromJsonString(
                                  dynamicAppleConfig),
                          paymentItems: [
                            PaymentItem(
                              label: 'Lab Result Interpretation',
                              amount: displayAmount,
                              status: PaymentItemStatus.final_price,
                            )
                          ],
                          style: ApplePayButtonStyle.whiteOutline,
                          width: double.infinity,
                          height: 56,
                          type: ApplePayButtonType.buy,
                          margin: const EdgeInsets.only(bottom: 16),
                          onPaymentResult: (result) async {
                            await paymentController.chargeNativePayment(
                              context: context,
                              amount: (priceInUSD * 100).toInt(), // Cents
                              currency: 'USD',
                              paymentFor: PaymentFor.labResult,
                              paymentToken: result,
                            );
                          },
                          loadingIndicator:
                              const Center(child: CircularProgressIndicator()),
                        );
                      })
                    else if (Platform.isAndroid)
                      Builder(builder: (builderContext) {
                        const String productId = 'lab_result_standard';
                        final String displayPrice = iapService.getProductPrice(productId);
                        final double rawPrice = iapService.getProductRawPrice(productId);

                        return PremiumButton(
                          onTap: () async {
                            await paymentController.makeInAppPurchase(
                              context: context,
                              productId: productId,
                              paymentFor: PaymentFor.labResult,
                              amount: rawPrice.toInt(),
                              currency: pricingService.userCurrency.value,
                            );
                          },
                          text: "Pay $displayPrice with Google Play",
                        );
                      }),

                    const SizedBox(height: 8),

                    // Regional Option (Backup for Africa)
                    if (pricingService.isAfrican())
                      _PaymentOptionCard(
                        title: 'Local Card Payment',
                        subtitle: 'Pay via Flutterwave/Card',
                        imagePath: 'assets/images/flutterwave.png',
                        onTap: () async {
                          Navigator.pop(sheetContext);
                          final userInfo = await Get.find<UserService>()
                              .getProfileById(
                                  userId: userController.userId.value);
                          const String productId = 'lab_result_standard';
                          final double amount = Platform.isAndroid 
                              ? iapService.getProductRawPrice(productId)
                              : pricingService.getFinalPrice(productId);

                          paymentController.makeFlutterwavePayment(
                            email: userInfo.email.validate(),
                            context: context,
                            amount: amount.toInt(),
                            currency: pricingService.userCurrency.value,
                            paymentFor: PaymentFor.labResult,
                            productId: 'lab_result_standard',
                          );
                        },
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
      );
    },
  );
}

handleShowPaymentOptionOrder(BuildContext context,
    {required int amount}) async {
  // ignore: unused_local_variable
  final orderController = Get.find<OrderController>();
  final paymentController = Get.find<PaymentController>();
  final iapService = Get.find<IAPService>();
  final pricingService = Get.find<PricingService>();
  final userService = Get.find<UserService>();
  final userController = Get.find<UserController>();

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) {
      return Container(
        decoration: const BoxDecoration(
          color: pageGray,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Premium Header ───────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              decoration: const BoxDecoration(
                color: obsidian,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Checkout',
                                style: boldTextStyle(size: 20, color: white)),
                            const SizedBox(height: 4),
                            Text('Secure payment for your medications',
                                style: secondaryTextStyle(
                                    color: white.withOpacity(0.5), size: 12)),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(sheetContext),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child:
                              const Icon(Icons.close, color: white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Payment Options ──────────────────────────────────────────────
            Obx(() {
              if (paymentController.isLoading.value) {
                return const SizedBox(
                  height: 100,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Processing Order...',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Native Pay (Global)
                    if (Platform.isIOS)
                      Builder(builder: (builderContext) {
                        // Convert local amount back to USD for native pay sheet
                        double priceInUSD =
                            amount / pricingService.exchangeRate.value;
                        final String displayAmount =
                            priceInUSD.toStringAsFixed(2);

                        // Forcing USD for maximum compatibility on real devices
                        String dynamicAppleConfig = defaultApplePayConfigString;

                        return SizedBox(
                          width: double.infinity,
                          child: ApplePayButton(
                            paymentConfiguration:
                                PaymentConfiguration.fromJsonString(
                                    dynamicAppleConfig),
                            paymentItems: [
                              PaymentItem(
                                label: 'Medication Order',
                                amount: displayAmount,
                                status: PaymentItemStatus.final_price,
                              )
                            ],
                            style: ApplePayButtonStyle.whiteOutline,
                            width: double.infinity,
                            height: 56,
                            type: ApplePayButtonType.buy,
                            margin: const EdgeInsets.only(bottom: 16),
                            onPaymentResult: (result) async {
                              await paymentController.chargeNativePayment(
                                context: context,
                                amount:
                                    (priceInUSD * 100).toInt(), // Cents for USD
                                currency: 'USD',
                                paymentFor: PaymentFor.order,
                                paymentToken: result,
                              );
                            },
                            loadingIndicator: const Center(
                                child: CircularProgressIndicator()),
                          ),
                        );
                      })
                    else if (Platform.isAndroid)
                      Builder(builder: (builderContext) {
                        final String displayAmount =
                            amount.toDouble().toStringAsFixed(2);
                        final String displayCurrency =
                            pricingService.userCurrency.value;

                        final String dynamicGoogleConfig =
                            defaultGooglePayConfigString.replaceAll(
                                '"USD"', '"$displayCurrency"');

                        return SizedBox(
                          width: double.infinity,
                          child: GooglePayButton(
                            paymentConfiguration:
                                PaymentConfiguration.fromJsonString(
                                    dynamicGoogleConfig),
                            paymentItems: [
                              PaymentItem(
                                label: 'Medication Order',
                                amount: displayAmount,
                                status: PaymentItemStatus.final_price,
                              )
                            ],
                            type: GooglePayButtonType.buy,
                            margin: const EdgeInsets.only(bottom: 16),
                            onPaymentResult: (result) async {
                              await paymentController.makeNativePayPayment(
                                context: context,
                                amount: amount,
                                paymentFor: PaymentFor.order,
                                currency: displayCurrency,
                              );
                            },
                            loadingIndicator: const Center(
                                child: CircularProgressIndicator()),
                          ),
                        );
                      }),

                    const SizedBox(height: 12),

                    // Regional Option (Backup for Africa)
                    if (supportedAfricanCurrencies
                        .contains(iapService.currentCurrency))
                      _PaymentOptionCard(
                        title: 'Local Card Payment',
                        subtitle: 'Pay via Flutterwave/Card',
                        imagePath: 'assets/images/flutterwave.png',
                        onTap: () async {
                          Navigator.pop(sheetContext);
                          var user = await userService.getProfileById(
                              userId: userController.userId.value);
                          await paymentController.makeFlutterwavePayment(
                            email: user.email.validate(),
                            context: context,
                            amount: amount,
                            paymentFor: PaymentFor.order,
                          );
                        },
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
      );
    },
  );
}
