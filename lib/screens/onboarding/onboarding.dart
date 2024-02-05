import 'package:flutter/material.dart';
import 'package:instant_doctor/screens/authentication/email_screen.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../constant/color.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  PageController controller = PageController();
  List images = [
    "onboardingpage1.png",
    "onboardingpage2.png",
    "onboardingpage3.png",
    "onboardingpage4.png",
  ];

  int index = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                PageView.builder(
                    controller: controller,
                    itemCount: images.length,
                    onPageChanged: (value) {
                      index = value;
                      setState(() {});
                    },
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage(
                                    "assets/images/${images[index]}"),
                                fit: BoxFit.cover)),
                      );
                    }),
                Positioned(
                    bottom: 90,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 3, horizontal: 5),
                      decoration: BoxDecoration(
                          color: kPrimaryLight,
                          borderRadius: BorderRadius.circular(20)),
                      child: SmoothPageIndicator(
                          controller: controller, // PageController

                          count: images.length,
                          effect: const ExpandingDotsEffect(
                              activeDotColor: kPrimary,
                              dotHeight: 5,
                              dotColor: kPrimaryLight), // your preferred effect
                          onDotClicked: (index) {
                            index = index;
                          }),
                    )),
                Positioned(
                  bottom: 10,
                  child: index + 1 == images.length
                      ? AppButton(
                          text: "Start",
                          onTap: () {
                            const EmailScreen().launch(context);
                          },
                        )
                      : SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CircleAvatar(
                                  backgroundColor: whiteColor,
                                  child: Image.asset(
                                    "assets/images/arrow_backward.png",
                                  ),
                                ).onTap(() {
                                  controller.animateToPage(index - 1,
                                      duration:
                                          const Duration(milliseconds: 500),
                                      curve: Curves.ease);
                                }).visible(index > 0),
                                CircleAvatar(
                                  backgroundColor: whiteColor,
                                  child: Image.asset(
                                    "assets/images/arrow_forward.png",
                                  ),
                                ).onTap(() {
                                  controller.animateToPage(index + 1,
                                      duration:
                                          const Duration(milliseconds: 500),
                                      curve: Curves.ease);
                                }).visible(index < images.length)
                              ],
                            ),
                          ),
                        ),
                ),
                Positioned(
                  top: 50,
                  right: 20,
                  child: Text(
                    "Skip",
                    style: boldTextStyle(),
                  ).onTap(() {
                    controller.animateToPage(images.length,
                        duration: const Duration(milliseconds: 10),
                        curve: Curves.ease);
                  }).visible(index + 1 < images.length),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
