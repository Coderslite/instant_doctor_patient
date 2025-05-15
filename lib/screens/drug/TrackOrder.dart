
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/component/backButton.dart';
import 'package:instant_doctor/component/order_tracker/OrderCompleted.dart';
import 'package:instant_doctor/component/order_tracker/OrderDelivering.dart';
import 'package:instant_doctor/services/format_number.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/order_tracker/OrderPending.dart';
import '../../component/order_tracker/OrderProcessing.dart';
import '../../models/OrderModel.dart';
import '../../services/OrderService.dart';

class OrderTracker extends StatefulWidget {
  final String orderId;
  const OrderTracker({super.key, required this.orderId});

  @override
  State<OrderTracker> createState() => _OrderTrackerState();
}

class _OrderTrackerState extends State<OrderTracker> {
  final orderService = Get.find<OrderService>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<OrderModel>(
            stream: orderService.getMyOrderById(orderId: widget.orderId),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var order = snapshot.data!;
                int currentIndex = order.status == "confirmed"
                    ? 1
                    : order.status == "delivering"
                        ? 2
                        : order.status == "completed"
                            ? 3
                            : 0;

                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        backButton(context),
                        Text(
                          "Track Order",
                          style: boldTextStyle(
                            size: 16,
                          ),
                        ),
                        Container()
                      ],
                    ),
                    20.height,
                    Expanded(
                      child: ListView(
                        children: [
                          OrderPending(
                            order: order,
                            index: currentIndex,
                          ),
                          OrderProcessing(
                            order: order,
                            index: currentIndex,
                          ),
                          OrderDelivering(
                            order: order,
                            index: currentIndex,
                          ),
                          OrderCompleted(
                            order: order,
                            index: currentIndex,
                          ),
                        ],
                      ),
                    ),
                    Card(
                      color: context.cardColor,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Column(
                          children: [
                            for (int x = 0; x < order.items!.length; x++)
                              ListTile(
                                title: Text(
                                  "${order.items![x]['name']}",
                                  style: boldTextStyle(),
                                ),
                                subtitle: Text(
                                  "x ${order.items![x]['quantity']} = ${formatAmount(order.items![x]['quantity'] * order.items![x]['amount'])}",
                                  style: secondaryTextStyle(
                                    size: 12,
                                  ),
                                ),
                              ),
                            Text(
                              formatAmount(
                                order.totalAmount.validate(),
                              ),
                              style: boldTextStyle(size: 20),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }
              return Loader();
            }),
      )),
    );
  }
}
