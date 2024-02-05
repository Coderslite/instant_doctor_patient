import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/services/TransactionService.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/ProfileImage.dart';
import '../../component/card.dart';
import '../../component/eachTransaction.dart';
import '../../controllers/SettingController.dart';
import '../../controllers/UserController.dart';
import '../../main.dart';
import '../../models/UserModel.dart';
import '../../services/format_number.dart';
import '../../services/greetings.dart';
import 'fund_wallet/FundWallet.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final SettingsController settingsController = Get.find();

  TransactionService transactionService = TransactionService();
  UserController userController = Get.put(UserController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        bool isDarkMode = settingsController.isDarkMode.value;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StreamBuilder<UserModel>(
                        stream: userController.userId.isNotEmpty
                            ? userService.getProfile(
                                userId: userController.userId.value)
                            : null,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            var data = snapshot.data;
                            return Row(
                              children: [
                                profileImage(data, 40, 40),
                                10.width,
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      getGreeting(),
                                      style: primaryTextStyle(size: 14),
                                    ),
                                    Text(
                                      "${data!.firstName!} ${data.lastName!}",
                                      style: boldTextStyle(),
                                    ),
                                  ],
                                )
                              ],
                            );
                          }
                          return Container();
                        }),
                    SizedBox(
                      height: 50,
                      width: 50,
                      child: Image.asset(
                        "assets/images/logo.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      Future.delayed(Duration(seconds: 2));
                      return;
                    },
                    child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          10.height,
                          card(context),
                          10.height,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              walletOption("Top Up", "topup.png", () {
                                const FundWalletScreen().launch(context);
                              }),
                              walletOption(
                                "Transfer",
                                "transfer.png",
                                () {},
                              ),
                              walletOption(
                                "Receipt",
                                "receipt.png",
                                () {},
                              ),
                            ],
                          ).paddingSymmetric(
                            horizontal: 50,
                          ),
                          20.height,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Transaction History",
                                style: secondaryTextStyle(size: 14),
                              ),
                              Text(
                                "See all",
                                style: secondaryTextStyle(size: 14),
                              ),
                            ],
                          ),
                          20.height,
                          StreamBuilder(
                              stream: transactionService.getAllTransaction(
                                  userId: userController.userId.value),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  var transaction = snapshot.data;
                                  if (snapshot.data!.isEmpty) {
                                    return Center(
                                        child: Text(
                                      "No Transaction Yet",
                                      style: boldTextStyle(),
                                    ));
                                  } else {
                                    return Column(
                                      children: [
                                        for (int x = 0;
                                            x < snapshot.data!.length;
                                            x++)
                                          eachTransaction(
                                              transaction: transaction![x]),
                                      ],
                                    );
                                  }
                                }
                                return Center(
                                  child: CircularProgressIndicator(
                                    color: kPrimary,
                                  ),
                                );
                              })
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  walletOption(String name, String image, VoidCallback ontap) {
    return Column(
      children: [
        SizedBox(
          width: 40,
          child: Image.asset("assets/images/$image"),
        ),
        1.height,
        Text(
          name,
          style: boldTextStyle(
            color: kPrimary,
            size: 12,
          ),
        ),
      ],
    ).onTap(ontap);
  }
}
