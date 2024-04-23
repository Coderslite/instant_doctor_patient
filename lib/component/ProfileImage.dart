import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:nb_utils/nb_utils.dart';

import '../models/UserModel.dart';

ClipOval profileImage(UserModel? data, double width, double height) {
  return ClipOval(
    child: Container(
      decoration: const BoxDecoration(
        color: white,
      ),
      width: width,
      height: height,
      child: data!.photoUrl.validate().isNotEmpty
          ? CachedNetworkImage(
              imageUrl: data.photoUrl!,
              fit: BoxFit.cover,
            )
          : Icon(
              Icons.person,
              size: width,
              color: kPrimary,
            ),
    ),
  );
}
