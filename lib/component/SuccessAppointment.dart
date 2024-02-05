import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../constant/color.dart';
import '../screens/home/Root.dart';

Future<dynamic> successAppointement(BuildContext context) {
  return showInDialog(context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 150,
            width: 150,
            child: Image.asset("assets/images/thumb.png", fit: BoxFit.cover),
          ),
          10.height,
          Text(
            "Thank You!",
            style: boldTextStyle(size: 35, color: kPrimary),
          ),
          0.height,
          Text(
            " Appointment Booked",
            style: primaryTextStyle(
              size: 16,
            ),
          ),
          40.height,
          AppButton(
            onTap: () {
              Root().launch(context);
            },
            text: "Done",
            width: double.infinity,
            color: kPrimary,
            textColor: white,
          ),
          20.height,
          Text(
            "Edit Appointment",
            style: primaryTextStyle(
              size: 16,
            ),
          ),
        ],
      ));
}
