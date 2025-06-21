// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/component/ProfileImage.dart';
import 'package:instant_doctor/component/snackBar.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/constant/constants.dart';
import 'package:instant_doctor/controllers/ChatController.dart';
import 'package:instant_doctor/controllers/UserController.dart';
import 'package:instant_doctor/main.dart';
import 'package:instant_doctor/models/AppointmentModel.dart';
import 'package:instant_doctor/models/UserModel.dart';
import 'package:instant_doctor/screens/appointment/reports/CreateReport.dart';
import 'package:instant_doctor/screens/doctors/SingleDoctor.dart';
import 'package:instant_doctor/screens/profile/help/Help.dart';
import 'package:instant_doctor/services/UserService.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
// import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

import '../../component/IsOnline.dart';
import '../../component/TimeRemaining.dart';
import '../../controllers/BookingController.dart';
import '../../controllers/PaymentController.dart';
import '../../services/AppointmentService.dart';
import '../../services/DoctorService.dart';
import '../../services/SecurityHelper.dart';
import '../prescription/Prescription.dart';
import 'ImagePreview.dart';

class ChatInterface extends StatefulWidget {
  final String docId;
  final AppointmentModel appointment;
  final String appointmentId;
  final String videocallToken;
  final bool isExpired;

  const ChatInterface({
    super.key,
    required this.appointmentId,
    required this.docId,
    required this.videocallToken,
    required this.appointment,
    required this.isExpired,
  });

  @override
  State<ChatInterface> createState() => _ChatInterfaceState();
}

class _ChatInterfaceState extends State<ChatInterface> {
  final chatController = Get.find<ChatController>();
  final bookingController = Get.find<BookingController>();
  final paymentController = Get.find<PaymentController>();
  final userController = Get.find<UserController>();
  final userService = Get.find<UserService>();
  final doctorService = Get.find<DoctorService>();
  final appointmentService = Get.find<AppointmentService>();
  String token = '';
  late Timer timer;
  UserModel? doctor;
  UserModel? me;
  String userName = '';

  int rating = 3;
  var commentController = TextEditingController();
  var messageController = TextEditingController();
  bool isReviewed = false;
  handleGetUserToken() async {
    token = await userService.getUserToken(userId: widget.docId);
    doctor = await userService.getProfileById(userId: widget.docId);
    me = await userService.getProfileById(userId: userController.userId.value);
    userName = "${me!.firstName.validate()} ${me!.lastName.validate()}";
    setState(() {});
  }

  final _formKey = GlobalKey<FormState>();

