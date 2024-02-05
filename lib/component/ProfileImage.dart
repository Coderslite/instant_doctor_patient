import 'package:flutter/material.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:nb_utils/nb_utils.dart';

import '../models/UserModel.dart';

ClipOval profileImage(UserModel? data, double width, double height) {
  return ClipOval(
    child: Container(
      decoration: BoxDecoration(
        color: white,
      ),
      width: width,
      height: height,
      child: data!.photoUrl.validate().isNotEmpty
          ? Image.asset(
              data.photoUrl!,
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
