import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/models/UserModel.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../component/ProfileImage.dart';
import '../../../main.dart';

class PersonalProfileScreen extends StatefulWidget {
  const PersonalProfileScreen({super.key});

  @override
  State<PersonalProfileScreen> createState() => _PersonalProfileScreenState();
}

class _PersonalProfileScreenState extends State<PersonalProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        bool isDarkMode = settingsController.isDarkMode.value;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const BackButton(
                        color: kPrimary,
                      ),
                      Text(
                        "Personal Information",
                        style: boldTextStyle(
                          size: 16,
                          color: kPrimary,
                        ),
                      ),
                      Container(),
                    ],
                  ),
                  1.height,
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      profileImage(UserModel(), 100, 100),
                      const Positioned(
                        child: Icon(
                          Icons.edit,
                          color: kPrimary,
                          size: 14,
                        ),
                      )
                    ],
                  ).center(),
                  30.height,
                  Text(
                    "Update Information",
                    style: secondaryTextStyle(
                      size: 14,
                    ),
                  ),
                  10.height,
                  profileOption("Email", "abraham@gmail.com"),
                  profileOption("Phone Number", "+2348145108521"),
                  profileOption("Marital Status", "Single"),
                  profileOption("Height", "6ft"),
                  profileOption("Blood Group", "O+"),
                  profileOption("Genotype", "AS"),
                  profileOption("Surgery History/Medical Condition", "None"),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  profileOption(String title, String description) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: boldTextStyle(size: 16),
                  ),
                  5.height,
                  Text(
                    description,
                    style: secondaryTextStyle(size: 14),
                  ),
                ],
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
              )
            ],
          ),
        ),
      ),
    );
  }
}
