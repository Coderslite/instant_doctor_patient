import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/models/HealthTipModel.dart';
import 'package:instant_doctor/services/HealthTipService.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../screens/healthtips/SingleTips.dart';

Padding eachTips(BuildContext context, HealthTipModel healthTip) {
  var healthTipService = Get.find<HealthTipService>();
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Card(
      color: context.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            SizedBox(
              height: 50,
              width: 50,
              child: CachedNetworkImage(
                imageUrl: healthTip.image.validate(),
                fit: BoxFit.cover,
              ),
            ),
            10.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    healthTip.title.validate(),
                    style: boldTextStyle(
                      size: 14,
                    ),
                  ),
                  StreamBuilder<int>(
                      stream: healthTipService.getViewCount(
                          healthTipId: healthTip.id.validate()),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Text(
                            "${snapshot.data} views Published ${timeago.format(healthTip.createdAt!.toDate())}",
                            style: secondaryTextStyle(
                              size: 12,
                            ),
                          );
                        }
                        return SizedBox.shrink();
                      })
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
            ),
          ],
        ),
      ),
    ).onTap(() {
      SingleTipScreen(
        healthTip: healthTip,
      ).launch(context);
    }),
  );
}
