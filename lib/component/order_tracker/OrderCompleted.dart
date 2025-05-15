import 'package:flutter/material.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/services/formatDate.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../models/OrderModel.dart';

class OrderCompleted extends StatefulWidget {
  final int index;
  OrderModel order;
  OrderCompleted({super.key, required this.index, required this.order});

  @override
  State<OrderCompleted> createState() => _OrderCompletedState();
}

class _OrderCompletedState extends State<OrderCompleted> {
  bool visible = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 5,
          backgroundColor: widget.index >= 3 ? kPrimary : grey.withOpacity(0.4),
        ),
        IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 2,
                color: widget.index >= 3 ? kPrimary : grey.withOpacity(0.4),
              ).paddingLeft(4),
              20.width,
              Expanded(
                  child: Column(
                children: [
                  Row(
                    crossAxisAlignment: widget.index == 3
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.center,
                    children: [
                      Card(
                        color: context.cardColor,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: widget.index > 2
                              ? Icon(
                                  Icons.check_circle,
                                  color: kPrimary,
                                )
                              : SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: Icon(
                                    Icons.medication,
                                  ),
                                ).opacity(opacity: widget.index >= 3 ? 1 : 0.4),
                        ),
                      ),
                      10.width,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Order Completed",
                            style: boldTextStyle(
                              color: widget.index >= 3
                                  ? kPrimary
                                  : grey.withOpacity(0.4),
                            ),
                          ),
                          Text(
                            "Order order has been completed",
                            style: primaryTextStyle(
                              size: 12,
                              color: widget.index >= 3
                                  ? null
                                  : grey.withOpacity(0.4),
                            ),
                          ).visible(widget.index == 3),
                          5.height,
                          Text(
                            formatDate(widget.order.updatedAt!.toDate()),
                            style: primaryTextStyle(
                              size: 12,
                            ),
                          ).visible(widget.index == 3),
                        ],
                      ),
                    ],
                  ),
                  10.height,
                ],
              )),
            ],
          ),
        ),
        CircleAvatar(
          radius: 5,
          backgroundColor: widget.index >= 3 ? kPrimary : grey.withOpacity(0.4),
        ),
      ],
    );
  }
}
