// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/constant/constants.dart';
import 'package:instant_doctor/controllers/UserController.dart';
import 'package:instant_doctor/main.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../component/dialpad.dart';
import '../../../controllers/PaymentController.dart';
import '../../../services/caluculate_fontsize.dart';
import '../../../services/format_number.dart';

class FundWalletScreen extends StatefulWidget {
  const FundWalletScreen({super.key});

  @override
  State<FundWalletScreen> createState() => _FundWalletScreenState();
}

class _FundWalletScreenState extends State<FundWalletScreen> {
  PaymentController paymentController = Get.put(PaymentController());
  bool decimalPointPressed = false; // Flag to track decimal point
  String email = '';
  UserController userController = Get.put(UserController());

  handleGetEmail() async {
    var res =
        await userService.getProfileById(userId: userController.userId.value);
    email = res.email!;
    setState(() {});
  }

  @override
  void dispose() {
    paymentController.amount.value = '0';
    super.dispose();
  }

  var publicKey = PaystackKey.publicKey;
  final plugin = PaystackPlugin();

  @override
  void initState() {
    super.initState();
    handleGetEmail();
    plugin.initialize(publicKey: publicKey);
  }

  makePayment(
    BuildContext context1,
  ) async {
    Charge charge = Charge()
      ..amount = double.parse(paymentController.amount.value).toInt() * 100
      ..reference = 'ref ${DateTime.now().microsecondsSinceEpoch}'
      // or ..accessCode = _getAccessCodeFrmInitialization()
      ..currency = userController.currency.value
      ..email = email;

    CheckoutResponse response = await plugin.checkout(context1,
        method: CheckoutMethod.card, // Defaults to CheckoutMethod.selectable
        charge: charge,
        fullscreen: true,
        hideEmail: true,
        logo: SizedBox(
          width: 70,
          height: 70,
          child: Image.asset(
            "assets/images/logo.png",
            fit: BoxFit.cover,
          ),
        ));
    if (response.status) {
      paymentController.handleTopUp(context);
    } else {
      toast("payment was not success");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/thumbnail1.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const BackButton(),
                    Text(
                      "Fund Wallet",
                      style: boldTextStyle(size: 18),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: context.primaryColor),
                      ),
                      child: Row(
                        children: [
                          Text(
                            userController.currency.value,
                            style: primaryTextStyle(),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userController.currency.value,
                            style: secondaryTextStyle(
                              size: 14,
                              // color: kPrimary,
                            ),
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              formatAmount(
                                  int.parse(paymentController.amount.value)),
                              overflow: TextOverflow.ellipsis,
                              style: boldTextStyle(
                                size: calculateFontSize(
                                    paymentController.amount.value.length),
                                color: kPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                10.height,
                Expanded(
                  flex: 3,
                  child: CalculatorDialpad(
                    onDeletePressed: () {
                      // Handle delete button press
                      if (paymentController.amount.value.isNotEmpty &&
                          paymentController.amount.value != '0') {
                        String lastChar = paymentController.amount.value
                            .substring(
                                paymentController.amount.value.length - 1);

                        if (lastChar == '.') {
                          decimalPointPressed =
                              false; // Reset the flag if deleting a decimal point
                        }
                        paymentController.amount.value =
                            paymentController.amount.value.substring(
                                0, paymentController.amount.value.length - 1);
                        if (paymentController.amount.isEmpty) {
                          paymentController.amount.value = '0';
                        }
                        setState(() {});
                      }
                    },
                    onDigitPressed: (String digit) {
                      // Handle digit button press
                      if (digit == '.') {
                        // Check if decimal point is already pressed
                        if (!decimalPointPressed) {
                          paymentController.amount.value += digit;
                          decimalPointPressed = true; // Set the flag
                          setState(() {});
                        }
                      } else {
                        if (paymentController.amount.value == '0' &&
                            digit != '.') {
                          paymentController.amount.value = digit;
                        } else {
                          paymentController.amount.value += digit;
                        }
                        setState(() {});
                      }
                    },
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: kPrimary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "Next",
                    style: primaryTextStyle(color: white),
                  ).center(),
                ).onTap(() {
                  makePayment(context);
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
