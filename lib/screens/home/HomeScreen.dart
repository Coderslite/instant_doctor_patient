// // ignore_for_file: file_names

// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:instant_doctor/constant/color.dart';
// import 'package:instant_doctor/main.dart';
// import 'package:instant_doctor/models/NotificationModel.dart';
// import 'package:instant_doctor/models/UserModel.dart';
// import 'package:instant_doctor/screens/appointment/AppointmentPricing.dart';
// import 'package:instant_doctor/screens/doctors/AllDoctors.dart';
// import 'package:instant_doctor/screens/doctors/SingleDoctor.dart';
// import 'package:instant_doctor/screens/faqs/Faqs.dart';
// import 'package:instant_doctor/screens/healthtips/HealthTipsHome.dart';
// import 'package:instant_doctor/screens/lap_result/LabResult.dart';
// import 'package:instant_doctor/screens/medication/IntroMedicationTracker.dart';
// import 'package:instant_doctor/screens/notification/Notification.dart';
// import 'package:nb_utils/nb_utils.dart';
// import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

// import '../../component/ProfileImage.dart';
// import '../../component/eachDoctor.dart';
// import '../../component/eachService.dart';
// import '../../controllers/FirebaseMessaging.dart';
// import '../../controllers/SettingController.dart';
// import '../../models/category_model.dart';
// import '../../services/GetUserId.dart';
// import '../../services/greetings.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   final SettingsController settingsController = Get.find();

//   var notificationKey = GlobalKey();
//   var medicationKey = GlobalKey();
//   var labResultKey = GlobalKey();
//   var bookSessionKey = GlobalKey();
//   var healthKey = GlobalKey();
//   var womenKey = GlobalKey();
//   List<TargetFocus> targetList = [];
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//   }

//   @override
//   void initState() {
//     targetList.addAll([
//       TargetFocus(keyTarget: notificationKey, contents: [
//         TargetContent(
//             child: Column(
//           children: [
//             Text(
//               "Click to view notification",
//               style: primaryTextStyle(
//                 color: white,
//               ),
//             ),
//           ],
//         ))
//       ]),
//       TargetFocus(keyTarget: medicationKey, contents: [
//         TargetContent(
//             child: Column(
//           children: [
//             Text(
//               "Click to use our medication tracker system",
//               style: primaryTextStyle(
//                 color: white,
//               ),
//             ),
//           ],
//         ))
//       ]),
//       TargetFocus(keyTarget: labResultKey, contents: [
//         TargetContent(
//             child: Column(
//           children: [
//             Text(
//               "Upload your lab / medical result for professional interpretation ",
//               style: primaryTextStyle(
//                 color: white,
//               ),
//             ),
//           ],
//         ))
//       ]),
//       TargetFocus(keyTarget: healthKey, contents: [
//         TargetContent(
//             child: Column(
//           children: [
//             Text(
//               "Stay Update with Health Information",
//               style: primaryTextStyle(
//                 color: white,
//               ),
//             ),
//           ],
//         ))
//       ]),
//       TargetFocus(keyTarget: womenKey, contents: [
//         TargetContent(
//             child: Column(
//           children: [
//             Text(
//               "View Women Health related tips",
//               style: primaryTextStyle(
//                 color: white,
//               ),
//             ),
//           ],
//         ))
//       ]),
//     ]);
//     userController.isFirstTime.value == true
//         ? Future.delayed(Duration.zero, showTutorial)
//         : null;

