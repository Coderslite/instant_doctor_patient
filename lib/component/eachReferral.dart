import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instant_doctor/component/ProfileImage.dart';
import 'package:instant_doctor/main.dart';
import 'package:instant_doctor/models/ReferralModel.dart';
import 'package:instant_doctor/models/UserModel.dart';
import 'package:instant_doctor/services/format_number.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:timeago/timeago.dart' as timeago;

StreamBuilder eachReferral(
    {required BuildContext context, required ReferralModel data}) {
  return StreamBuilder<UserModel>(
      stream: userService.getProfile(userId: data.userId.validate()),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var userRef = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Card(
              color: context.cardColor,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          profileImage(userRef, 40, 40,context: context),
                          10.width,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 1.9,
                                child: Text(
                                  "${userRef.firstName.validate()} ${userRef.lastName.validate()} was referred by you",
                                  style: boldTextStyle(size: 14),
                                ),
                              ),
                              10.height,
                              Text(
                                timeago.format(data.createdAt!.toDate()),
                                style: secondaryTextStyle(size: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "${formatAmount(500)}",
                      style: boldTextStyle(
                        color: mediumSeaGreen,
                        size: 12,
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        }
        return Container();
      });
}
