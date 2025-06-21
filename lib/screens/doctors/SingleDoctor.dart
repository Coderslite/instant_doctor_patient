// ignore_for_file: file_names, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/component/ProfileImage.dart';
import 'package:instant_doctor/component/backButton.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/controllers/BookingController.dart';
import 'package:instant_doctor/screens/appointment/AppointmentPricing.dart';
import 'package:instant_doctor/screens/appointment/NewAppointment.dart';
import 'package:instant_doctor/screens/profile/medical/MedicalData.dart';
import 'package:instant_doctor/services/GetUserId.dart';
import 'package:ionicons/ionicons.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../component/DoctorDetail.dart';
import '../../models/UserModel.dart';
import '../../services/ReviewService.dart';

class SingleDoctorScreen extends StatefulWidget {
  final UserModel doctor;
  const SingleDoctorScreen({super.key, required this.doctor});

  @override
  State<SingleDoctorScreen> createState() => _SingleDoctorScreenState();
}

class _SingleDoctorScreenState extends State<SingleDoctorScreen> {
  final reviewService = Get.find<ReviewService>();

  bool isOpened = false;
  var controller = PanelController();
  BookingController bookingController = Get.put(BookingController());
  bool isLoading = true; // Add a loading state
  int totalReview = 0;
  @override
  void initState() {
    super.initState();
    // handleCheck();
  }

  handleGetTotalReview() async {
    totalReview = await reviewService.getDoctorReviewsCount(
        docId: widget.doctor.id.validate());
    setState(() {});
  }

  // Use didChangeDependencies to perform asynchronous tasks
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // handleCheck();
    handleGetTotalReview();
  }

  handleCheck() async {
    if (bookingController.price.value < 1) {
      await Future.delayed(const Duration(seconds: 1));
      // Launch screen only if it's not already loading
      if (mounted && isLoading) {
        setState(() {
          isLoading = false;
        });
        showConfirmDialogCustom(context,
            title: "Please select an appointment package to continue",
            positiveText: "Proceed",
            negativeText: "Cancel", onAccept: (v) {
          const AppointmentPricingScreen(fromDocScreen: true).launch(context);
        });
        // toast();
      }
    }
  }

  handleGetPricing() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          if (isOpened == false) {
            return true;
          } else {
            setState(() {
              isOpened = false;
              controller.close();
            });
            return false;
          }
        },
        child: SlidingUpPanel(
            controller: controller,
            isDraggable: false,
            minHeight: MediaQuery.of(context).size.height / 1.5,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
            color: context.cardColor,
            backdropColor: context.cardColor,
            onPanelClosed: () {
              isOpened = false;
              setState(() {});
            },
            onPanelOpened: () {
              isOpened = true;
              setState(() {});
            },
            parallaxEnabled: true,
            panel: Column(
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: context.cardColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            60.height,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                backButton(context),
                                Text(
                                  "Doctor Details",
                                  style: boldTextStyle(
                                    size: 18,
                                  ),
                                ),
                                const Text("        "),
                              ],
                            ),
                            10.height,
                            Row(
                              children: [
                                Stack(
                                  alignment: Alignment.topCenter,
                                  children: [
                                    profileImage(widget.doctor, 100, 100,
                                        context: context),
                                    Positioned(
                                      right: 10,
                                      top: 10,
                                      child: Image.asset(
                                          "assets/images/verified.png"),
                                    )
                                  ],
                                ),
                                10.width,
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${widget.doctor.firstName} ${widget.doctor.lastName}",
                                      style: boldTextStyle(size: 20),
                                    ),
                                    Text(
                                      widget.doctor.speciality.validate(),
                                      style: secondaryTextStyle(
                                        size: 14,
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ).visible(
                          isOpened,
                        ),
                        30.height,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            docDetail(context, "Address",
                                "${widget.doctor.state}", "address.png"),
                            docDetail(
                                context,
                                "Experience",
                                "${widget.doctor.experience} Years",
                                "experience.png"),
                            docDetail(
                                context,
                                "4.5",
                                "$totalReview ${totalReview > 1 ? "Reviews" : "Review"}",
                                "rating.png"),
                          ],
                        ),
                        30.height,
                        Text(
                          "About Doctor",
                          style: secondaryTextStyle(size: 14),
                        ).center(),
                        // 10.height,
                        Divider(
                          color: dimGray.withOpacity(0.2),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 0),
                          // decoration: BoxDecoration(
                          //   color: context.cardColor,
                          //   borderRadius: BorderRadius.circular(10),
                          //   boxShadow: [
                          //     BoxShadow(
                          //       color: dimGray.withOpacity(0.2),
                          //       spreadRadius: 2,
                          //       blurRadius: 3,
                          //       offset: const Offset(0, 5),
                          //     ),
                          //   ],
                          // ),
                          child: Text(
                            "${widget.doctor.bio}",
                            style: primaryTextStyle(
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              //   StreamBuilder<UserModel>(
              //       stream: userService.getProfile(
              //           userId: userController.userId.value),
              //       builder: (context, snapshot) {
              //         if (snapshot.hasData) {
              //           var data = snapshot.data!;
              //           bool profileCompleted =
              //               data.bloodGroup.validate().isNotEmpty &&
              //                   data.height.validate().isNotEmpty &&
              //                   data.weight.validate().isNotEmpty &&
              //                   data.genotype.validate().isNotEmpty;
              //           return AppButton(
              //             text: !profileCompleted
              //                 ? "Please complete profile"
              //                 : "Book Appointment",
              //             onTap: () {
              //               !profileCompleted
              //                   ? const MedicalDataScreen().launch(context)
              //                   : NewAppointment(
              //                       docID: widget.doctor.id.validate(),
              //                     ).launch(context);
              //             },
              //             color: kPrimary,
              //             textColor: white,
              //             width: double.infinity,
              //           );
              //         }
              //         return Loader().center();
              //       }).paddingSymmetric(horizontal: 10, vertical: 10),ß
              ]
            ),
            body: Container(
              padding: const EdgeInsets.all(8),
              color: kPrimary,
              child: Column(
                children: [
                  30.height,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      backButton(context),
                      Text(
                        "Doctor Details",
                        style: boldTextStyle(
                          size: 18,
                          color: whiteColor,
                        ),
                      ),
                      const Text("        "),
                    ],
                  ),
                  10.height,
                  Row(
                    children: [
                      Stack(
                        alignment: Alignment.topCenter,
                        clipBehavior: Clip.none,
                        children: [
                          profileImage(widget.doctor, 100, 100,
                              context: context),
                          Positioned(
                            right: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: white,
                              ),
                              child: SizedBox(
                                width: 20,
                                child: Image.asset(
                                  "assets/images/verified.png",
                                  // color: white,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      10.width,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${widget.doctor.firstName} ${widget.doctor.lastName}",
                            style: boldTextStyle(color: white, size: 20),
                          ),
                          Text(
                            widget.doctor.speciality!,
                            style: secondaryTextStyle(size: 14, color: white),
                          ),
                          5.height,
                          Row(
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Ionicons.language,
                                    size: 16,
                                    color: white,
                                  ),
                                  Text(
                                    "English",
                                    style: secondaryTextStyle(
                                      size: 12,
                                      color: white,
                                    ),
                                  ),
                                ],
                              ),
                              5.width,
                              Row(
                                children: [
                                  Icon(
                                    Ionicons.language,
                                    size: 16,
                                    color: white,
                                  ),
                                  Text(
                                    "Yoruba",
                                    style: secondaryTextStyle(
                                      size: 12,
                                      color: white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  )
                ],
              ),
            )),
      ),
    );
  }
}
