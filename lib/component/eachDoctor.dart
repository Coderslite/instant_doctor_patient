import 'package:flutter/material.dart';
import 'package:instant_doctor/component/ProfileImage.dart';
import 'package:instant_doctor/main.dart';
import 'package:instant_doctor/models/ReviewsModel.dart';
import 'package:nb_utils/nb_utils.dart';

import '../constant/constants.dart';
import '../models/UserModel.dart';
import 'IsOnline.dart';

Padding eachDoctor({required UserModel doctor, required BuildContext context}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Card(
      color: context.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    SizedBox(
                      height: 50,
                      width: 50,
                      child: profileImage(doctor, 40, 40, context: context),
                    ),
                    Positioned(
                        right: 2,
                        bottom: 2,
                        child: isOnline(doctor.status == ONLINE ? true : false))
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
                    10.height,
                    Text(
                      doctor.speciality!,
                      style: secondaryTextStyle(size: 12),
                    ),
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
                  return Text("");
                }),
          ],
        ),
      ),
    ),
  );
}
