import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/controllers/AuthenticationController.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/ProfileImage.dart';
import '../../main.dart';
import '../../models/UserModel.dart';
import '../../services/GetAppVersion.dart';
import '../settings/SettingScreen.dart';
import 'personal/PersonalProfile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String version = '';
  AuthenticationController authenticationController =
      Get.put(AuthenticationController());

  handleGetVersion() async {
    version = await getAppVersion();
    setState(() {});
  }

  @override
  void initState() {
    handleGetVersion();
    super.initState();
  }

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
                        "Profile",
                        style: boldTextStyle(
                          size: 16,
                          color: kPrimary,
                        ),
                      ),
                      const Icon(
                        Icons.settings,
                        color: kPrimary,
                      ).onTap(() {
                        const SettingScreen().launch(context);
                      })
                    ],
                  ),
                  1.height,
                  profileImage(UserModel(), 100, 100).center(),
                  10.height,
                  Container(
                    width: double.infinity,
                    height: 140,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: kPrimary,
                        borderRadius: BorderRadius.circular(20),
                        image: const DecorationImage(
                          image: AssetImage("assets/images/particle.png"),
                          fit: BoxFit.cover,
                          opacity: 0.4,
                        )),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Name",
                                  style: secondaryTextStyle(
                                      size: 14, color: white),
                                ),
                                Text(
                                  "Ossai Abraham",
                                  style: boldTextStyle(size: 14, color: white),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Age",
                                  style: secondaryTextStyle(
                                      size: 14, color: white),
                                ),
                                Text(
                                  "25yrs",
                                  style: boldTextStyle(size: 14, color: white),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Height",
                                  style: secondaryTextStyle(
                                      size: 14, color: white),
                                ),
                                Text(
                                  "6ft",
                                  style: boldTextStyle(size: 14, color: white),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Height",
                                  style: secondaryTextStyle(
                                      size: 14, color: white),
                                ),
                                Text(
                                  "6ft",
                                  style: boldTextStyle(size: 14, color: white),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Height",
                                  style: secondaryTextStyle(
                                      size: 14, color: white),
                                ),
                                Text(
                                  "6ft",
                                  style: boldTextStyle(size: 14, color: white),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  20.height,
                  profileOption("Personal Information", "personal information",
                      () {
                    PersonalProfileScreen().launch(context);
                  }),
                  profileOption("Privacy", "Security Settings", () {}),
                  profileOption("Policy", "Read about our policy", () {}),
                  profileOption("Get Help", "Contact us", () {}),
                  profileOption("About Us", "About Instant Doctor", () {}),
                  profileOption("Ringtone", "About Instant Doctor", () {
                    // handlePlayRingtone();
                  }),
                  profileOption("Ringtone", "About Instant Doctor", () {
                    // handleStopRingtone();
                  }),
                  10.height,
                  Text(
                    version,
                    style: secondaryTextStyle(),
                  ).center(),
                  10.height,
                  TextButton(
                    onPressed: () {
                      authenticationController.handleLogout(context);
                    },
                    child: Text(
                      "Sign Out",
                      style: boldTextStyle(color: redColor, size: 16),
                    ),
                  ).center(),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  profileOption(String title, String description, VoidCallback ontap) {
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
                    style: boldTextStyle(size: 14),
                  ),
                  5.height,
                  Text(
                    description,
                    style: secondaryTextStyle(size: 12),
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
    ).onTap(ontap);
  }
}
