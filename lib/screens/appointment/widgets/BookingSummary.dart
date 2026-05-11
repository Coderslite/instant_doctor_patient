import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/services/PricingService.dart';
import 'package:instant_doctor/services/IAPService.dart';
import 'package:nb_utils/nb_utils.dart';

class BookingSummary extends StatelessWidget {
  final String selectedProduct; // Changed from ProductDetails
  final DateTime selectedDate;
  final String selectedTime;
  final Set<String> symptoms;
  final String complaint;

  const BookingSummary({
    super.key,
    required this.selectedProduct,
    required this.selectedDate,
    required this.selectedTime,
    required this.symptoms,
    required this.complaint,
  });

  @override
  Widget build(BuildContext context) {
    final pricingService = Get.find<PricingService>();
    final iapService = Get.find<IAPService>();
    final metadata = iapService.getMetadata(selectedProduct);
    final String displayPrice = Platform.isAndroid
        ? iapService.getProductPrice(selectedProduct)
        : pricingService.getFormattedPrice(selectedProduct);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Booking Review',
          style: boldTextStyle(size: 22, color: ink, letterSpacing: -0.5),
        ),
        8.height,
        Text(
          'Please review your appointment details before proceeding to payment.',
          style: secondaryTextStyle(size: 13, color: slate, height: 1.4),
        ),
        24.height,

        // Package Card
        _ReviewCard(
          title: 'Consultation Package',
          icon: Icons.medical_services_rounded,
          iconColor: kPrimary,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  metadata?['name'] ?? selectedProduct.split('_').last.capitalizeFirstLetter(),
                  style: boldTextStyle(size: 16, color: ink),
                ),
              ),
              Text(
                displayPrice,
                style: boldTextStyle(size: 18, color: green),
              ),
            ],
          ),
        ),
        16.height,

        // Schedule Card
        _ReviewCard(
          title: 'Schedule',
          icon: Icons.calendar_today_rounded,
          iconColor: amber,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${selectedDate.day} ${_getMonth(selectedDate.month)} ${selectedDate.year}',
                style: boldTextStyle(size: 15, color: ink),
              ),
              4.height,
              Text(
                selectedTime,
                style: secondaryTextStyle(color: slate, size: 13),
              ),
            ],
          ),
        ),
        16.height,

        // Health Concerns Card (omitted for brevity in this replace call, but keeping logic)
        if (symptoms.isNotEmpty || complaint.isNotEmpty)
          _ReviewCard(
            title: 'Health Concerns',
            icon: Icons.health_and_safety_rounded,
            iconColor: green,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (symptoms.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: symptoms
                        .map((s) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: kPrimary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(s,
                                  style: boldTextStyle(size: 11, color: kPrimary)),
                            ))
                        .toList(),
                  ),
                if (symptoms.isNotEmpty && complaint.isNotEmpty) 12.height,
                if (complaint.isNotEmpty)
                  Text(
                    complaint,
                    style: secondaryTextStyle(color: slate, size: 13, height: 1.4),
                  ),
              ],
            ),
          ),

        32.height,

        // Total Amount Display
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: obsidian,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: obsidian.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Amount',
                      style: secondaryTextStyle(color: white.withOpacity(0.5), size: 12)),
                  const SizedBox(height: 4),
                  const Text('Secured Payment',
                      style: TextStyle(
                          color: white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600)),
                ],
              ),
              Text(
                displayPrice,
                style: boldTextStyle(color: white, size: 24, letterSpacing: -0.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getMonth(int month) {
    return [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ][month - 1];
  }
}

class _ReviewCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;

  const _ReviewCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: obsidian.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 14, color: iconColor),
              ),
              10.width,
              Text(
                title,
                style: boldTextStyle(size: 13, color: slate),
              ),
            ],
          ),
          16.height,
          child,
        ],
      ),
    );
  }
}
