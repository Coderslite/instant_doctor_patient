// // ignore_for_file: use_build_context_synchronously

// import 'package:flutter/material.dart';
// import 'package:flutterwave_standard_smart/flutterwave.dart';
// import 'package:get/get.dart';
// import 'package:instant_doctor/component/snackBar.dart';
// import 'package:instant_doctor/constant/color.dart';
// import 'package:paystack_for_flutter/paystack_for_flutter.dart';
// import 'package:uuid/uuid.dart';
// import 'package:instant_doctor/controllers/UserController.dart';
// import 'package:instant_doctor/main.dart';
// import 'package:nb_utils/nb_utils.dart';

// import '../../../component/backButton.dart';
// import '../../../component/dialpad.dart';
// import '../../../controllers/PaymentController.dart';
// import '../../../services/GetUserId.dart';
// import '../../../services/caluculate_fontsize.dart';
// import '../../../services/format_number.dart';

// class FundWalletScreen extends StatefulWidget {
//   const FundWalletScreen({super.key});

//   @override
//   State<FundWalletScreen> createState() => _FundWalletScreenState();
// }

// class _FundWalletScreenState extends State<FundWalletScreen> {
//   PaymentController paymentController = Get.put(PaymentController());
//   bool decimalPointPressed = false; // Flag to track decimal point
//   String email = '';
//   String token = '';
//   bool isLoading = false;

//   handleGetEmail() async {
//     var res =
//         await userService.getProfileById(userId: userController.userId.value);
//     email = res.email!;
//     token = res.token!;

//     setState(() {});
//   }

//   @override
//   void dispose() {
//     paymentController.amount.value = '0';
//     super.dispose();
//   }

//   @override
//   void initState() {
//     super.initState();
//     handleGetEmail();
//   }

//   handlePaymentInitialization() async {}

//   // void makePayment() async {
//   //   try {
//   //     isLoading = true;
//   //     setState(() {});
//   //     final Customer customer = Customer(
//   //       name: "Flutterwave Developer",
//   //       phoneNumber: "1234566677777",
//   //       email: email,
//   //     );
//   //     final Flutterwave flutterwave = Flutterwave(
//   //         context: context,
//   //         publicKey: "FLWPUBK_TEST-77caed21c093d04214eb3f85634c0fa6-X",
//   //         currency: "NGN",
//   //         redirectUrl: "https://instantdoctorservice.com",
//   //         txRef: Uuid().v1(),
//   //         amount: paymentController.amount.string,
//   //         customer: customer,
//   //         paymentOptions: "ussd, card, barter, payattitude",
//   //         customization: Customization(title: "Top Wallet"),
//   //         isTestMode: true);
//   //     final ChargeResponse response = await flutterwave.charge();
//   //     if (response.success.validate()) {
//   //       await paymentController.handleTopUp(context, token: token);
//   //     } else {
//   //       errorSnackBar(title: "Payment not successful");
//   //     }
//   //   } finally {
//   //     isLoading = false;
//   //     setState(() {});
//   //   }
//   // }

//   // @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         alignment: Alignment.center,
//         children: [
//           Container(
//             decoration: const BoxDecoration(
//               image: DecorationImage(
//                 image: AssetImage("assets/images/thumbnail1.png"),
//                 fit: BoxFit.cover,
//               ),
//             ),
//             child: SafeArea(
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         backButton(context),
//                         Text(
//                           "Fund Wallet",
//                           style: boldTextStyle(size: 18),
//                         ),
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 10,
//                             vertical: 10,
//                           ),
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(20),
//                             border: Border.all(color: context.primaryColor),
//                           ),
//                           child: Row(
//                             children: [
//                               Text(
//                                 userController.currency.value,
//                                 style: primaryTextStyle(),
//                               ),
//                             ],
//                           ),
//                         )
//                       ],
//                     ),
//                     10.height,
//                     FittedBox(
//                       fit: BoxFit.scaleDown,
//                       child: Text(
//                         formatAmount(int.parse(paymentController.amount.value)),
//                         overflow: TextOverflow.ellipsis,
//                         style: boldTextStyle(
//                           size: calculateFontSize(
//                               paymentController.amount.value.length),
//                           color: kPrimary,
//                         ),
//                       ),
//                     ),
//                     Expanded(
//                       child: CalculatorDialpad(
//                         onDeletePressed: () {
//                           // Handle delete button press
//                           if (paymentController.amount.value.isNotEmpty &&
//                               paymentController.amount.value != '0') {
//                             String lastChar = paymentController.amount.value
//                                 .substring(
//                                     paymentController.amount.value.length - 1);

//                             if (lastChar == '.') {
//                               decimalPointPressed =
//                                   false; // Reset the flag if deleting a decimal point
//                             }
//                             paymentController.amount.value =
//                                 paymentController.amount.value.substring(0,
//                                     paymentController.amount.value.length - 1);
//                             if (paymentController.amount.isEmpty) {
//                               paymentController.amount.value = '0';
//                             }
//                             setState(() {});
//                           }
//                         },
//                         onDigitPressed: (String digit) {
//                           // Handle digit button press
//                           if (digit == '.') {
//                             // Check if decimal point is already pressed
//                             if (!decimalPointPressed) {
//                               paymentController.amount.value += digit;
//                               decimalPointPressed = true; // Set the flag
//                               setState(() {});
//                             }
//                           } else {
//                             if (paymentController.amount.value == '0' &&
//                                 digit != '.') {
//                               paymentController.amount.value = digit;
//                             } else {
//                               paymentController.amount.value += digit;
//                             }
//                             setState(() {});
//                           }
//                         },
//                       ),
//                     ),
//                     Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 20, vertical: 10),
//                       decoration: BoxDecoration(
//                         color: kPrimary,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Text(
//                         "Next",
//                         style: primaryTextStyle(color: white),
//                       ).center(),
//                     ).onTap(() {
//                       paymentController.makePayment(
//                           email: email, context: context, token: token,amount:int.parse( paymentController.amount.value));
//                     }).visible(!isLoading),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           Positioned(
//             child: Loader().center().visible(isLoading),
//           )
//         ],
//       ),
//     );
//   }
// }
