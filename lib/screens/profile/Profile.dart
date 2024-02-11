import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/controllers/AuthenticationController.dart';
import 'package:instant_doctor/services/GetUserId.dart';
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
                  StreamBuilder<UserModel>(
                      stream: userService.getProfile(
                          userId: userController.userId.value),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          var data = snapshot.data;
                          return profileImage(data, 100, 100).center();
                        }
                        return const CircleAvatar(
                          radius: 100,
                          child: Icon(Icons.person),
                        );
                      }),
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
                    child: StreamBuilder<UserModel>(
                        stream: userService.getProfile(
                            userId: userController.userId.value),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            var data = snapshot.data!;
                            bool profileCompleted =
                                data.bloodGroup.validate().isNotEmpty &&
                                    data.height.validate().isNotEmpty &&
                                    data.weight.validate().isNotEmpty &&
                                    data.dob != null &&
                                    data.genotype.validate().isNotEmpty &&
                                    data.phoneNumber.validate().isNotEmpty;

                            return !profileCompleted
                                ? Column(
                                    children: [
                                      Text(
                                        "Please complete your profile setup",
                                        style: primaryTextStyle(color: white),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          const PersonalProfileScreen()
                                              .launch(context);
                                        },
                                        child: Text(
                                          "Complete Profile ",
                                          style: primaryTextStyle(color: black),
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Name",
                                                style: secondaryTextStyle(
                                                    size: 14, color: white),
                                              ),
                                              Text(
                                                "${data.firstName} ${data.lastName}",
                                                style: boldTextStyle(
                                                    size: 14, color: white),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Age",
                                                style: secondaryTextStyle(
                                                    size: 14, color: white),
                                              ),
                                              Text(
                                                "${(DateTime.now().difference(data.dob!.toDate())).inDays ~/ 365} yrs",
                                                style: boldTextStyle(
                                                    size: 14, color: white),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Blood Group",
                                                style: secondaryTextStyle(
                                                    size: 14, color: white),
                                              ),
                                              Text(
                                                data.bloodGroup.validate(),
                                                style: boldTextStyle(
                                                    size: 14, color: white),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Weight",
                                                style: secondaryTextStyle(
                                                    size: 14, color: white),
                                              ),
                                              Text(
                                                "${data.weight.validate()} ft",
                                                style: boldTextStyle(
                                                    size: 14, color: white),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Height",
                                                style: secondaryTextStyle(
                                                    size: 14, color: white),
                                              ),
                                              Text(
                                                "${data.height.validate()} ft",
                                                style: boldTextStyle(
                                                    size: 14, color: white),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                          }
                          return const CircularProgressIndicator(
                            color: white,
                          ).center();
                        }),
                  ),
                  20.height,
                  profileOption("Personal Information", "personal information",
                      () {
                    const PersonalProfileScreen().launch(context);
                  }),
                  profileOption("Privacy", "Security Settings", () {}),
                  profileOption("Policy", "Read about our policy", () {}),
                  profileOption("Get Help", "Contact us", () {}),
                  profileOption("About Us", "About Instant Doctor", () {}),
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
        color: context.cardColor,
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