  // handleCheckReview() async {
  //   var res = await reviewService.getAppointmentReview(
  //       docId: widget.docId, appointmentId: widget.appointmentId);
  //   isReviewed = res != null;
  //   setState(() {});
  //   if (widget.isExpired) {
  //     showInDialog(context,
  //         backgroundColor: Colors.transparent,
  //         barrierDismissible: false,
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Container(),
  //             Container(
  //               padding: const EdgeInsets.all(20),
  //               decoration: BoxDecoration(
  //                   color: kPrimary, borderRadius: BorderRadius.circular(20)),
  //               child: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     children: [
  //                       const Text(""),
  //                       Text(
  //                         "Rate your session",
  //                         style: boldTextStyle(),
  //                       ),
  //                       const Icon(
  //                         Icons.close,
  //                         color: white,
  //                         size: 12,
  //                       )
  //                     ],
  //                   ),
  //                   15.height,
  //                   RatingBar.builder(
  //                     initialRating: rating.toDouble(),
  //                     minRating: 1,
  //                     direction: Axis.horizontal,
  //                     // allowHalfRating: true,
  //                     itemCount: 5,
  //                     itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
  //                     itemBuilder: (context, _) => const Icon(
  //                       Icons.star,
  //                       color: Colors.amber,
  //                     ),
  //                     onRatingUpdate: (rate) {
  //                       // print(rating);
  //                       rating = rate.toInt();
  //                       setState(() {});
  //                     },
  //                   ),
  //                   10.height,
  //                   AppTextField(
  //                     textFieldType: TextFieldType.OTHER,
  //                     minLines: 3,
  //                     maxLines: 5,
  //                     maxLength: 200,
  //                     controller: commentController,
  //                     textStyle: primaryTextStyle(color: black),
  //                     decoration: InputDecoration(
  //                         hintText: "Type here.....",
  //                         fillColor: white,
  //                         filled: true,
  //                         border: OutlineInputBorder(
  //                             borderSide: BorderSide.none,
  //                             borderRadius: BorderRadius.circular(20))),
  //                   ),
  //                   10.height,
  //                   ElevatedButton(
  //                     onPressed: () async {
  //                       if (commentController.text.isEmptyOrNull) {
  //                         toast("Please add comment");
  //                       } else {
  //                         reviewService.addReview(
  //                             review: ReviewsModel(
  //                           rating: rating,
  //                           review: commentController.text,
  //                           doctorId: widget.docId,
  //                           appointmentId: widget.appointmentId,
  //                           createdAt: Timestamp.now(),
  //                           userId: userController.userId.value,
  //                         ));
  //                         Navigator.pop(context);
  //                       }
  //                     },
  //                     child: const Text("Submit"),
  //                   ),
  //                 ],
  //               ),
  //             ).visible(!isReviewed),
  //             Column(
  //               children: [
  //                 ElevatedButton(
  //                   onPressed: () async {
  //                     var res = await reportService.getReport(
  //                         appointmentId: widget.appointmentId);
  //                     if (res != null) {
  //                       ReportChatInterface(
  //                         appointmentReport: res,
  //                       ).launch(context);
  //                     } else {
  //                       CreateReportScreen(
  //                         userId: widget.appointment.userId.validate(),
  //                         doctorId: widget.appointment.doctorId.validate(),
  //                         appointmentId: widget.appointment.id.validate(),
  //                       ).launch(context);
  //                     }
  //                   },
  //                   child: Text(
  //                     "Report",
  //                     style: primaryTextStyle(color: black),
  //                   ),
  //                 ),
  //                 ElevatedButton(
  //                   onPressed: () {
  //                     Navigator.pop(context);
  //                   },
  //                   child: Text(
  //                     "Close",
  //                     style: primaryTextStyle(color: black),
  //                   ),
  //                 ),
  //               ],
  //             )
  //           ],
  //         ));
  //   }
  // }

  @override
  void initState() {
    super.initState();
    messageController.addListener(updateSendButtonVisibility);
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
    handleGetUserToken();
    // handleCheckReview();
  }

