import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/component/ProfileImage.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/controllers/BookingController.dart';
import 'package:instant_doctor/main.dart';
import 'package:instant_doctor/screens/appointment/AppointmentPricing.dart';
import 'package:instant_doctor/screens/doctors/BookAppointment.dart';
import 'package:instant_doctor/screens/profile/personal/PersonalProfile.dart';
import 'package:instant_doctor/services/GetUserId.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../component/DoctorDetail.dart';
import '../../component/IsOnline.dart';
import '../../constant/constants.dart';
import '../../models/UserModel.dart';

class SingleDoctorScreen extends StatefulWidget {
  final UserModel doctor;
  const SingleDoctorScreen({Key? key, required this.doctor}) : super(key: key);

  @override
  State<SingleDoctorScreen> createState() => _SingleDoctorScreenState();
}

class _SingleDoctorScreenState extends State<SingleDoctorScreen> {
  bool isOpened = false;
  var controller = PanelController();
  BookingController bookingController = Get.put(BookingController());
  bool isLoading = true; // Add a loading state

  @override
  void initState() {
    super.initState();
    handleCheck();
  }

  // Use didChangeDependencies to perform asynchronous tasks
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    handleCheck();
  }

  handleCheck() async {
    if (bookingController.price.value < 1) {
      await Future.delayed(const Duration(seconds: 1));
      // Launch screen only if it's not already loading
      if (mounted && isLoading) {
        setState(() {
          isLoading = false;
        });
        toast("please select appointment package");
        const AppointmentPricingScreen(fromDocScreen: true).launch(context);
      }
    }
  }

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
            maxHeight: MediaQuery.of(context).size.height,
            minHeight: MediaQuery.of(context).size.height - 250,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
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
            panel: Column(
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: context.cardColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: SingleChildScrollView(
                      physics: isOpened
                          ? const AlwaysScrollableScrollPhysics()
                          : const NeverScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              60.height,
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const BackButton(),
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
                                      Positioned(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(40),
                                            boxShadow: [
                                              BoxShadow(
                                                color: dimGray.withOpacity(0.2),
                                                blurRadius: 5.0,
                                                spreadRadius: 2.0,
                                                offset: const Offset(0, 5),
                                              ),
                                            ],
                                          ),
                                          child: profileImage(
                                              widget.doctor, 100, 100),
                                        ),
                                      ),
                                      Positioned(
                                        right: 10,
                                        top: 10,
                                        child: isOnline(
                                            widget.doctor.status == ONLINE),
                                      )
                                    ],
                                  ),
                                  10.width,
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                  context, "4.5", "35 reviews", "rating.png"),
                            ],
                          ),
                          30.height,
                          Text(
                            "About Doctor",
                            style: secondaryTextStyle(size: 18),
                          ).center(),
                          10.height,
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 20),
                            decoration: BoxDecoration(
                              color: context.cardColor,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: dimGray.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 3,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Text(
                              "${widget.doctor.bio}",
                              style: secondaryTextStyle(size: 14),
                            ),
                          ),
                          30.height,
                          Text(
                            "Working Hours",
                            style: secondaryTextStyle(size: 18),
                          ).center(),
                          10.height,
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 20),
                            decoration: BoxDecoration(
                              color: context.cardColor,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: dimGray.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 3,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (int x = 0;
                                    x <
                                        widget.doctor.workingHours
                                            .validate()
                                            .length;
                                    x++)
                                  Text(
                                    "${widget.doctor.workingHours.validate()[x]}",
                                    style: secondaryTextStyle(size: 14),
                                  ),
                              ],
                            ).visible(widget.doctor.workingHours
                                .validate()
                                .isNotEmpty),
                          ),
                          20.height,
                          StreamBuilder<UserModel>(
                              stream: userService.getProfile(
                                  userId: userController.userId.value),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  var data = snapshot.data!;
                                  bool profileCompleted = data.bloodGroup
                                          .validate()
                                          .isNotEmpty &&
                                      data.height.validate().isNotEmpty &&
                                      data.weight.validate().isNotEmpty &&
                                      data.dob != null &&
                                      data.genotype.validate().isNotEmpty &&
                                      data.phoneNumber.validate().isNotEmpty;
                                  return Obx(() {
                                    var d = bookingController.complain.value;
                                    return AppButton(
                                      text: !profileCompleted
                                          ? "Please complete profile"
                                          : bookingController.price > 0
                                              ? "Book Appointment"
                                              : "Select Package",
                                      onTap: () {
                                        !profileCompleted
                                            ? const PersonalProfileScreen()
                                                .launch(context)
                                            : bookingController.price > 0
                                                ? BookAppointmentScreen(
                                                    doctor: widget.doctor,
                                                  ).launch(context)
                                                : const AppointmentPricingScreen(
                                                        fromDocScreen: true)
                                                    .launch(context);
                                      },
                                      color: kPrimary,
                                      textColor: white,
                                      width: double.infinity,
                                    );
                                  });
                                }
                                return const CircularProgressIndicator()
                                    .center();
                              }),
                          20.height,
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
            body: Container(
              padding: const EdgeInsets.all(16),
              color: kPrimary,
              child: Column(
                children: [
                  30.height,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const BackButton(
                        color: white,
                      ),
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
                        children: [
                          Positioned(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40),
                                boxShadow: [
                                  BoxShadow(
                                    color: dimGray.withOpacity(0.5),
                                    blurRadius: 5.0,
                                    spreadRadius: 2.0,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: profileImage(widget.doctor, 100, 100),
                            ),
                          ),
                          Positioned(
                            right: 10,
                            top: 10,
                            child: isOnline(widget.doctor.status == ONLINE),
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
