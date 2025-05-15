// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:instant_doctor/constant/color.dart';
// import 'package:instant_doctor/services/TransactionService.dart';
// import 'package:nb_utils/nb_utils.dart';

// import '../../component/ProfileImage.dart';
// import '../../component/card.dart';
// import '../../component/eachTransaction.dart';
// import '../../controllers/SettingController.dart';
// import '../../controllers/UserController.dart';
// import '../../main.dart';
// import '../../models/UserModel.dart';
// import '../../services/greetings.dart';
// import 'fund_wallet/FundWallet.dart';
// import 'history/History.dart';
// import 'send_funds/SendFunds.dart';

// class WalletScreen extends StatefulWidget {
//   const WalletScreen({super.key});

//   @override
//   State<WalletScreen> createState() => _WalletScreenState();
// }

// class _WalletScreenState extends State<WalletScreen> {
//   final SettingsController settingsController = Get.find();

//   TransactionService transactionService = TransactionService();
//   UserController userController = Get.put(UserController());

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Obx(() {
//         // ignore: unused_local_variable
//         bool isDarkMode = settingsController.isDarkMode.value;
//         return SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Column(
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     StreamBuilder<UserModel>(
//                         stream: userController.userId.isNotEmpty
//                             ? userService.getProfile(
//                                 userId: userController.userId.value)
//                             : null,
//                         builder: (context, snapshot) {
//                           if (snapshot.hasData) {
//                             var data = snapshot.data;
//                             return Row(
//                               children: [
//                                 profileImage(UserModel(), 40, 40,
//                                     context: context),
//                                 10.width,
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       "${data!.firstName!} ${data.lastName!}",
//                                       style: boldTextStyle(),
//                                     ),
//                                     Text(
//                                       getGreeting(),
//                                       style: primaryTextStyle(size: 12),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             );
//                           }
//                           return Container();
//                         }),
//                     SizedBox(
//                       height: 50,
//                       width: 50,
//                       child: Image.asset(
//                         "assets/images/logo.png",
//                         fit: BoxFit.cover,
//                         color: kPrimary,
//                       ),
//                     ),
//                   ],
//                 ),
//                 Expanded(
//                   child: RefreshIndicator(
//                     color: kPrimary,
//                     onRefresh: () async {
//                       Future.delayed(const Duration(seconds: 2));
//                       return;
//                     },
//                     child: SingleChildScrollView(
//                       physics: const BouncingScrollPhysics(),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           10.height,
//                           card(context),
//                           20.height,
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               walletOption("Top Up", "topup.png", () {
//                                 if (userController.currency.isNotEmpty) {
//                                   const FundWalletScreen().launch(context);
//                                 } else {
//                                   toast(
//                                       "Please complete wallet setup to proceed");
//                                 }
//                               }),
//                               walletOption(
//                                 "Transfer",
//                                 "transfer.png",
//                                 () {
//                                   if (userController.currency.isNotEmpty) {
//                                     const SendFundScreen().launch(context);
//                                   } else {
//                                     toast(
//                                         "Please complete wallet setup to proceed");
//                                   }
//                                 },
//                               ),
//                               walletOption(
//                                 "Receipt",
//                                 "receipt.png",
//                                 () {},
//                               ),
//                             ],
//                           ).paddingSymmetric(
//                             horizontal: 20,
//                           ),
//                           20.height,
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 "Transaction History",
//                                 style: secondaryTextStyle(size: 14),
//                               ),
//                               Text(
//                                 "See all",
//                                 style: secondaryTextStyle(size: 14),
//                               ).onTap(() {
//                                 const History().launch(context);
//                               }),
//                             ],
//                           ),
//                           20.height,
//                           StreamBuilder(
//                               stream: transactionService.getAllTransaction(
//                                   userId: userController.userId.value),
//                               builder: (context, snapshot) {
//                                 if (snapshot.hasData) {
//                                   var transaction = snapshot.data;
//                                   if (snapshot.data!.isEmpty) {
//                                     return Center(
//                                         child: Text(
//                                       "No Transaction Yet",
//                                       style: boldTextStyle(),
//                                     ));
//                                   } else {
//                                     return Column(
//                                       children: [
//                                         for (int x = 0;
//                                             x < snapshot.data!.length;
//                                             x++)
//                                           eachTransaction(
//                                               context: context,
//                                               transaction: transaction![x]),
//                                       ],
//                                     );
//                                   }
//                                 }
//                                 return const Center(
//                                   child: CircularProgressIndicator(
//                                     color: kPrimary,
//                                   ),
//                                 );
//                               })
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       }),
//     );
//   }

//   walletOption(String name, String image, VoidCallback ontap) {
//     return Column(
//       children: [
//         Container(
//           width: MediaQuery.of(context).size.width / 7,
//           alignment: Alignment.center,
//           padding: const EdgeInsets.all(10),
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             color: context.cardColor,
//           ),
//           child: SizedBox(
//             child: Image.asset(
//               "assets/images/$image",
//               color: kPrimary,
//             ),
//           ).center(),
//         ),
//         1.height,
//         Text(
//           name,
//           style: boldTextStyle(
//             color: kPrimary,
//             size: 12,
//           ),
//         ),
//       ],
//     ).onTap(ontap);
//   }
// }
