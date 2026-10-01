import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/services/PricingService.dart';
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

  /// Maps package index to an icon for visual variety
  IconData _iconForIndex(int index) {
    const icons = [
      Icons.chat_bubble_outline_rounded,
      Icons.video_call_rounded,
      Icons.health_and_safety_rounded,
      Icons.medical_services_rounded,
      Icons.local_hospital_rounded,
      Icons.healing_rounded,
    ];
    return icons[index % icons.length];
  }

  Widget _buildFeatureItem(String text, IconData icon, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: secondaryTextStyle(size: 13, color: slate, weight: FontWeight.w500),
            ),
          ),
          Icon(Icons.check_circle_rounded, size: 16, color: green),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pricingService = Get.find<PricingService>();

    return Obx(() {
      if (pricingService.isLoading.value && pricingService.appointmentPackages.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      final packages = pricingService.appointmentPackages;

      if (packages.isEmpty) {
        return Center(
          child: Text(
            'No consultation packages available',
            style: secondaryTextStyle(size: 14, color: slate),
          ),
        );
      }

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
          ...packages.asMap().entries.map((entry) {
            final index = entry.key;
            final pkg = entry.value;
            final String pkgId = pkg.id ?? '';
            final String pkgName = pkg.name ?? 'Package';
            final String pkgDesc = pkg.desc ?? '';
            final int pkgDuration = pkg.duration ?? 0;

            final isSelected = (selectedProduct is String)
                ? selectedProduct == pkgId
                : (selectedProduct?.id == pkgId);

            final String displayPrice = pricingService.getFormattedPrice(pkgId);
            final String pkgType = pricingService.getPackageType(pkgId);

            List<Widget> features = [];
            features.add(_buildFeatureItem('Chat consultation', Icons.chat_bubble_rounded, kPrimary));
            if (pkgType == 'standard' || pkgType == 'special') {
              features.add(_buildFeatureItem('Video call consultation', Icons.videocam_rounded, kPrimary));
            }
            if (pkgType == 'special') {
              features.add(_buildFeatureItem('7 days follow up of 1hr daily', Icons.event_repeat_rounded, Colors.orange));
            }

            return GestureDetector(
              onTap: () => onSelected(pkgId),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isSelected ? kPrimary.withOpacity(0.04) : white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected ? kPrimary : border,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: kPrimary.withOpacity(0.12),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      )
                    else
                      BoxShadow(
                        color: obsidian.withOpacity(0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: isSelected ? kPrimary.withOpacity(0.1) : pageGray,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            _iconForIndex(index),
                            color: kPrimary,
                            size: 26,
                          ),
                        ),
                        16.width,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pkgName,
                                style: boldTextStyle(size: 17, color: ink),
                              ),
                              4.height,
                              Text(
                                pkgDesc,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: secondaryTextStyle(
                                    size: 12, color: slate, height: 1.3),
                              ),
                            ],
                          ),
                        ),
                        12.width,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              displayPrice,
                              style: boldTextStyle(size: 18, color: green),
                            ),
                            if (pkgDuration > 0) ...[
                              6.height,
                              Row(
                                children: [
                                  const Icon(Icons.timer_outlined,
                                      size: 14, color: slate),
                                  4.width,
                                  Text(
                                    formatDuration(Duration(seconds: pkgDuration)),
                                    style: secondaryTextStyle(size: 11, color: slate, weight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    if (features.isNotEmpty) ...[
                      20.height,
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected ? white : pageGray.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? kPrimary.withOpacity(0.1) : border.withOpacity(0.5),
                          ),
                        ),
                        child: Column(
                          children: features,
                        ),
                      ),
                    ],
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
