import 'dart:async';

import 'package:flutter/material.dart';
import 'package:instant_doctor/component/AnimatedCard.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/screens/appointment/NewAppointment.dart';
import 'package:instant_doctor/screens/doctors/AllDoctors.dart';
import 'package:instant_doctor/screens/pharmacy/Pharmacies.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomeCard extends StatefulWidget {
  const HomeCard({super.key});

  @override
  State<HomeCard> createState() => _HomeCardState();
}

class _HomeCardState extends State<HomeCard> {
  var pageController = PageController(viewportFraction: 0.99, keepPage: false);
  Timer? timer;
  handleNext() {
    var index = pageController.page!.toInt();
    if (index == 1) {
      pageController.previousPage(
          duration: Duration(milliseconds: 500), curve: Curves.linearToEaseOut);
    } else {
      pageController.nextPage(
          duration: Duration(milliseconds: 500), curve: Curves.linearToEaseOut);
    }
  }

  handleInit() async {
    timer = Timer.periodic(Duration(seconds: 10), (v) {
      handleNext();
    });
  }

  @override
  void initState() {
    handleInit();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 210,
      child: Column(
        children: [
          Expanded(
            child: PageView(
              controller: pageController,
              clipBehavior: Clip.none,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: AnimatedCard(
                    color1: kPrimaryDark,
                    color2: const Color.fromRGBO(0, 174, 239, 1),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 40,
                                    child: Text(
                                      "Pharmacies",
                                      style: boldTextStyle(
                                        color: white,
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'Purchase drugs on our store and get it delivered to your doorstep',
                                    style: secondaryTextStyle(
                                        color: Colors.white, size: 12),
                                  ),
                                  const SizedBox(height: 20),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.white,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "Buy Now",
                                          style: boldTextStyle(
                                            color: Colors.white,
                                            size: 12,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Icon(
                                          Icons.add_shopping_cart,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  ).onTap(() {
                                    // MedicineHome().launch(context);
                                    PharmaciesScreen().launch(context);
                                  }),
                                ],
                              ),
                            ),
                            10.width,
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: white,
                              ),
                              child: Image.asset(
                                "assets/images/med.png",
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedCard(
                  color1: kPrimaryLight,
                  color2: kPrimaryDark,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 40,
                                  child: Text(
                                    "Talk to a doctor",
                                    style:
                                        boldTextStyle(size: 22, color: white),
                                  ),
                                ),
                                Text(
                                  'Schedule an appointment with our certified medical practitioner',
                                  style: secondaryTextStyle(
                                      color: Colors.white, size: 12),
                                ),
                                20.height,
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.white,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "Consult Now",
                                        style: boldTextStyle(
                                          color: Colors.white,
                                          size: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Icon(
                                        Icons.call,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ).onTap(() {
                                  // AllDoctorsScreen().launch(context);
                                  NewAppointment().launch(context);
                                }),
                              ],
                            ),
                          ),
                          20.width,
                          Container(
                            width: 80,
                            height: 150,
                            decoration: BoxDecoration(
                                // shape: BoxShape.circle,
                                // color: white,
                                ),
                            child: Image.asset(
                              "assets/images/cartoon_doc.png",
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          10.height,
          SmoothPageIndicator(
            controller: pageController,
            count: 2,
            effect: JumpingDotEffect(activeDotColor: kPrimary, dotHeight: 3),
          )
        ],
      ),
    );
  }
}
