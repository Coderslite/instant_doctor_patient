// import 'package:flutter/material.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
// import 'package:get/get.dart';
// import 'package:instant_doctor/constant/color.dart';

// import '../controllers/PaymentController.dart';

// class StripePayCard extends StatefulWidget {
//   final String currency;
//   const StripePayCard({super.key, required this.currency});

//   @override
//   State<StripePayCard> createState() => _StripePayCardState();
// }

// class _StripePayCardState extends State<StripePayCard> {
//   PaymentController paymentController = Get.put(PaymentController());
//   @override
//   Widget build(BuildContext context) {
//     return CardFormField(
//       enablePostalCode: false,
//       controller: paymentController.controller,
//       countryCode: widget.currency,
//       style: CardFormStyle(
//         cursorColor: kPrimary,
//         borderColor: kPrimary,
//         textColor: context.iconColor,
//         placeholderColor: kPrimary,
//       ),
//       autofocus: true,
//       onCardChanged: (details) {},
//     );
//   }
// }
