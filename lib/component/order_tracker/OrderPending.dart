import 'package:flutter/material.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../models/OrderModel.dart';
import '../../services/formatDate.dart';

class OrderPending extends StatefulWidget {
  final int index;
  OrderModel order;
  OrderPending({super.key, required this.index, required this.order});

  @override
  State<OrderPending> createState() => _OrderPendingState();
}

class _OrderPendingState extends State<OrderPending> {
  bool visible = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 5,
          backgroundColor: widget.index >= 0 ? kPrimary : grey.withOpacity(0.4),
        ),
        IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 2,
                color: widget.index >= 0 ? kPrimary : grey.withOpacity(0.4),
              ).paddingLeft(4),
              20.width,
              Expanded(
                  child: Column(
                children: [
                  Row(
                    crossAxisAlignment: widget.index == 0
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.center,
                    children: [
                      Card(
                        color: context.cardColor,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: widget.index > 0
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
                                ).opacity(opacity: widget.index >= 0 ? 1 : 0.4),
                        ),
                      ),
                      10.width,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Order Pending",
                            style: boldTextStyle(
                              color: widget.index >= 0
                                  ? kPrimary
                                  : grey.withOpacity(0.4),
                            ),
                          ),
                          Text(
                            "Your order has been sent",
                            style: primaryTextStyle(
                              size: 12,
                              color: widget.index >= 0
                                  ? null
                                  : grey.withOpacity(0.4),
                            ),
                          ).visible(widget.index == 0),
                          5.height,
                          Text(
                            formatDate(widget.order.updatedAt!.toDate()),
                            style: primaryTextStyle(
                              size: 12,
                            ),
                          ).visible(widget.index == 0),
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
