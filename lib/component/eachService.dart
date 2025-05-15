import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

services(
    BuildContext context, String image, String serviceName, VoidCallback onTap,
    {required GlobalKey<State<StatefulWidget>> key}) {
  return Container(
    width: 150,
    height: 120,
    key: key,
    padding: const EdgeInsets.all(10),
    margin: const EdgeInsets.all(10),
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
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 50,
          child: Image.asset(
            "assets/images/$image",
            fit: BoxFit.cover,
            // color: kPrimary,
          ),
        ),
        5.height,
        Text(
          serviceName,
          textAlign: TextAlign.center,
          style: boldTextStyle(size: 14),
        )
      ],
    ),
  ).onTap(onTap);
}
