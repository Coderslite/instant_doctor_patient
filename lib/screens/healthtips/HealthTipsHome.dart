import 'package:flutter/material.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/main.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../component/Accordion.dart';

class HealthTipsHome extends StatefulWidget {
  final String tipsType;
  final String image;
  const HealthTipsHome(
      {super.key, required this.tipsType, required this.image});

  @override
  State<HealthTipsHome> createState() => _HealthTipsHomeState();
}

class _HealthTipsHomeState extends State<HealthTipsHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          if (settingsController.panelOpened == false) {
            return true;
          } else {
            setState(() {
              settingsController.panelOpened = false;
              settingsController.panelController.close();
            });
            return false;
          }
        },
        child: SlidingUpPanel(
          controller: settingsController.panelController,
          onPanelOpened: () {
            setState(() {
              settingsController.panelOpened = true;
            });
          },
          onPanelClosed: () {
            setState(() {
              settingsController.panelOpened = false;
            });
          },
          maxHeight: MediaQuery.of(context).size.height,
          minHeight: MediaQuery.of(context).size.height / 1.6,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          color: context.cardColor,
          collapsed: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Pull Up",
                      style: TextStyle(
                        fontFamily: 'RedHatDisplay',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0XFF8A99B1),
                      ),
                    ).onTap(() {
                      settingsController.panelController.open();
                    }),
                    Icon(
                      Icons.arrow_upward,
                      size: 14,
                      color: Color(0XFF8A99B1),
                    )
                  ],
                )
              ],
            ),
          ),
          panel: Padding(
            padding: const EdgeInsets.only(top: 20, left: 5, right: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                40.height,
                Text(
                  widget.tipsType,
                  style: boldTextStyle(
                    color: kPrimary,
                    size: 22,
                  ),
                ).paddingLeft(10),
                10.height,
                Expanded(
                  child: RefreshIndicator(
                   onRefresh: () async {
                      Future.delayed(Duration(seconds: 2));
                      return;
                    },
                    child: ListView.builder(
                        itemCount: 20,
                        physics: settingsController.panelOpened
                            ? BouncingScrollPhysics()
                            : NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return widget.tipsType == 'FAQ'
                              ? healthTipAccordion()
                              : healthTipCard();
                        }),
                  ),
                )
              ],
            ),
          ),
          body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/${widget.image}"),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              children: [
                90.height,
                Text(
                  widget.tipsType == 'FAQ'
                      ? 'Frequently Asked Questions'
                      : widget.tipsType,
                  textAlign: TextAlign.center,
                  style: boldTextStyle(size: 32, color: white),
                ).center(),
              ],
            ).center(),
          ),
        ),
      ),
    );
  }

  Accordion healthTipAccordion() {
    return Accordion(
      items: [
        AccordionItem(
            header: Text(
              "What is Instant Doctor?",
              style: primaryTextStyle(size: 18),
            ),
            content: Column(
              children: [
                Text(
                  "Instant doctor is a mobile application built using flutter, node js ",
                  style: secondaryTextStyle(),
                ).paddingSymmetric(horizontal: 15, vertical: 10)
              ],
            ))
      ],
    );
  }

  Padding healthTipCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              SizedBox(
                height: 50,
                width: 50,
                child: Image.asset(
                  "assets/images/heart.png",
                  fit: BoxFit.cover,
                ),
              ),
              10.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Matters of the heart",
                      style: boldTextStyle(size: 15),
                    ),
                    10.height,
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.timelapse,
                              size: 10,
                            ),
                            5.width,
                            Text(
                              "3 mins ago",
                              style: secondaryTextStyle(size: 12),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.visibility,
                              size: 10,
                            ),
                            5.width,
                            Text(
                              "1k views",
                              style: secondaryTextStyle(size: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
