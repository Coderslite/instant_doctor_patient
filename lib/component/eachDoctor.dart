import 'package:flutter/material.dart';
import 'package:instant_doctor/component/ProfileImage.dart';
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
                      child: profileImage(doctor, 40, 40),
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
            Column(
              children: [
                Row(
                  children: [
                    for (int y = 0; y < 5; y++)
                      const Icon(
                        Icons.star,
                        size: 12,
                        color: gold,
                      )
                  ],
                ),
                Text(
                  "35 Reviews",
                  style: primaryTextStyle(size: 12),
                )
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
