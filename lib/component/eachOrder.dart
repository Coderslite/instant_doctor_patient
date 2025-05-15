import 'package:flutter/material.dart';
import 'package:instant_doctor/models/OrderModel.dart';
import 'package:nb_utils/nb_utils.dart';

import '../constant/color.dart';
import '../services/format_number.dart';

Color getStatusColor(String status) {
  switch (status) {
    case 'pending':
      return Colors.orangeAccent;
    case 'confirmed':
      return Colors.redAccent;
    case 'delivering':
      return Colors.deepOrange;
    case 'completed':
      return Colors.greenAccent;
    default:
      return Colors.grey;
  }
}

Container eachOrder(BuildContext context, OrderModel order) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 5),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: context.cardColor,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                  color:
                      getStatusColor(order.status.validate()).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20)),
              child: Text(
                order.status.validate(),
                style: primaryTextStyle(
                  size: 12,
                ),
              ),
            ),
            Text(
              "Order Number: ${order.trackingId}",
              style: primaryTextStyle(
                size: 12,
              ),
            ),
          ],
        ),
        10.height,
        Column(
          children: [
            for (int x = 0; x < order.items!.length; x++)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    Icons.medication,
                  ),
                  10.width,
                  Expanded(
                      child: Text(
                    "x ${order.items.validate()[x]['quantity']} ${order.items.validate()[x]['name']}",
                    style: primaryTextStyle(
                      size: 14,
                    ),
                  ))
                ],
              ),
          ],
        ),
        10.height,
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              formatAmount(order.totalAmount.validate()),
              style: boldTextStyle(
                size: 16,
                color: kPrimary,
              ),
            ),
          ],
        )
      ],
    ),
  );
}
