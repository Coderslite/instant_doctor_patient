import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/controllers/UserController.dart';
import 'package:instant_doctor/main.dart';
import 'package:instant_doctor/models/NotificationModel.dart';
import 'package:instant_doctor/models/UserModel.dart';
import 'package:instant_doctor/screens/doctors/AllDoctors.dart';
import 'package:instant_doctor/screens/doctors/SingleDoctor.dart';
import 'package:instant_doctor/screens/healthtips/HealthTipsHome.dart';
import 'package:instant_doctor/screens/medication/IntroMedicationTracker.dart';
import 'package:instant_doctor/screens/notification/Notification.dart';
import 'package:instant_doctor/services/UserService.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/ProfileImage.dart';
import '../../component/eachDoctor.dart';
import '../../component/eachService.dart';
import '../../controllers/SettingController.dart';
import '../../models/category_model.dart';
import '../../services/greetings.dart';
import '../lap_result/UploadLabResult.dart';
import '../medication/MedicationTracker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SettingsController settingsController = Get.find();
  UserController userController = Get.put(UserController());


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    List<Categories> categories = [
      Categories(
        name: "Health Tips",
        image: "health.png",
        onTap: () {
          const HealthTipsHome(
            tipsType: "Health Tips",
            image: "healthtips.png",
          ).launch(context);
        },
      ),
      Categories(
        name: "Women Health",
        image: "women_health.png",
        onTap: () {
          const HealthTipsHome(
            tipsType: "Women Health",
            image: "womentips.png",
          ).launch(context);
        },
      ),
      Categories(
        name: "Men Health",
        image: "men_health.png",
        onTap: () {
          const HealthTipsHome(
            tipsType: "Men Health",
            image: "mentips.png",
          ).launch(context);
        },
      ),
      Categories(
        name: "FAQ's",
        image: "faqs.png",
        onTap: () {
          const HealthTipsHome(
            tipsType: "FAQ",
            image: "faqtips.png",
          ).launch(context);
        },
      ),
    ];
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Obx(() {
            bool isDarkMode = settingsController.isDarkMode.value;
            return Column(
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
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        const Icon(
                          Icons.notifications_active,
                          color: kPrimary,
                        ).onTap(() {
                          const NotificationScreen().launch(context);
                        }),
                        Positioned(
                            top: -4,
                            right: 0,
                            child: StreamBuilder<List<NotificationModel>>(
                                stream: notificationService
                                    .getUserUnSeenNotifications(
                                        userId: userController.userId.value),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    var data = snapshot.data;
                                    return Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: fireBrick),
                                      child: Text(
                                        "${data!.length}",
                                        style: boldTextStyle(
                                            color: white, size: 10),
                                      ).center(),
                                    ).visible(data.isNotEmpty);
                                  }
                                  return const Text("");
                                }))
                      ],
                    )
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 30.height,
                        // Text(
                        //   "Stay",
                        //   style: boldTextStyle(size: 30),
                        // ),
                        // Text(
                        //   "Informed",
                        //   style: boldTextStyle(
                        //     letterSpacing: 6,
                        //     size: 16,
                        //   ),
                        // ),
                        20.height,
                        Text(
                          "Services",
                          style: secondaryTextStyle(size: 14, color: kPrimary),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: [
                              services(
                                context,
                                "medication_tracker.png",
                                "Medication Tracker",
                                () {
                                  // const MedicationTracker().launch(context);
                                  IntroMedicationTracker().launch(context);
                                },
                              ),
                              services(
                                context,
                                "upload.png",
                                "Upload Lab Result",
                                () {
                                  const UploadLabResult().launch(context);
                                },
                              ),
                              services(
                                context,
                                "book_session.png",
                                "Book Session",
                                () {
                                  const AllDoctorsScreen().launch(context);
                                },
                              ),
                            ],
                          ),
                        ),
                        20.height,
                        Text(
                          "Wellness Tips",
                          style: secondaryTextStyle(size: 14, color: kPrimary),
                        ),
                        10.height,
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: [
                              for (int x = 0; x < categories.length; x++)
                                Container(
                                  width: 180,
                                  height: 120,
                                  margin: const EdgeInsets.only(right: 15),
                                  padding: const EdgeInsets.only(
                                    left: 20,
                                    right: 20,
                                    bottom: 20,
                                    top: 20,
                                  ),
                                  decoration: BoxDecoration(
                                    // color: categories[x].color,
                                    image: DecorationImage(
                                      alignment: Alignment.bottomLeft,
                                      image: AssetImage(
                                          "assets/images/${categories[x].image}"),
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(30),
                                      bottomRight: Radius.circular(30),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          categories[x].name.toString(),
                                          style: boldTextStyle(
                                              color: white,
                                              weight: FontWeight.bold,
                                              size: 16),
                                        ),
                                      ),
                                      Text(
                                        "view",
                                        style: secondaryTextStyle(
                                          color: white,
                                          decoration: TextDecoration.underline,
                                          decorationColor: white,
                                          size: 15,
                                        ),
                                      ).onTap(categories[x].onTap),
                                    ],
                                  ),
                                )
                            ],
                          ),
                        ),
                        30.height,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Top Rated Doctors",
                              style:
                                  secondaryTextStyle(size: 14, color: kPrimary),
                            ),
                            Text(
                              "See all",
                              style: secondaryTextStyle(size: 14),
                            ).onTap(() {
                              const AllDoctorsScreen().launch(context);
                            }),
                          ],
                        ),
                        10.height,
                        StreamBuilder<List<UserModel>>(
                            stream: doctorService.getTopDocs(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                var data = snapshot.data;
                                return Column(
                                  children: [
                                    for (int x = 0; x < data!.length; x++)
                                      eachDoctor(doctor: data[x]).onTap(() {
                                        SingleDoctorScreen(
                                          doctor: data[x],
                                        ).launch(context);
                                      }),
                                  ],
                                );
                              }
                              return const CircularProgressIndicator(
                                backgroundColor: kPrimary,
                              ).center();
                            })
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
