import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/models/OrderModel.dart';
import 'package:instant_doctor/screens/drug/TrackOrder.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/eachOrder.dart';
import '../../services/OrderService.dart';

class OrderHistory extends StatefulWidget {
  const OrderHistory({super.key});

  @override
  State<OrderHistory> createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {
  final orderService = Get.find<OrderService>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Order History",
                    style: boldTextStyle(
                      size: 18,
                      color: kPrimary,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: StreamBuilder<List<OrderModel>>(
                    stream: orderService.getMyOrders(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        var data = snapshot.data!;
                        return data.isEmpty
                            ? Text(
                                "No order history available",
                                style: boldTextStyle(),
                              ).center()
                            : ListView.builder(
                                itemCount: data.length,
                                itemBuilder: (context, index) {
                                  return eachOrder(context, data[index])
                                      .onTap(() {
                                    OrderTracker(
                                      orderId: data[index].id.validate(),
                                    ).launch(context);
                                  });
                                },
                              );
                      }
                      return Loader();
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
