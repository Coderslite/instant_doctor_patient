import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/screens/appointment/NewAppointment.dart';
import 'package:instant_doctor/screens/healthtips/HealthTipsHome.dart';
import 'package:instant_doctor/screens/lap_result/LabResult.dart';
import 'package:instant_doctor/screens/medication/MedicationTracker.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/HomeCard.dart';
import '../../component/ProfileImage.dart';
import '../../models/NotificationModel.dart';
import '../../models/UserModel.dart';
import '../../services/DoctorService.dart';
import '../../services/GetUserId.dart';
import '../../services/NotificationService.dart';
import '../../services/greetings.dart';
import '../notification/Notification.dart';

class Home2 extends StatefulWidget {
  const Home2({super.key});

  @override
  State<Home2> createState() => _Home2State();
}

class _Home2State extends State<Home2> {
  final notificationService = Get.find<NotificationService>();
  final doctorService = Get.find<DoctorService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 8,
        ),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StreamBuilder<UserModel>(
                      stream: userController.userId.value.isNotEmpty
                          ? userService.getProfile(
                              userId: userController.userId.value)
                          : null,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          var data = snapshot.data;
                          return Row(
                            children: [
                              profileImage(UserModel(), 40, 40,
                                  context: context),
                              10.width,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${data!.firstName!} ${data.lastName!}",
                                    style: boldTextStyle(),
                                  ),
                                  Text(
                                    getGreeting(),
                                    style: primaryTextStyle(size: 12),
                                  ),
                                ],
                              ),
                            ],
                          );
                        }
                        return Container();
                      }),
                  Stack(
                    alignment: Alignment.topRight,
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        Icons.notifications_active,
                        // color: kPrimary,
                        // key: notificationKey,
                      ),
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
                                    padding: const EdgeInsets.all(3),
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: fireBrick),
                                    child: Text(
                                      data!.length > 9
                                          ? "9+"
                                          : data.length.toString(),
                                      textAlign: TextAlign.center,
                                      style:
                                          boldTextStyle(color: white, size: 10),
                                    ).center(),
                                  ).visible(data.isNotEmpty);
                                }
                                return const Text("");
                              }))
                    ],
                  ).onTap(() {
                    const NotificationScreen().launch(context);
                  })
                ],
              ),
              10.height,
              HomeCard(),
              15.height,
              Text(
                "Instant Service",
                style: primaryTextStyle(size: 12),
              ),
              10.height,
              StaggeredGrid.count(
                crossAxisCount: 4,
                mainAxisSpacing: 5,
                crossAxisSpacing: 5,
                children: [
                  StaggeredGridTile.count(
                    crossAxisCellCount: 2,
                    mainAxisCellCount: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: context.cardColor,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Book Appointment",
                                style: boldTextStyle(
                                  size: 14,
                                ),
                              ),
                              Text(
                                "Schedule a session with a professional medical practitioner",
                                style: secondaryTextStyle(
                                  size: 10,
                                ),
                              ),
                            ],
                          ).paddingAll(10),
                          Expanded(
                            child: SizedBox(
                              width: double.infinity,
                              child: Image.asset(
                                "assets/images/man_doc.png",
                                fit: BoxFit.cover,
                                alignment: Alignment.topCenter,
                              ),
                            ),
                          )
                        ],
                      ),
                    ).onTap(() {
                      // AllDoctorsScreen().launch(context);
                      NewAppointment().launch(context);
                    }),
                  ),
                  StaggeredGridTile.count(
                    crossAxisCellCount: 2,
                    mainAxisCellCount: 2,
                    child: Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: context.cardColor,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Medication Tracker",
                                style: boldTextStyle(
                                  size: 14,
                                ),
                              ),
                              Text(
                                "Get instant Reminder to take your medication ",
                                style: secondaryTextStyle(
                                  size: 10,
                                ),
                              ),
                            ],
                          ).paddingAll(10),
                          Expanded(
                            child: SizedBox(
                              width: double.infinity,
                              height: 100,
                              child: Image.asset(
                                "assets/images/med_tracker2.png",
                                alignment: Alignment.bottomCenter,
                                fit: BoxFit.scaleDown,
                              ),
                            ),
                          )
                        ],
                      ),
                    ).onTap(() {
                      MedicationTracker().launch(context);
                    }),
                  ),
                  StaggeredGridTile.count(
                    crossAxisCellCount: 2,
                    mainAxisCellCount: 2,
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: context.cardColor,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Upload Lab Result",
                                style: boldTextStyle(
                                  size: 14,
                                ),
                              ),
                              Text(
                                "Upload lab result for instant interpretation ",
                                style: secondaryTextStyle(
                                  size: 10,
                                ),
                              ),
                            ],
                          ).paddingAll(10),
                          Expanded(
                            child: SizedBox(
                              width: double.infinity,
                              child: Image.asset(
                                "assets/images/lab_result2.png",
                                alignment: Alignment.topCenter,
                                fit: BoxFit.scaleDown,
                              ),
                            ),
                          )
                        ],
                      ),
                    ).onTap(() {
                      LabResultScreen().launch(context);
                    }),
                  ),
                  StaggeredGridTile.count(
                    crossAxisCellCount: 2,
                    mainAxisCellCount: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: context.cardColor,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Health Tips",
                                  style: boldTextStyle(
                                    size: 12,
                                  ),
                                ),
                                Text(
                                  "Learn More",
                                  style: secondaryTextStyle(
                                    size: 10,
                                  ),
                                ),
                              ],
                            ).paddingAll(10),
                          ),
                          Expanded(
                            child: SizedBox(
                              child: Image.asset(
                                "assets/images/health-tips2.png",
                                alignment: Alignment.bottomCenter,
                                fit: BoxFit.scaleDown,
                              ),
                            ).paddingAll(10),
                          )
                        ],
                      ),
                    ).onTap(() {
                      HealthTipsHome().launch(context);
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
