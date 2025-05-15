import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/component/ProfileImage.dart';
import 'package:instant_doctor/main.dart';
import 'package:instant_doctor/models/ReviewsModel.dart';
import 'package:instant_doctor/services/ReviewService.dart';
import 'package:ionicons/ionicons.dart';
import 'package:nb_utils/nb_utils.dart';

import '../models/UserModel.dart';

Container eachDoctor(
    {required UserModel doctor, required BuildContext context}) {
  var reviewService = Get.find<ReviewService>();
  return Container(
    padding: const EdgeInsets.all(8.0),
    margin: const EdgeInsets.symmetric(vertical: 2),
    decoration: BoxDecoration(
      color: context.cardColor,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Stack(
              alignment: Alignment.topLeft,
              clipBehavior: Clip.none,
              children: [
                SizedBox(
                  height: 50,
                  width: 50,
                  child: profileImage(doctor, 40, 40, context: context),
                ),
                Positioned(
                    left: 0,
                    top: 2,
                    child: SizedBox(
                      width: 10,
                      height: 10,
                      child: Image.asset("assets/images/verified.png"),
                    ))
              ],
            ),
            10.width,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${doctor.firstName!} ${doctor.lastName!}",
                  style: boldTextStyle(size: 14),
                ),
                Text(
                  doctor.speciality!,
                  style: secondaryTextStyle(size: 12),
                ),
                5.height,
                Row(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Ionicons.language,
                          size: 16,
                          color: settingsController.isDarkMode.value
                              ? white.withOpacity(0.2)
                              : black.withOpacity(0.2),
                        ),
                        Text(
                          "English",
                          style: secondaryTextStyle(
                            size: 12,
                          ),
                        ),
                      ],
                    ),
                    5.width,
                    Row(
                      children: [
                        Icon(
                          Ionicons.language,
                          size: 16,
                          color: settingsController.isDarkMode.value
                              ? white.withOpacity(0.2)
                              : black.withOpacity(0.2),
                        ),
                        Text(
                          "Yoruba",
                          style: secondaryTextStyle(
                            size: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
        StreamBuilder<List<ReviewsModel>>(
            stream: reviewService.getDoctorReviews(
              docId: doctor.id.validate(),
            ),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var reviews = snapshot.data!;
                if (reviews.isNotEmpty) {
                  double averageRating = 0;
                  for (final review in reviews) {
                    final reviewData = review;
                    final rating = reviewData.rating.validate();
                    averageRating += rating;
                  }
                  averageRating /= reviews.length;
                  return Column(
                    children: [
                      Row(
                        children: [
                          for (int y = 0; y < 5; y++)
                            Icon(
                              Icons.star,
                              size: 12,
                              color: averageRating > y ? gold : Colors.grey,
                            )
                        ],
                      ),
                      Text(
                        "${reviews.length} Reviews",
                        style: primaryTextStyle(size: 12),
                      ),
                    ],
                  );
                }
              }
              return const Text("");
            }),
      ],
    ),
  );
}