  void updateSendButtonVisibility() {
    setState(() {
      // Update the UI based on whether the text field is empty or not
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var startTime = widget.appointment.startTime;
    var endTime = widget.appointment.endTime;
    var now = Timestamp.now();
    var isExpired = now.compareTo(endTime!) > 0;
    var isOngoing =
        now.compareTo(startTime!) >= 0 && now.compareTo(endTime) <= 0;
    var isYetToCommence = now.compareTo(startTime) <= 0;
    return Scaffold(
      // backgroundColor: kPrimaryLight,
      body: KeyboardDismisser(
        child: Container(
          decoration: const BoxDecoration(
              color: kPrimary,
              image: DecorationImage(
                image: AssetImage("assets/images/particle.png"),
                fit: BoxFit.cover,
                opacity: 0.4,
              ),
            ),
          child: SafeArea(
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: context.cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: dimGray.withOpacity(0.2),
                          offset: const Offset(0, 2),
                          spreadRadius: 2,
                          blurRadius: 2,
                        )
                      ]),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StreamBuilder<UserModel>(
                          stream: doctorService.getDoc(docId: widget.docId),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              var data = snapshot.data;
                              return Row(
                                children: [
                                  const Icon(
                                    Icons.arrow_back_ios,
                                  ).onTap(() {
                                    finish(context);
                                  }),
                                  Stack(
                                    alignment: Alignment.topRight,
                                    children: [
                                      profileImage(data, 30, 30,
                                          context: context),
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: isOnline(
                                            data!.status.validate() == ONLINE),
                                      ),
                                    ],
                                  ),
                                  10.width,
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${data.firstName!} ${data.lastName!}",
                                        style: boldTextStyle(
                                            color: kPrimary, size: 14),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            data.status.validate() == ONLINE
                                                ? ONLINE
                                                : OFFLINE,
                                            style: secondaryTextStyle(size: 12),
                                          ).visible(
                                              data.status.validate() == ONLINE),
                                          10.width.visible(
                                              data.status.validate() == ONLINE),
                                          Text(
                                            timeago.format(
                                                data.lastSeen!.toDate()),
                                            style: secondaryTextStyle(size: 10),
                                          ).visible(
                                              data.status.validate() == OFFLINE)
                                        ],
                                      ),
                                      widget.appointment.isPaid.validate() ==
                                                  false &&
                                              !widget.isExpired
                                          ? SizedBox()
                                          : TimeRemaining(
                                              appointment: widget.appointment,
                                            )
                                    ],
                                  ),
                                ],
                              );
                            }
                            return const Text('');
                          }),
                      Row(
                        children: [
                          IconButton(
                              onPressed: () {
                                showModalBottomSheet(
                                    context: context,
                                    backgroundColor: transparentColor,
                                    builder: (context) {
                                      return Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: context.cardColor,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(20),
                                            topRight: Radius.circular(20),
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(),
                                                Text(
                                                  "Select an action",
                                                  style:
                                                      boldTextStyle(size: 18),
                                                ),
                                                CircleAvatar(
                                                  backgroundColor: context
                                                      .scaffoldBackgroundColor,
                                                  child: Icon(
                                                    Icons.close_rounded,
                                                    color: context.primaryColor,
                                                  ),
                                                ).onTap(() {
                                                  finish(context);
                                                }),
                                              ],
                                            ),
                                            10.height,
                                            Divider(),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "Video Call",
                                                  style: boldTextStyle(),
                                                ),
                                                ZegoSendCallInvitationButton(
                                                  callID: widget.appointmentId,
                                                  iconSize: const Size(30, 30),
                                                  iconVisible: !isExpired &&
                                                      widget.appointment.isPaid
                                                          .validate() &&
                                                      !isYetToCommence,
                                                  icon: ButtonIcon(
                                                    // backgroundColor: white,
                                                    icon: Image.asset(
                                                      "assets/images/video.png",
                                                      color: kPrimary,
                                                    ),
                                                  ),
                                                  verticalLayout: false,
                                                  buttonSize:
                                                      const Size(50, 50),
                                                  isVideoCall: true,
                                                  resourceID:
                                                      "instantdoctorservice", //You need to use the resourceID that you created in the subsequent steps. Please continue reading this document.
                                                  invitees: [
                                                    ZegoUIKitUser(
                                                      id: widget
                                                          .appointment.doctorId
                                                          .validate(),
                                                      name: userName,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ).onTap(() {
                                              finish(context);
                                              if (isYetToCommence) {
                                                errorSnackBar(
                                                    title:
                                                        "Appointment is yet to commence");
                                                return;
                                              }
                                              if (isExpired) {
                                                errorSnackBar(
                                                    title:
                                                        "Appointment has expired");
                                                return;
                                              }
                                              if (widget.appointment.isPaid
                                                      .validate() ==
                                                  false) {
                                                errorSnackBar(
                                                    title:
                                                        "You havent made payment for this appointment");
                                                return;
                                              }
                                            }),
                                            Divider(),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "Audio Call",
                                                  style: boldTextStyle(),
                                                ),
                                                ZegoSendCallInvitationButton(
                                                  callID: widget.appointmentId,
                                                  iconSize: const Size(30, 30),
                                                  iconVisible: !isExpired &&
                                                      widget.appointment.isPaid
                                                          .validate() &&
                                                      !isYetToCommence,
                                                  icon: ButtonIcon(
                                                    // backgroundColor: white,
                                                    icon: Icon(
                                                      Icons.call,
                                                      color: kPrimary,
                                                    ),
                                                  ),
                                                  verticalLayout: false,
                                                  buttonSize:
                                                      const Size(50, 50),
                                                  isVideoCall: false,
                                                  resourceID:
                                                      "instantdoctorservice", //You need to use the resourceID that you created in the subsequent steps. Please continue reading this document.
                                                  invitees: [
                                                    ZegoUIKitUser(
                                                      id: widget
                                                          .appointment.doctorId
                                                          .validate(),
                                                      name: userName,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ).onTap(() {
                                              finish(context);
                                              if (isYetToCommence) {
                                                errorSnackBar(
                                                    title:
                                                        "Appointment is yet to commence");
                                                return;
                                              }
                                              if (isExpired) {
                                                errorSnackBar(
                                                    title:
                                                        "Appointment has expired");
                                                return;
                                              }
                                              if (widget.appointment.isPaid
                                                      .validate() ==
                                                  false) {
                                                errorSnackBar(
                                                    title:
                                                        "You havent made payment for this appointment");
                                                return;
                                              }
                                            }),
                                            Divider(),
                                          ],
                                        ),
                                      );
                                    });
                              },
                              icon: Icon(Icons.add_call)),
                          PopupMenuButton(
                              color: kPrimary,
                              icon: SizedBox(
                                  width: 30,
                                  height: 30,
                                  child: Image.asset(
                                    "assets/images/more.png",
                                    color: settingsController.isDarkMode.value
                                        ? white
                                        : black,
                                  )),
                              itemBuilder: (context) {
                                return [
                                  PopupMenuItem(
                                    onTap: () {
                                      SingleDoctorScreen(doctor: doctor!)
                                          .launch(context);
                                    },
                                    child: Text(
                                      "Doctor Info",
                                      style: primaryTextStyle(color: white),
                                    ),
                                  ),
                                  PopupMenuItem(
                                    onTap: () {
                                      PrescriptionScreen(
                                        appointment: widget.appointment,
                                      ).launch(context);
                                    },
                                    child: Text(
                                      "Prescriptions",
                                      style: primaryTextStyle(color: white),
                                    ),
                                  ),
                                  PopupMenuItem(
                                    onTap: () {
                                      CreateReportScreen(
                                              userId:
                                                  userController.userId.value,
                                              doctorId: doctor!.id.validate(),
                                              appointmentId:
                                                  widget.appointmentId)
                                          .launch(context);
                                    },
                                    child: Text(
                                      "Report Appointment",
                                      style: primaryTextStyle(color: white),
                                    ),
                                  ),
                                ];
                              })
                        ],
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: widget.appointment.isPaid.validate() == false &&
                          !widget.isExpired
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 100,
                              width: 100,
                              child: Image.asset("assets/images/error.png"),
                            ),
                            10.height,
                            Text(
                              "You haven't made payment for this appointment",
                              textAlign: TextAlign.center,
                              style: boldTextStyle(
                                size: 20,
                                // color: white,
                              ),
                            ),
                            10.height,
                            Text(
                              "Contact support",
                              style: boldTextStyle(
                                size: 14,
                                color: fireBrick,
                              ),
                            ).onTap(() {
                              HelpScreen().launch(context);
                            }),
                          ],
                        ).center()
                      : isYetToCommence
                          ? Center(
                              child: Text(
                                "Appointment is yet to commence",
                                style: boldTextStyle(
                                  size: 14,
                                ),
                              ),
                            )
                          : StreamBuilder<List<AppointmentConversationModel>>(
                              stream: appointmentService
                                  .getConversation(widget.appointmentId),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  if (snapshot.data!.isEmpty) {
                                    return Center(
                                      child: Text(
                                        "No Conversation Yet",
                                        style: boldTextStyle(),
                                      ),
                                    );
                                  } else {
                                    return ListView.builder(
                                      itemCount: chatController.message.length,
                                      reverse: true,
                                      physics: const BouncingScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        AppointmentConversationModel message =
                                            chatController.message[index];
                                        appointmentService.updateChatStatus(
                                            appointmentId: widget.appointmentId,
                                            userId: widget.docId);
                                        return message.type == MessageType.image
                                            ? Column(
                                                children: [
                                                  BubbleNormalImage(
                                                    onTap: () {
                                                      ImagePreview(
                                                              imageUrl: message
                                                                  .fileUrl!)
                                                          .launch(context);
                                                    },
                                                    id: message.id.validate(),
                                                    tail: true,
                                                    image: CachedNetworkImage(
                                                      imageUrl:
                                                          message.fileUrl!,
                                                      fit: BoxFit.cover,
                                                    ),
                                                    sent: message.senderId !=
                                                            userController
                                                                .userId.value
                                                        ? false
                                                        : message.status ==
                                                                MessageStatus
                                                                    .sent
                                                            ? true
                                                            : false,
                                                    delivered: message
                                                                .senderId !=
                                                            userController
                                                                .userId.value
                                                        ? false
                                                        : message.senderId !=
                                                                userController
                                                                    .userId
                                                                    .value
                                                            ? false
                                                            : message.status ==
                                                                    MessageStatus
                                                                        .delivered
                                                                ? true
                                                                : false,
                                                    seen: message.senderId !=
                                                            userController
                                                                .userId.value
                                                        ? false
                                                        : message.status ==
                                                                MessageStatus
                                                                    .read
                                                            ? true
                                                            : false,
                                                    isSender:
                                                        message.senderId ==
                                                            userController
                                                                .userId.value,
                                                  ),
                                                  BubbleSpecialThree(
                                                    isSender:
                                                        message.senderId ==
                                                            userController
                                                                .userId.value,
                                                    sent: message.status ==
                                                            MessageStatus.sent
                                                        ? true
                                                        : false,
                                                    delivered: message
                                                                .senderId !=
                                                            userController
                                                                .userId.value
                                                        ? false
                                                        : message.status ==
                                                                MessageStatus
                                                                    .delivered
                                                            ? true
                                                            : false,
                                                    seen: message.senderId !=
                                                            userController
                                                                .userId.value
                                                        ? false
                                                        : message.status ==
                                                                MessageStatus
                                                                    .read
                                                            ? true
                                                            : false,
                                                    text: SecurityHelper()
                                                        .decryptText(message
                                                            .message
                                                            .validate()),
                                                    color: context.cardColor,
                                                    tail: true,
                                                    textStyle: primaryTextStyle(
                                                        size: 16),
                                                  ).visible(message
                                                      .message!.isNotEmpty)
                                                ],
                                              )
                                            : message.type == MessageType.voice
                                                ? BubbleNormalAudio(
                                                    onSeekChanged: (s) {},
                                                    onPlayPauseButtonClick:
                                                        () {},
                                                    textStyle:
                                                        primaryTextStyle(),
                                                    color: context.cardColor,
                                                    sent: message.senderId !=
                                                            userController
                                                                .userId.value
                                                        ? false
                                                        : message.status ==
                                                                MessageStatus
                                                                    .sent
                                                            ? true
                                                            : false,
                                                    delivered: message
                                                                .senderId !=
                                                            userController
                                                                .userId.value
                                                        ? false
                                                        : message.status ==
                                                                MessageStatus
                                                                    .delivered
                                                            ? true
                                                            : false,
                                                    seen: message.senderId !=
                                                            userController
                                                                .userId.value
                                                        ? false
                                                        : message.status ==
                                                                MessageStatus
                                                                    .read
                                                            ? true
                                                            : false,
                                                  )
                                                : message.type ==
                                                        MessageType.file
                                                    ? SizedBox(
                                                        width: 70,
                                                        height: 70,
                                                        child: Image.asset(
                                                          "assets/images/pdf.png",
                                                          fit: BoxFit.cover,
                                                        ),
                                                      )
                                                    : BubbleSpecialThree(
                                                        isSender:
                                                            message.senderId ==
                                                                userController
                                                                    .userId
                                                                    .value,
                                                        sent: message
                                                                    .senderId !=
                                                                userController
                                                                    .userId
                                                                    .value
                                                            ? false
                                                            : message.status ==
                                                                    MessageStatus
                                                                        .sent
                                                                ? true
                                                                : false,
                                                        delivered: message
                                                                    .senderId !=
                                                                userController
                                                                    .userId
                                                                    .value
                                                            ? false
                                                            : message.status ==
                                                                    MessageStatus
                                                                        .delivered
                                                                ? true
                                                                : false,
                                                        seen: message
                                                                    .senderId !=
                                                                userController
                                                                    .userId
                                                                    .value
                                                            ? false
                                                            : message.status ==
                                                                    MessageStatus
                                                                        .read
                                                                ? true
                                                                : false,
                                                        text: SecurityHelper()
                                                            .decryptText(message
                                                                .message!),
                                                        tail: true,
                                                        color:
                                                            context.cardColor,
                                                        textStyle:
                                                            primaryTextStyle(
                                                          size: 16,
                                                        ),
                                                      );
                                      },
                                    );
                                  }
                                }
                                return const CircularProgressIndicator(
                                  color: kPrimary,
                                ).center();
                              }),
                ),
                Obx(
                  () => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                for (int x = 0;
                                    x < chatController.images.length;
                                    x++)
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Stack(
                                      alignment: Alignment.topRight,
                                      children: [
                                        SizedBox(
                                          width: 70,
                                          height: 70,
                                          child: Image.file(
                                            File(chatController.images[x].path),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: const Icon(
                                            Icons.delete,
                                            color: fireBrick,
                                          ).onTap(() {
                                            chatController.handleRemoveImage(x);
                                          }),
                                        )
                                      ],
                                    ),
                                  )
                              ],
                            )),
                        widget.appointment.isPaid.validate() == false &&
                                !widget.isExpired
                            ? Obx(() {
                                return bookingController.isLoading.value
                                    ? Loader()
                                    : Column(
                                        children: [
                                          AppButton(
                                            width: double.infinity,
                                            onTap: () async {
                                              try {
                                                bookingController
                                                    .isLoading.value = true;

                                                setState(() {});
                                                var userInfo = await userService
                                                    .getProfileById(
                                                        userId: userController
                                                            .userId.value);
                                                await paymentController
                                                    .makePayment(
                                                        email: userInfo.email
                                                            .validate(),
                                                        context: context,
                                                        amount: widget
                                                            .appointment.price
                                                            .validate(),
                                                        paymentFor:
                                                            'Appointment',
                                                        productId: widget
                                                            .appointment.id);
                                              } finally {
                                                bookingController
                                                    .isLoading.value = false;
                                              }
                                            },
                                            text: "Make Payment",
                                            color: white,
                                            textColor: kPrimary,
                                          )
                                        ],
                                      );
                              })
                            : widget.isExpired
                                ? Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: context.cardColor,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(20),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "View prescription",
                                          style: boldTextStyle(),
                                        )
                                      ],
                                    ),
                                  ).onTap(() {
                                    PrescriptionScreen(
                                            appointment: widget.appointment)
                                        .launch(context);
                                  })
                                : Form(
                                    key: _formKey,
                                    child: AppTextField(
                                      textFieldType: TextFieldType.MULTILINE,
                                      controller: messageController,
                                      minLines: 1,
                                      maxLines: 3,
                                      enabled: !isExpired && !isYetToCommence,
                                      decoration: InputDecoration(
                                        hintText: isYetToCommence
                                            ? "Appointment is yet to commence"
                                            : isExpired
                                                ? "This appointment session has expired"
                                                : "Type Here.....",
                                        hintStyle: primaryTextStyle(),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 10),
                                        filled: true,
                                        fillColor: context.cardColor,
                                        suffixIcon: isExpired
                                            ? null
                                            : Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons
                                                        .dashboard_customize_outlined,
                                                    color: kPrimary,
                                                  ).onTap(() {
                                                    return showModalBottomSheet(
                                                        context: context,
                                                        backgroundColor:
                                                            Colors.transparent,
                                                        builder: (BuildContext
                                                            context1) {
                                                          return Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(20),
                                                              height: 120,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: context
                                                                    .cardColor,
                                                                borderRadius:
                                                                    const BorderRadius
                                                                        .only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          20),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          20),
                                                                ),
                                                              ),
                                                              child: GridView
                                                                  .count(
                                                                crossAxisCount:
                                                                    3,
                                                                crossAxisSpacing:
                                                                    10,
                                                                mainAxisSpacing:
                                                                    10,
                                                                physics:
                                                                    const NeverScrollableScrollPhysics(),
                                                                children: [
                                                                  Column(
                                                                    children: [
                                                                      const CircleAvatar(
                                                                        child:
                                                                            Icon(
                                                                          Icons
                                                                              .document_scanner,
                                                                          size:
                                                                              30,
                                                                          // color: context.iconColor,
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                        "Documents",
                                                                        style: primaryTextStyle(
                                                                            size:
                                                                                14),
                                                                      ),
                                                                    ],
                                                                  ).onTap(() {
                                                                    Get.back();
                                                                    chatController
                                                                        .handleGetDoc();
                                                                  }),
                                                                  Column(
                                                                    children: [
                                                                      const CircleAvatar(
                                                                        child:
                                                                            Icon(
                                                                          Icons
                                                                              .browse_gallery,
                                                                          size:
                                                                              30,
                                                                          // color: context.iconColor,
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                        "Gallery",
                                                                        style: primaryTextStyle(
                                                                            size:
                                                                                14),
                                                                      ),
                                                                    ],
                                                                  ).onTap(() {
                                                                    Get.back();
                                                                    chatController
                                                                        .handleGetGallery();
                                                                  }),
                                                                  Column(
                                                                    children: [
                                                                      const CircleAvatar(
                                                                        child:
                                                                            Icon(
                                                                          Icons
                                                                              .camera,
                                                                          size:
                                                                              30,
                                                                          // color: context.iconColor,
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                        "Camera",
                                                                        style: primaryTextStyle(
                                                                            size:
                                                                                14),
                                                                      ),
                                                                    ],
                                                                  ).onTap(() {
                                                                    Get.back();
                                                                    chatController
                                                                        .handleGetCamera();
                                                                  }),
                                                                ],
                                                              ));
                                                        });
                                                  }),
                                                  10.width,
                                                  Loader().center().visible(
                                                      chatController
                                                          .isLoading.value),
                                                  messageController
                                                              .text.isEmpty &&
                                                          chatController
                                                              .files.isEmpty &&
                                                          chatController
                                                              .images.isEmpty
                                                      ? const CircleAvatar(
                                                          backgroundColor:
                                                              kPrimary,
                                                          child: Icon(
                                                            Icons.mic,
                                                            color: white,
                                                          ),
                                                        ).onTap(() {})
                                                      : const CircleAvatar(
                                                          backgroundColor:
                                                              kPrimary,
                                                          child: Icon(
                                                            Icons.send,
                                                            color: white,
                                                          ),
                                                        ).onTap(() {
                                                          if (_formKey
                                                              .currentState!
                                                              .validate()) {
                                                            chatController
                                                                .handleSendMessage(
                                                              docId:
                                                                  widget.docId,
                                                              myName: userName,
                                                              message:
                                                                  messageController
                                                                      .text,
                                                              appointmentId: widget
                                                                  .appointmentId,
                                                              token: token
                                                                  .validate(),
                                                            );
                                                            messageController
                                                                .clear();
                                                          }
                                                        }).visible(
                                                          chatController
                                                              .isLoading
                                                              .isFalse),
                                                  10.width,
                                                ],
                                              ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                    ),
                                  ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
