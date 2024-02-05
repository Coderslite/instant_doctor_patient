
  import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../constant/color.dart';

profileOption(String image, String name, VoidCallback onTap) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          border: Border.all(color: kPrimary, width: 1),
          borderRadius: BorderRadius.circular(20)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 50,
            child: Image.asset(
              "assets/images/$image",
              fit: BoxFit.cover,
            ),
          ),
          Text(
            name,
            textAlign: TextAlign.center,
            style: boldTextStyle(color: kPrimary),
          ),
        ],
      ),
    ).onTap(onTap);
  }
