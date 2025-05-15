import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/models/DrugModel.dart';
import 'package:instant_doctor/services/format_number.dart';
import 'package:nb_utils/nb_utils.dart';

import '../controllers/OrderController.dart';

class Eachcart extends StatefulWidget {
  final DrugModel drug;
  const Eachcart({super.key, required this.drug});

  @override
  State<Eachcart> createState() => _EachcartState();
}

class _EachcartState extends State<Eachcart> {
  final orderController = Get.find<OrderController>();
  @override
  Widget build(BuildContext context) {
    int drugQty = 0;
    int index =
        orderController.cart.indexWhere((item) => item.id == widget.drug.id);
    drugQty = orderController.cart[index].quantity;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 80,
              width: 80,
              child: CachedNetworkImage(
                imageUrl: widget.drug.images!.first,
                fit: BoxFit.cover,
              ),
            ),
          ),
          10.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${widget.drug.name}",
                      style: boldTextStyle(size: 14),
                    ),
                    Icon(Icons.close).onTap(() async {
                      orderController.handleRemoveFromCart(drug: widget.drug);
                      var res = await orderController.getTotalDeliveryFee();
                      orderController.deliveryFee.value = res.toInt();
                    }),
                  ],
                ),
                10.height,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatAmount(widget.drug.amount.validate().toInt() *
                          widget.drug.quantity
                              .validate()), // Show total price for the item
                      style: boldTextStyle(size: 16),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: grey),
                          ),
                          child: Icon(CupertinoIcons.minus, size: 25),
                        ).onTap(() {
                          if (widget.drug.quantity.validate() > 1) {
                            orderController.decreaseQuantity(widget.drug);
                            setState(() {});
                          }
                        }),
                        15.width,
                        Text(
                          "${widget.drug.quantity}", // Display current quantity
                          style: boldTextStyle(size: 16),
                        ),
                        15.width,
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: kPrimary),
                          ),
                          child: Icon(CupertinoIcons.add, size: 25),
                        ).onTap(() {
                          if (drugQty > widget.drug.remaining! - 1) {
                            toast(
                                "You have exceeded available quantity for ${widget.drug.name}");
                            return;
                          }
                          orderController.increaseQuantity(widget.drug);
                          setState(() {});
                        }),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
