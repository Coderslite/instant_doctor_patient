import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/services/PricingService.dart';
import 'package:instant_doctor/services/IAPService.dart';
import 'package:instant_doctor/services/formatDuration.dart';
import 'package:nb_utils/nb_utils.dart';

class PackageSelection extends StatelessWidget {
  final dynamic selectedProduct; // Changed to dynamic to handle both IAP and custom products
  final Function(dynamic) onSelected;

  const PackageSelection({
    super.key,
    required this.selectedProduct,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final pricingService = Get.find<PricingService>();
    final iapService = Get.find<IAPService>();

    return Obx(() {
      if (pricingService.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      // We use the product IDs defined in PricingService
      final packageIds = ['appointment_basic', 'appointment_standard', 'appointment_special'];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Consultation Packages',
            style: boldTextStyle(size: 22, color: ink, letterSpacing: -0.5),
          ),
          8.height,
          Text(
            'Select a consultation package that fits your needs. Prices are adjusted for your region.',
            style: secondaryTextStyle(size: 13, color: slate, height: 1.4),
          ),
          24.height,
          ...packageIds.map((id) {
            final metadata = iapService.getMetadata(id);
            final isSelected = (selectedProduct is String) 
                ? selectedProduct == id 
                : (selectedProduct?.id == id);
            
            final String displayPrice = Platform.isAndroid
                ? iapService.getProductPrice(id)
                : pricingService.getFormattedPrice(id);

            return GestureDetector(
              onTap: () => onSelected(id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isSelected ? kPrimary.withOpacity(0.05) : white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected ? kPrimary : border,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: kPrimary.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    else
                      BoxShadow(
                        color: obsidian.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color:
                            isSelected ? kPrimary.withOpacity(0.1) : pageGray,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        metadata?['icon'] ?? Icons.medical_services_rounded,
                        color: kPrimary,
                        size: 28,
                      ),
                    ),
                    20.width,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            metadata?['name'] ?? id.split('_').last.capitalizeFirstLetter(),
                            style: boldTextStyle(size: 16, color: ink),
                          ),
                          4.height,
                          Text(
                            metadata?['desc'] ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: secondaryTextStyle(
                                size: 12, color: slate, height: 1.3),
                          ),
                          12.height,
                          Row(
                            children: [
                              const Icon(Icons.timer_outlined,
                                  size: 14, color: kPrimary),
                              6.width,
                              Text(
                                formatDuration(Duration(
                                    seconds: metadata?['duration'] ?? 0)),
                                style: boldTextStyle(size: 11, color: kPrimary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    12.width,
                    Text(
                      displayPrice,
                      style: boldTextStyle(size: 18, color: green),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      );
    });
  }
}
