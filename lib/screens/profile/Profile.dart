import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/component/AnimatedCard.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/controllers/AuthenticationController.dart';
import 'package:instant_doctor/screens/profile/about/About.dart';
import 'package:instant_doctor/screens/profile/medical/MedicalData.dart';
import 'package:instant_doctor/screens/profile/wallet_setup/WalletSetup.dart';
import 'package:instant_doctor/services/GetUserId.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/ProfileImage.dart';
import '../../controllers/ReferController.dart';
import '../../main.dart';
import '../../models/UserModel.dart';
import '../../services/GetAppVersion.dart';
import '../refer/Refer.dart';
import '../settings/SettingScreen.dart';
import 'help/Help.dart';
import 'personal/PersonalProfile.dart';
import 'policy/Policy.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String version = '';
  AuthenticationController authenticationController =
      Get.put(AuthenticationController());
  ReferralController referralController = Get.put(ReferralController());

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
        // ignore: unused_local_variable
        bool isDarkMode = settingsController.isDarkMode.value;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // backButton(context),
                      Container(),
                      Text(
                        "Profile",
                        style: boldTextStyle(
                          size: 18,
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
                  10.height,
                  StreamBuilder<UserModel>(
                      stream: userService.getProfile(
                          userId: userController.userId.value),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          var data = snapshot.data!;
                          return profileImage(UserModel(), 100, 100,
                                  context: context)
                              .center();
                        }
                        return const CircleAvatar(
                          radius: 100,
                          child: Icon(Icons.person),
                        );
                      }),
                  10.height,
                  AnimatedCard(
                    
                    color1: kPrimary,
                    color2: kPrimaryDark,
                    child: StreamBuilder<UserModel>(
                        stream: userService.getProfile(
                            userId: userController.userId.value),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            var data = snapshot.data!;
                            bool profileCompleted = data.dob != null &&
                                data.address.validate().isNotEmpty;
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
                                      40.height,
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
                  profileOption("Personal Information",
                      "manage your personal information", () {
                    const PersonalProfileScreen().launch(context);
                  }),
                  profileOption(
                      "Medical Data", "manage your medical information", () {
                    const MedicalDataScreen().launch(context);
                  }),
                  profileOption("Wallet Setup", "Please Complete Wallet Setup",
                      () {
                    const WalletSetupScreen().launch(context);
                  }).visible(userController.currency.isEmpty),
                  profileOption("Refer 💶", "Refer and earn bonus", () {
                    const ReferScreen().launch(context);
                  }),
                  profileOption("Privacy", "Security Settings", () {}),
                  profileOption("Policy", "Read about our policy", () {
                    const PolicyScreen().launch(context);
                  }),
                  profileOption("Get Help", "Contact us", () {
                    const HelpScreen().launch(context);
                  }),
                  profileOption("About Us", "About Instant Doctor", () {
                    AboutScreen(
                      version: version,
                    ).launch(context);
                  }),
                  10.height,
                  Text(
                    version,
                    style: secondaryTextStyle(),
                  ).center(),
                  // 10.height,
                  TextButton(
                    onPressed: () {
                      authenticationController.handleLogout(context);
                    },
                    child: Text(
                      "Sign Out",
                      style: boldTextStyle(color: redColor, size: 16),
                    ),
                  ).center(),
                  20.height,
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Container profileOption(
      String title, String description, VoidCallback ontap) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(10),
      ),
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
      ).onTap(ontap),
    );
  }
}
