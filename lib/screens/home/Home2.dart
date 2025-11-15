import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/component/check_country.dart';
import 'package:instant_doctor/component/check_internet.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/controllers/TutorialCoachController.dart';
import 'package:instant_doctor/main.dart';
import 'package:instant_doctor/screens/anonymous/Anonymous.dart';
import 'package:instant_doctor/screens/appointment/NewAppointment.dart';
import 'package:instant_doctor/screens/home/AllServices.dart';
import 'package:instant_doctor/screens/lab_result/LabResult.dart';
import 'package:instant_doctor/screens/medication/MedicationTracker.dart';
import 'package:instant_doctor/screens/pharmacy/Pharmacies.dart';
import 'package:lottie/lottie.dart';
import 'package:nb_utils/nb_utils.dart' hide Marquee;
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../component/HomeCard.dart';
import '../../component/ProfileImage.dart';
import '../../models/NotificationModel.dart';
import '../../models/UserModel.dart';
import '../../services/DoctorService.dart';
import '../../services/GetUserId.dart';
import '../../services/NotificationService.dart';
import '../../services/greetings.dart';
import '../healthtips/HealthTipsHome.dart';
import '../notification/Notification.dart';
import 'TrialAvailable.dart';
import 'package:marquee/marquee.dart';

class Home2 extends StatefulWidget {
  const Home2({super.key});

  @override
  State<Home2> createState() => _Home2State();
}

class _Home2State extends State<Home2> with RouteAware {
  final notificationService = Get.find<NotificationService>();
  final doctorService = Get.find<DoctorService>();
  final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();
  Tutorialcoachcontroller tutorialcoachcontroller =
      Get.put(Tutorialcoachcontroller());
  late TutorialCoachMark tutorialCoachMark;
  @override
  void initState() {
    handleCheckFirstTimeTutorial();
    super.initState();
  }

  handleCheckFirstTimeTutorial() async {
    var prefs = await SharedPreferences.getInstance();

    bool isFirstTime = true;
    isFirstTime = prefs.getBool('isFirstTimeTutorial').validate();
    if (isFirstTime) {
      createTutorial();
      Future.delayed(Duration.zero, showTutorial);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _showTrialModal();
  }

  @override
  void didPush() {
    _showTrialModal();
  }

  void _showTrialModal() async {
    final prefs = await SharedPreferences.getInstance();
    int lastShown = prefs.getInt('lastTrialModalShown') ?? 0;
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    int threeDaysInMs = 3 * 24 * 60 * 60 * 1000; // 3 days in milliseconds

    if (settingsController.trialAvailable.value &&
        user != null &&
        currentTime - lastShown > threeDaysInMs) {
      await Future.delayed(Duration(seconds: 10));
      if (mounted && ModalRoute.of(context)!.isCurrent) {
        showDialog(
          context: context,
          builder: (context) => const TrialNotificationModal(),
        );
        await prefs.setInt('lastTrialModalShown', currentTime);
      }
    }
  }

  void createTutorial() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool('isFirstTimeTutorial', false);
    tutorialCoachMark = TutorialCoachMark(
      targets: tutorialcoachcontroller.createTargets(),
      colorShadow: kPrimaryDark,
      textSkip: "SKIP",
      hideSkip: true,
      paddingFocus: 20,
      opacityShadow: 0.8,
      imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      onFinish: () {
        print("Tutorial finished");
        setState(() {});
      },
      onClickTarget: (target) {
        print('Clicked target: $target');
      },
      onClickOverlay: (target) {
        print('Clicked overlay: $target');
      },
      onSkip: () {
        print("Tutorial skipped");
        return true;
      },
    );
  }

  void showTutorial() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      print("KeyButton1: ${tutorialcoachcontroller.keyButton1.currentContext}");
      print("KeyButton2: ${tutorialcoachcontroller.keyButton2.currentContext}");
      print("KeyButton3: ${tutorialcoachcontroller.keyButton3.currentContext}");
      var prefs = await SharedPreferences.getInstance();