//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     List<Categories> categories = [
//       Categories(
//         name: "Health Tips",
//         image: "health.png",
//         key: healthKey,
//         onTap: () {
//           const HealthTipsHome(
//             tipsType: "Health Tips",
//             image: "healthtips.png",
//           ).launch(context);
//         },
//       ),
//       Categories(
//         name: "Women Health",
//         image: "women_health.png",
//         key: womenKey,
//         onTap: () {
//           const HealthTipsHome(
//             tipsType: "Women Health",
//             image: "women_health2.jpg",
//           ).launch(context);
//         },
//       ),
//       Categories(
//         name: "Men Health",
//         image: "men_health.png",
//         onTap: () {
//           const HealthTipsHome(
//             tipsType: "Men Health",
//             image: "men_health2.jpg",
//           ).launch(context);
//         },
//       ),
//     ];
//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Obx(() {
//             return Column(
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     StreamBuilder<UserModel>(
//                         stream: userController.userId.isNotEmpty
//                             ? userService.getProfile(
//                                 userId: userController.userId.value)
//                             : null,
//                         builder: (context, snapshot) {
//                           if (snapshot.hasData) {
//                             var data = snapshot.data;
//                             return Row(
//                               children: [
//                                 profileImage(UserModel(), 40, 40,
//                                     context: context),
//                                 10.width,
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       getGreeting(),
//                                       style: primaryTextStyle(size: 14),
//                                     ),
//                                     Text(
//                                       "${data!.firstName!} ${data.lastName!}",
//                                       style: boldTextStyle(),
//                                     ),
//                                   ],
//                                 )
//                               ],
//                             );
//                           }
//                           return Container();
//                         }),
//                     Stack(
//                       alignment: Alignment.topRight,
//                       clipBehavior: Clip.none,
//                       children: [
//                         Icon(
//                           Icons.notifications_active,
//                           // color: kPrimary,
//                           key: notificationKey,
//                         ),
//                         Positioned(
//                             top: -4,
//                             right: 0,
//                             child: StreamBuilder<List<NotificationModel>>(
//                                 stream: notificationService
//                                     .getUserUnSeenNotifications(
//                                         userId: userController.userId.value),
//                                 builder: (context, snapshot) {
//                                   if (snapshot.hasData) {
//                                     var data = snapshot.data;
//                                     return Container(
//                                       padding: const EdgeInsets.all(3),
//                                       decoration: const BoxDecoration(
//                                           shape: BoxShape.circle,
//                                           color: fireBrick),
//                                       child: Text(
//                                         data!.length > 9
//                                             ? "9+"
//                                             : data.length.toString(),
//                                         textAlign: TextAlign.center,
//                                         style: boldTextStyle(
//                                             color: white, size: 10),
//                                       ).center(),
//                                     ).visible(data.isNotEmpty);
//                                   }
//                                   return const Text("");
//                                 }))
//                       ],
//                     ).onTap(() {
//                       const NotificationScreen().launch(context);
//                     })
//                   ],
//                 ),
//                 Expanded(
//                   child: SingleChildScrollView(
//                     physics: const BouncingScrollPhysics(),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // 30.height,
//                         // Text(
//                         //   "Stay",
//                         //   style: boldTextStyle(size: 30),
//                         // ),
//                         // Text(
//                         //   "Informed",
//                         //   style: boldTextStyle(
//                         //     letterSpacing: 6,
//                         //     size: 16,
//                         //   ),
//                         // ),
//                         20.height,
//                         Text(
//                           "Services",
//                           style: secondaryTextStyle(
//                             size: 14,
//                           ),
//                         ),
//                         SingleChildScrollView(
//                           scrollDirection: Axis.horizontal,
//                           physics: const BouncingScrollPhysics(),
//                           child: Row(
//                             children: [
//                               services(context, "medication_tracker.png",
//                                   "Medication Tracker", () {
//                                 // const MedicationTracker().launch(context);
//                                 const IntroMedicationTracker().launch(context);
//                               }, key: medicationKey),
//                               services(
//                                 context,
//                                 "upload.png",
//                                 "Upload Lab Result",
//                                 () {
//                                   const LabResultScreen().launch(context);
//                                   // showTutorial();
//                                 },
//                                 key: labResultKey,
//                               ),
//                               services(
//                                 context,
//                                 "book_session.png",
//                                 "Book Session",
//                                 () {
//                                   const AllDoctorsScreen().launch(context);
//                                 },
//                                 key: bookSessionKey,
//                               ),
//                             ],
//                           ),
//                         ),
//                         20.height,
//                         GestureDetector(
//                           child: Text(
//                             "Wellness Tips",
//                             style: secondaryTextStyle(size: 14),
//                           ),
//                         ),
//                         10.height,
//                         SingleChildScrollView(
//                           scrollDirection: Axis.horizontal,
//                           physics: const BouncingScrollPhysics(),
//                           child: Row(
//                             children: [
//                               for (int x = 0; x < categories.length; x++)
//                                 Container(
//                                   width: 180,
//                                   height: 120,
//                                   key: categories[x].key,
//                                   margin: const EdgeInsets.only(right: 15),
//                                   padding: const EdgeInsets.only(
//                                     left: 20,
//                                     right: 20,
//                                     bottom: 20,
//                                     top: 20,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     // color: categories[x].color,
//                                     image: DecorationImage(
//                                       alignment: Alignment.bottomLeft,
//                                       image: AssetImage(
//                                           "assets/images/${categories[x].image}"),
//                                       fit: BoxFit.cover,
//                                     ),
//                                     borderRadius: const BorderRadius.only(
//                                       topLeft: Radius.circular(30),
//                                       bottomRight: Radius.circular(30),
//                                     ),
//                                   ),
//                                   child: Column(
//                                     mainAxisAlignment: MainAxisAlignment.start,
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Expanded(
//                                         child: Text(
//                                           categories[x].name.toString(),
//                                           style: boldTextStyle(
//                                               color: white,
//                                               weight: FontWeight.bold,
//                                               size: 16),
//                                         ),
//                                       ),
//                                       Text(
//                                         "view",
//                                         style: secondaryTextStyle(
//                                           color: white,
//                                           decoration: TextDecoration.underline,
//                                           decorationColor: white,
//                                           size: 15,
//                                         ),
//                                       ).onTap(categories[x].onTap),
//                                     ],
//                                   ),
//                                 )
//                             ],
//                           ),
//                         ),
//                         30.height,
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               "Top Rated Doctors",
//                               style: secondaryTextStyle(size: 14),
//                             ),
//                             Text(
//                               "See all",
//                               style: secondaryTextStyle(size: 14),
//                             ).onTap(() {
//                               const AllDoctorsScreen().launch(context);
//                             }),
//                           ],
//                         ),
//                         10.height,
//                         StreamBuilder<List<UserModel>>(
//                             stream: doctorService.getTopDocs(),
//                             builder: (context, snapshot) {
//                               if (snapshot.hasData) {
//                                 var data = snapshot.data;
//                                 return Column(
//                                   children: [
//                                     for (int x = 0; x < data!.length; x++)
//                                       eachDoctor(
//                                               doctor: data[x], context: context)
//                                           .onTap(() {
//                                         SingleDoctorScreen(
//                                           doctor: data[x],
//                                         ).launch(context);
//                                       }),
//                                   ],
//                                 );
//                               }
//                               return const CircularProgressIndicator(
//                                 backgroundColor: kPrimary,
//                               ).center();
//                             })
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             );
//           }),
//         ),
//       ),
//     );
//   }

//   showTutorial() {
//     TutorialCoachMark(targets: targetList).show(context: context);
//     userController.handleFirstTimeUsed();
//   }
// }
