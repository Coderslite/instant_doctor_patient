import 'package:flutter/material.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../models/OrderModel.dart';
import '../../services/formatDate.dart';

class OrderDelivering extends StatefulWidget {
  final int index;
  OrderModel order;
  OrderDelivering({super.key, required this.index, required this.order});

  @override
  State<OrderDelivering> createState() => _OrderDeliveringState();
}

class _OrderDeliveringState extends State<OrderDelivering> {
  bool visible = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 5,
          backgroundColor: widget.index >= 2 ? kPrimary : grey.withOpacity(0.4),
        ),
        IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 2,
                color: widget.index >= 2 ? kPrimary : grey.withOpacity(0.4),
              ).paddingLeft(4),
              20.width,
              Expanded(
                  child: Column(
                children: [
                  Row(
                    crossAxisAlignment: widget.index == 2
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
                                ).opacity(opacity: widget.index >= 2 ? 1 : 0.4),
                        ),
                      ),
                      10.width,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Order on the way",
                            style: boldTextStyle(
                              color: widget.index >= 2
                                  ? kPrimary
                                  : grey.withOpacity(0.4),
                            ),
                          ),
                          Text(
                            "Your order is now on the way",
                            style: primaryTextStyle(
                              size: 12,
                              color: widget.index >= 2
                                  ? null
                                  : grey.withOpacity(0.4),
                            ),
                          ).visible(widget.index == 2),
                          5.height,
                          Text(
                            formatDate(widget.order.updatedAt!.toDate()),
                            style: primaryTextStyle(
                              size: 12,
                            ),
                          ).visible(widget.index == 2),
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
      ],
    );
  }
}
