import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/main.dart';
import 'package:instant_doctor/models/OrderModel.dart';
import 'package:instant_doctor/screens/drug/TrackOrder.dart';
import 'package:instant_doctor/screens/pharmacy/Pharmacies.dart';
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
      body: Obx(() {
        var d = settingsController.isDarkMode.value;
        return SafeArea(
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
                              ? _buildNoOrderFound()
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
        );
      }),
    );
  }

  Widget _buildNoOrderFound() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(CupertinoIcons.shopping_cart, size: 80, color: Colors.grey[400]),
        SizedBox(height: 20),
        Text(
          "No Order Found",
          style: boldTextStyle(size: 18),
        ),
        SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Text(
            "You haven't made any order yet, click on the button below to start",
            textAlign: TextAlign.center,
            style: primaryTextStyle(size: 14, color: Colors.grey),
          ),
        ),
        SizedBox(height: 30),
        ElevatedButton(
          onPressed: () => PharmaciesScreen().launch(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          ),
          child: Text(
            "Order Now",
            style: boldTextStyle(color: white),
          ),
        ),
      ],
    );
  }
}
