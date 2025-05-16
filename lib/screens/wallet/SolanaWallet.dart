import 'package:flutter/material.dart';
import 'package:instant_doctor/component/snackBar.dart';
import 'package:instant_doctor/main.dart';
import 'package:instant_doctor/screens/home/Root.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/backButton.dart';
import '../../constant/color.dart';

class Assets {
  String name;
  String label;
  double amount;
  String image;
  Assets({
    required this.name,
    required this.label,
    required this.amount,
    required this.image,
  });
}

class Adapters {
  String name;
  double amount;
  String image;
  Adapters({
    required this.name,
    required this.amount,
    required this.image,
  });
}

class SolanaScreen extends StatefulWidget {
  const SolanaScreen({super.key});

  @override
  State<SolanaScreen> createState() => _SolanaScreenState();
}

class _SolanaScreenState extends State<SolanaScreen> {
  List<Assets> myAssets = [
    Assets(name: "USDC", label: 'usdc', amount: 5, image: "usdc.png"),
    Assets(name: "USDT", label: 'usdt', amount: 15, image: "usdt.png"),
    Assets(name: "Solana", label: 'sol', amount: 0.1, image: "solana2.png"),
  ];
  List<Adapters> myAdapters = [
    Adapters(name: "Solflare", amount: 0, image: "solflare.png"),
    Adapters(name: "Phantom", amount: 0, image: "phantom.png"),
    // Adapters(name: "MetaMask", amount: 0, image: "metamask.png"),
  ];

  bool isConnected = false;
  bool isLoading = false;
  handleConnect() async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: kPrimary,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Select Preferred Solana Wallet",
                style: boldTextStyle(
                  size: 14,
                  color: white,
                ),
              ),
              for (int x = 0; x < myAdapters.length; x++)
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  padding: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: white,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 50,
                        height: 50,
                        child:
                            Image.asset("assets/images/${myAdapters[x].image}"),
                      ),
                      10.width,
                      Expanded(
                        child: Text(
                          myAdapters[x].name,
                          style: boldTextStyle(
                            size: 14,
                            color: white,
                          ),
                        ),
                      )
                    ],
                  ),
                ).onTap(() async {
                  isLoading = true;
                  setState(() {});
                  finish(context);
                  isConnected = !isConnected;
                  await Future.delayed(Duration(seconds: 5));
                  isLoading = false;
                  setState(() {});
                })
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  backButton(context),
                  Text(
                    "Wallet",
                    style: boldTextStyle(
                      size: 16,
                      color: kPrimary,
                    ),
                  ),
                  Container(),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: kPrimary,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.wallet,
                      color: white,
                    ),
                    5.width,
                    Text(
                      "Connect Wallet",
                      style: boldTextStyle(
                        color: white,
                      ),
                    ),
                    10.width,
                  ],
                ),
              ).center().onTap(() {
                handleConnect();
              }).visible(!isConnected),
              10.height,
              isLoading
                  ? Loader().center()
                  : Container(
                      width: double.infinity,
                      height: 150,
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: kPrimary,
                        image: DecorationImage(
                          image: AssetImage(
                            "assets/images/sol_bg.png",
                          ),
                          fit: BoxFit.cover,
                          opacity: 0.2,
                        ),
                      ),
                      child: isConnected
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Balance",
                                  style: primaryTextStyle(
                                    size: 14,
                                    color: white,
                                  ),
                                ),
                                Text(
                                  "\$37.1",
                                  style: boldTextStyle(
                                    size: 40,
                                    color: white,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              "No wallet connected",
                              textAlign: TextAlign.center,
                              style: boldTextStyle(size: 14, color: white),
                            ).center(),
                    ),
              10.height,
              Text(
                "Assets",
                style: boldTextStyle(
                  size: 14,
                ),
              ).visible(isConnected && !isLoading),
              10.height,
              Column(
                children: [
                  for (int x = 0; x < myAssets.length; x++)
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: kPrimary,
                        ),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            height: 50,
                            width: 50,
                            child: Image.asset(
                              "assets/images/${myAssets[x].image}",
                              fit: BoxFit.cover,
                            ),
                          ).paddingAll(10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                myAssets[x].name,
                                style: boldTextStyle(
                                  size: 14,
                                ),
                              ),
                              Text(
                                "${myAssets[x].amount.toString()} ${myAssets[x].label}",
                                style: secondaryTextStyle(
                                  size: 12,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ).onTap(() {
                      successSnackBar(
                        title: "Payment Successful",
                      );
                      settingsController.selectedIndex.value = 0;
                      Root().launch(context);
                    }),
                ],
              ).visible(isConnected && !isLoading),
            ],
          ),
        ),
      ),
    );
  }
}
