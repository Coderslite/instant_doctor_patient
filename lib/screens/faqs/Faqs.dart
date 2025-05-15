import 'package:accordion/accordion.dart';
import 'package:accordion/controllers.dart';
import 'package:flutter/material.dart';
import 'package:instant_doctor/component/backButton.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:nb_utils/nb_utils.dart';

class FaqsScreen extends StatefulWidget {
  const FaqsScreen({super.key});

  @override
  State<FaqsScreen> createState() => _FaqsScreenState();
}

class _FaqsScreenState extends State<FaqsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  backButton(context),
                  Text(
                    "FAQ",
                    style: boldTextStyle(),
                  ),
                  Text("       "),
                ],
              ),
              Expanded(
                child: Accordion(
                  headerBorderColor: Colors.blueGrey,
                  headerBorderColorOpened: Colors.transparent,
                  // headerBorderWidth: 1,
                  headerBackgroundColorOpened: kPrimary,
                  contentBackgroundColor: context.scaffoldBackgroundColor,
                  contentBorderColor: kPrimary,
                  contentBorderWidth: 3,
                  contentHorizontalPadding: 20,
                  scaleWhenAnimating: true,
                  openAndCloseAnimation: true,
                  headerPadding:
                      const EdgeInsets.symmetric(vertical: 7, horizontal: 15),
                  sectionOpeningHapticFeedback: SectionHapticFeedback.heavy,
                  sectionClosingHapticFeedback: SectionHapticFeedback.light,
                  children: [
                    AccordionSection(
                      isOpen: true,
                      contentVerticalPadding: 20,
                      header: Text(
                        'What is Instant Doctor, and how does it work?',
                        style: primaryTextStyle(),
                      ),
                      content: Text(
                        "Instant Doctor is a telemedicine app designed to provide users with convenient access to medical care, health management tools, and wellness resources. The app allows users to book virtual consultations with licensed healthcare professionals, upload and review laboratory results, track medications, and access personalized health tips. Our platform aims to bridge the gap between patients and healthcare providers, making it easier to manage your health from anywhere.ß",
                        style: primaryTextStyle(),
                      ),
                    ),
                    AccordionSection(
                      isOpen: true,
                      contentVerticalPadding: 20,
                      header: Text(
                        'Simple Text',
                        style: primaryTextStyle(),
                      ),
                      content: Text(
                        "loremIpsum",
                        style: primaryTextStyle(),
                      ),
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
