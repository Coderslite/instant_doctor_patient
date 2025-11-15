import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/models/HealthTipModel.dart';
import 'package:instant_doctor/services/HealthTipService.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';
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
                  Text(
                    "${healthTip.views.validate()} views Published ${timeago.format(healthTip.createdAt!.toDate())}",
                    style: secondaryTextStyle(
                      size: 12,
                    ),
                  )
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
      launchUrl(
        Uri.parse(
            "https://instantdoctor.co/blog-details.php?id=${healthTip.id.validate()}"),
        mode: LaunchMode.inAppBrowserView,
      );
    }),
  );
}
