import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../constant/color.dart';

Stack tipsAds() {
  return Stack(
    alignment: Alignment.center,
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          width: double.infinity,
          child: Image.asset(
            "assets/images/men_health2.jpg",
            fit: BoxFit.cover,
          ),
        ),
      ),
      Positioned(
          child: Stack(
        children: <Widget>[
          // Stroked text as border.
          Text(
            'Always Drink Water',
            maxLines: 1,
            style: TextStyle(
              fontSize: 30,
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 6
                ..color = white,
            ),
          ),
          // Solid text as fill.
          Text(
            'Always Drink Water',
            maxLines: 1,
            style: TextStyle(
              fontSize: 30,
              color: kPrimary,
            ),
          ),
        ],
      )),
    ],
  );
}
