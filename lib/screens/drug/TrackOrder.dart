import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/component/backButton.dart';
import 'package:instant_doctor/models/PharmacyModel.dart';
import 'package:instant_doctor/services/PharmacyService.dart';
import 'package:instant_doctor/services/format_number.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
  var pharmacyService = Get.find<PharmacyService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        backButton(context),
                        Text(
                          "Order #${order.id.validate().substring(0, 8)}",
                          style: boldTextStyle(size: 20),
                        ),
                        const SizedBox(width: 48), // For balance
                      ],
                    ),
                    24.height,

                    // Pharmacy Info Card
                    StreamBuilder<PharmacyModel>(
                        stream: pharmacyService.getPharmacyById(
                            id: order.pharmacyId.validate()),
                        builder: (context, asyncSnapshot) {
                          if (asyncSnapshot.hasData) {
                            var pharmacy = asyncSnapshot.data!;
                            return Container(
                              decoration: BoxDecoration(
                                color: context.cardColor,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  // Pharmacy Image
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.grey[200],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: CachedNetworkImage(
                                        imageUrl: pharmacy.image ?? '',
                                        placeholder: (context, url) =>
                                            Container(
                                          color: Colors.grey[200],
                                          child: Icon(Icons.local_pharmacy,
                                              color: Colors.grey[400]),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Container(
                                          color: Colors.grey[200],
                                          child: Icon(Icons.local_pharmacy,
                                              color: Colors.grey[400]),
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  12.width,

                                  // Pharmacy Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          pharmacy.name ?? 'Pharmacy',
                                          style: boldTextStyle(size: 16),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        4.height,
                                        if (pharmacy.address != null)
                                          Text(
                                            pharmacy.address!,
                                            style: secondaryTextStyle(size: 12),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        4.height,
                                        if (pharmacy.phoneNumber != null)
                                          Row(
                                            children: [
                                              Icon(Icons.phone,
                                                  size: 14, color: gray),
                                              4.width,
                                              Text(
                                                pharmacy.phoneNumber!,
                                                style: secondaryTextStyle(
                                                    size: 12),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ).animate().fadeIn().slideY(begin: 0.2);
                          }
                          return Loader();
                        }),
                    16.height,

                    // Progress Timeline
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _TimelineItem(
                              status: "Order Placed",
                              isActive: currentIndex >= 0,
                              isCurrent: currentIndex == 0,
                              date: order.createdAt!.toDate(),
                              icon: Icons.shopping_bag_outlined,
                              description: "Your order has been received",
                            ),
                            _TimelineItem(
                              status: "Processing",
                              isActive: currentIndex >= 1,
                              isCurrent: currentIndex == 1,
                              date: order.updatedAt!.toDate(),
                              icon: Icons.local_pharmacy_outlined,
                              description: "Preparing your medications",
                            ),
                            _TimelineItem(
                              status: "On the Way",
                              isActive: currentIndex >= 2,
                              isCurrent: currentIndex == 2,
                              date: order.updatedAt!.toDate(),
                              icon: Icons.delivery_dining,
                              description: "Your order is out for delivery",
                            ),
                            _TimelineItem(
                              status: "Delivered",
                              isActive: currentIndex >= 3,
                              isCurrent: currentIndex == 3,
                              date: order.updatedAt!.toDate(),
                              icon: Icons.check_circle_outline,
                              description: "Order successfully delivered",
                              isLast: true,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Order Summary
                    Container(
                      decoration: BoxDecoration(
                        color: context.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 16,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            "Order Summary",
                            style: boldTextStyle(size: 18),
                          ),
                          16.height,
                          ...order.items!.map(
                            (item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(Icons.medication,
                                        color: Colors.blue),
                                  ),
                                  12.width,
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['name'],
                                          style: primaryTextStyle(),
                                        ),
                                        Text(
                                          "Qty: ${item['quantity']}",
                                          style: secondaryTextStyle(size: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    formatAmount(
                                        item['quantity'] * item['amount']),
                                    style: boldTextStyle(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Divider(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Total Amount",
                                style: boldTextStyle(size: 16),
                              ),
                              Text(
                                formatAmount(order.totalAmount.validate()),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final String status;
  final String description;
  final bool isActive;
  final bool isCurrent;
  final bool isLast;
  final DateTime date;
  final IconData icon;

  const _TimelineItem({
    required this.status,
    required this.description,
    required this.isActive,
    required this.isCurrent,
    required this.date,
    required this.icon,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? Colors.blue : Colors.grey[300],
                  border: Border.all(
                    color: isActive ? Colors.blue.shade700 : Colors.grey[400]!,
                    width: 2,
                  ),
                ),
                child: isActive
                    ? Icon(
                        isCurrent ? icon : Icons.check,
                        size: 14,
                        color: Colors.white,
                      )
                    : null,
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 80,
                  color: isActive ? Colors.blue : Colors.grey[300],
                ),
            ],
          ),
          16.width,

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isActive ? Colors.blue : Colors.grey,
                  ),
                ),
                8.height,
                if (isCurrent)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        description,
                        style: TextStyle(
                          color: Colors.grey[700],
                        ),
                      ),
                      8.height,
                      Text(
                        _formatDate(date),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }
}
