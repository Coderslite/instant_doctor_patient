import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

Container docDetail(
    BuildContext context, String desc, String title, String image) {
  return Container(
    width: MediaQuery.of(context).size.width / 3.4,
    height: 110,
    decoration: BoxDecoration(
      color: context.cardColor,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: dimGray.withOpacity(0.1),
          spreadRadius: 0.5,
          blurRadius: 3,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          SizedBox(
            width: 35,
            height: 50,
            child: Image.asset(
              "assets/images/$image",
              fit: BoxFit.cover,
            ),
          ),
          10.height,
          Text(
            title,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: boldTextStyle(size: 14),
          ),
          5.height,
          Text(
            desc,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: secondaryTextStyle(size: 12),
          ),
        ],
      ),
    ),
  );
}
