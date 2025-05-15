import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/screens/appointment/AppointmentPricing.dart';
import 'package:nb_utils/nb_utils.dart';

import '../constant/color.dart';
import '../controllers/BookingController.dart';

class DateBooking extends StatefulWidget {
  final PageController pageController;
  const DateBooking({super.key, required this.pageController});

  @override
  State<DateBooking> createState() => _DateBookingState();
}

class _DateBookingState extends State<DateBooking> {
  var bookingController = Get.put(BookingController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        children: [
          Text(
            "Hello Username, please set date and timefor your appointment;",
            textAlign: TextAlign.center,
            style: secondaryTextStyle(),
          ),
          10.height,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: dimGray.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 3,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: AppTextField(
              textFieldType: TextFieldType.MULTILINE,
              minLines: 7,
              maxLines: 9,
              initialValue: bookingController.complain.value,
              textStyle: primaryTextStyle(),
              onChanged: (p0) {
                bookingController.complain.value = p0;
              },
              decoration: InputDecoration(
                  filled: true,
                  fillColor: context.cardColor,
                  labelText: "Enter your complain",
                  labelStyle: primaryTextStyle(color: kPrimary),
                  border: InputBorder.none),
            ),
          ),
          20.height,
          const CircularProgressIndicator(
            color: kPrimary,
          ).center().visible(bookingController.isLoading.value),
          AppButton(
            onTap: () {
              if (bookingController.price > 0) {
                if (bookingController.complain.isEmpty) {
                  toast("please enter complain");
                } else {
                  widget.pageController.nextPage(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeIn);
                }
              } else {
                const AppointmentPricingScreen(fromDocScreen: true)
                    .launch(context);
              }
            },
            text: bookingController.price > 0 ? "Continue" : "Select Package",
            color: kPrimary,
            textColor: white,
            width: double.infinity,
          ).visible(!bookingController.isLoading.value),
        ],
      ),
    );
  }
}