      tutorialCoachMark.show(context: context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 8,
          ),
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                internetCheck(),
                countryCheck(),
                SizedBox(
                  height: 50,
                  child: Marquee(
                    text: settingsController.marquee.value,
                    style: boldTextStyle(color: darkOrange, size: 16),
                    scrollAxis: Axis.horizontal,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    blankSpace: 20.0,
                    velocity: 30.0,
                    // pauseAfterRound: Duration(seconds: 1),
                    startPadding: 10.0,
                    // accelerationDuration: Duration(seconds: 1),
                    // accelerationCurve: Curves.linear,
                    // decelerationDuration: Duration(milliseconds: 500),
                    // decelerationCurve: Curves.easeOut,
                  ),
                ).visible(settingsController.showMarquee.value),
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
                                      style: boldTextStyle(size: 18),
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
                                        style: boldTextStyle(
                                            color: white, size: 10),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Healthcare Services",
                      style: primaryTextStyle(size: 14),
                    ),
                    Row(
                      children: [
                        Text(
                          "view all",
                          style: primaryTextStyle(
                            size: 14,
                          ),
                        ),
                        5.width,
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: kPrimary,
                        )
                      ],
                    ).onTap(() {
                      AllServicesScreen().launch(context);
                    })
                  ],
                ),
                15.height,
                StaggeredGrid.count(
                  crossAxisCount: 4,
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 5,
                  children: [
                    StaggeredGridTile.count(
                      crossAxisCellCount: 2,
                      mainAxisCellCount: 3,
                      key: tutorialcoachcontroller.keyButton1,
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
                                  "Talk to a doctor",
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
                        NewAppointment().launch(context);
                      }),
                    ),
                    StaggeredGridTile.count(
                      crossAxisCellCount: 2,
                      mainAxisCellCount: 2,
                      key: tutorialcoachcontroller.keyButton2,
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
                                  "Interpret Lab Result",
                                  style: boldTextStyle(
                                    size: 14,
                                  ),
                                ),
                                Text(
                                  "Upload lab result for instant interpretation",
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
                                child: Lottie.asset(
                                  "assets/lottie/lottie5.json",
                                  fit: BoxFit.fitHeight,
                                  width: 30,
                                  height: 100,
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
                      mainAxisCellCount: 2,
                      key: tutorialcoachcontroller.keyButton3,
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
                                child: Lottie.asset(
                                  'assets/lottie/lottie4.json',
                                  fit: BoxFit.contain,
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
                                  "Pharmacies",
                                  style: boldTextStyle(
                                    size: 14,
                                  ),
                                ),
                                Text(
                                  "Order drug from the nearest pharmacy",
                                  style: secondaryTextStyle(
                                    size: 10,
                                  ),
                                ),
                              ],
                            ).paddingAll(10),
                            Expanded(
                              child: SizedBox(
                                child: Image.asset(
                                  'assets/images/pharmacy.png',
                                  width: 150,
                                  height: 150,
                                  fit: BoxFit.contain,
                                ),
                              ).paddingAll(10),
                            )
                          ],
                        ),
                      ).onTap(() {
                        PharmaciesScreen().launch(context);
                        // QuestionAnswerScreen().launch(context);
                      }),
                    ),
                    StaggeredGridTile.count(
                      crossAxisCellCount: 2,
                      mainAxisCellCount: 1,
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
                                  settingsController.anonymous.value
                                      ? "Anonymous"
                                      : "Health Tips",
                                  style: boldTextStyle(
                                    size: 14,
                                  ),
                                ),
                                Text(
                                  settingsController.anonymous.value
                                      ? "Send anonymous Message"
                                      : "Learn more about your health",
                                  style: secondaryTextStyle(
                                    size: 10,
                                  ),
                                ),
                              ],
                            ).paddingAll(10),
                            Expanded(
                              child: SizedBox(
                                width: double.infinity,
                                child: Lottie.asset(
                                  'assets/lottie/lottie3.json',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            )
                          ],
                        ),
                      ).onTap(() {
                        settingsController.anonymous.value
                            ? QuestionAnswerScreen().launch(context)
                            : HealthTipsHome().launch(context);
                      }),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
