// // ignore_for_file: use_build_context_synchronously

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:instant_doctor/constant/color.dart';
// import 'package:instant_doctor/main.dart';
// import 'package:instant_doctor/models/UserModel.dart';
// import 'package:instant_doctor/services/GetUserId.dart';
// import 'package:instant_doctor/services/format_number.dart';
// import 'package:nb_utils/nb_utils.dart';

// import '../../../component/backButton.dart';
// import '../../../services/is_email.dart';

// class SendFundScreen extends StatefulWidget {
//   const SendFundScreen({super.key});

//   @override
//   State<SendFundScreen> createState() => _SendFundScreenState();
// }

// class _SendFundScreenState extends State<SendFundScreen> {
//   final _formKey = GlobalKey<FormState>();
//   var emailController = TextEditingController();
//   var amountController = TextEditingController();
//   bool isSending = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//             image: DecorationImage(
//                 image: AssetImage("assets/images/thumbnail1.png"),
//                 fit: BoxFit.contain)),
//         child: SafeArea(
//             child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   backButton(context),
//                   Text(
//                     "Send Funds",
//                     style: boldTextStyle(
//                       color: kPrimary,
//                     ),
//                   ),
//                   const Text("    "),
//                 ],
//               ),
//               Expanded(
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         "Amount to transfer",
//                         style: primaryTextStyle(),
//                       ),
//                       AppTextField(
//                         textFieldType: TextFieldType.NUMBER,
//                         controller: amountController,
//                         inputFormatters: [
//                           FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
//                         ],
//                         decoration: InputDecoration(
//                           prefixIcon: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               10.width,
//                               Text(
//                                 "NGN ",
//                                 style: primaryTextStyle(color: kPrimary),
//                               ),
//                             ],
//                           ),
//                           border: OutlineInputBorder(
//                             borderSide: const BorderSide(color: kPrimary),
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                         ),
//                       ),
//                       20.height,
//                       Text(
//                         "Receiver Email / Tag",
//                         style: primaryTextStyle(),
//                       ),
//                       AppTextField(
//                         textFieldType: TextFieldType.OTHER,
//                         controller: emailController,
//                         decoration: InputDecoration(
//                           border: OutlineInputBorder(
//                             borderSide: const BorderSide(color: kPrimary),
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               isSending
//                   ? const CircularProgressIndicator(
//                       color: kPrimary,
//                     ).center()
//                   : AppButton(
//                       onTap: () async {
//                         if (_formKey.currentState!.validate()) {
//                           try {
//                             UserModel? user;
//                             isSending = true;
//                             setState(() {});
//                             if (isEmail(emailController.text)) {
//                               user = await userService.getUserByEmail(
//                                   email: emailController.text);
//                             } else {
//                               user = await userService.getUserByTag(
//                                   tag: emailController.text);
//                             }

//                             if (user != null) {
//                               showDialog(
//                                   context: context,
//                                   builder: (context) {
//                                     return AlertDialog(
//                                       title: Text(
//                                         "Proceed to Send ${formatAmount(int.parse(amountController.text))} to ${user!.firstName} ${user.lastName} ?",
//                                         style: primaryTextStyle(size: 16),
//                                       ),
//                                       actions: [
//                                         ElevatedButton(
//                                           style: ElevatedButton.styleFrom(
//                                               backgroundColor: fireBrick),
//                                           onPressed: () {
//                                             Navigator.pop(context);
//                                           },
//                                           child: Text(
//                                             "Cancel",
//                                             style:
//                                                 primaryTextStyle(color: white),
//                                           ),
//                                         ),
//                                         ElevatedButton(
//                                           style: ElevatedButton.styleFrom(
//                                               backgroundColor: kPrimary),
//                                           onPressed: () async {
//                                             try {
//                                               Navigator.pop(context);
//                                               isSending = true;
//                                               setState(() {});
//                                               var result =
//                                                   await walletService.sendFunds(
//                                                       email: user!.email
//                                                           .validate(),
//                                                       amount: int.parse(
//                                                           amountController
//                                                               .text),
//                                                       myId: userController
//                                                           .userId.value);
//                                               if (result) {
//                                                 toast("Transfer successful");
//                                                 emailController.clear();
//                                                 amountController.clear();
//                                               }
//                                             } finally {
//                                               isSending = false;
//                                               setState(() {});
//                                             }
//                                           },
//                                           child: Text(
//                                             "Proceed",
//                                             style:
//                                                 primaryTextStyle(color: white),
//                                           ),
//                                         ),
//                                       ],
//                                     );
//                                   });
//                             } else {
//                               toast("User not found");
//                             }
//                           } finally {
//                             isSending = false;
//                             setState(() {});
//                           }
//                         }
//                       },
//                       width: double.infinity,
//                       color: kPrimary,
//                       text: "Proceed",
//                       textColor: white,
//                     )
//             ],
//           ),
//         )),
//       ),
//     );
//   }
// }
