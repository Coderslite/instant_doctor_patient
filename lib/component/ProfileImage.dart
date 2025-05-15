import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../models/UserModel.dart';
import '../screens/chat/ImagePreview.dart';

ClipOval profileImage(UserModel? data, double width, double height,
    {required BuildContext context}) {
  return ClipOval(
    child: Container(
      decoration: BoxDecoration(
        color: context.cardColor,
      ),
      width: width,
      height: height,
      child: data!.photoUrl.validate().isNotEmpty
          ? CachedNetworkImage(
              imageUrl: data.photoUrl!,
              fit: BoxFit.cover,
            ).onTap(() {
              ImagePreview(imageUrl: data.photoUrl.validate()).launch(context);
            })
          : Image.asset(
              "assets/images/avatar2.png",
              fit: BoxFit.cover,
            ),
    ),
  );
}
