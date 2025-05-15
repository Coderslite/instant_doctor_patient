import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/constant/constants.dart';
import 'package:instant_doctor/controllers/LocationController.dart';
import 'package:instant_doctor/models/PharmacyModel.dart';
import 'package:nb_utils/nb_utils.dart';

Container eachPharmacy(BuildContext context, PharmacyModel pharmacy) {
  final locationController = Get.find<LocationController>();
  return Container(
    padding: const EdgeInsets.all(10),
    margin: const EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      color: context.cardColor,
    ),
    child: Column(
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: double.infinity,
                height: 130,
                child: CachedNetworkImage(
                  imageUrl: pharmacy.image.validate(),
                  progressIndicatorBuilder: (context, url, progress) {
                    return Loader(
                      value: progress.progress,
                    );
                  },
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
            ),
            Positioned(
              right: 5,
              top: 2,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: gold,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "${pharmacy.discount}% off",
                  style: primaryTextStyle(
                    size: 12,
                  ),
                ),
              ).visible(pharmacy.discount.validate() > 0),
            ),
          ],
        ),
        10.height,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              pharmacy.name.validate(),
              style: boldTextStyle(
                size: 16,
              ),
            ),
            Row(
              children: [
                Icon(
                  Icons.star,
                  color: gold,
                  size: 14,
                ),
                Text(
                  "4.5 (+500 Reviews)",
                  style: primaryTextStyle(
                    size: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        5.height,
        Row(
          children: [
            Icon(
              Icons.location_on,
              color: fireBrick,
              size: 14,
            ),
            5.width,
            Expanded(
              child: Text(
                pharmacy.address.validate(),
                style: primaryTextStyle(
                  size: 10,
                ),
              ),
            ),
            Text(
              "${calculateDistance2(locationController.latitude.value, locationController.longitude.value, pharmacy.location!.latitude, pharmacy.location!.longitude)}km",
              style: boldTextStyle(
                size: 16,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
