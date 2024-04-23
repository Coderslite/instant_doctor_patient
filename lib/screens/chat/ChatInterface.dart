// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/component/ProfileImage.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/constant/constants.dart';
import 'package:instant_doctor/controllers/ChatController.dart';
import 'package:instant_doctor/controllers/UserController.dart';
import 'package:instant_doctor/function/send_notification.dart';
import 'package:instant_doctor/main.dart';
import 'package:instant_doctor/models/AppointmentModel.dart';
import 'package:instant_doctor/models/ReviewsModel.dart';
import 'package:instant_doctor/models/UserModel.dart';
import 'package:instant_doctor/screens/appointment/reports/CreateReport.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../component/IsOnline.dart';
import '../../component/TimeRemaining.dart';
import '../../component/dropdown_menu.dart';
import '../appointment/reports/ReportChat.dart';
import 'ImagePreview.dart';
import 'VideoCall.dart';

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
  ChatController chatController = Get.put(ChatController());
  UserController userController = Get.put(UserController());
  String token = '';
  late Timer timer;

  int rating = 3;
  var commentController = TextEditingController();
  bool isReviewed = false;
  handleGetUserToken() async {
    token = await userService.getUserToken(userId: widget.docId);
  }

  handleCheckReview() async {
    var res = await reviewService.getAppointmentReview(
        docId: widget.docId, appointmentId: widget.appointmentId);
    isReviewed = res != null;
    setState(() {});
    if (widget.isExpired) {
      showInDialog(context,
          backgroundColor: Colors.transparent,
          barrierDismissible: false,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: kPrimary, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(""),
                        Text(
                          "Rate your session",
                          style: boldTextStyle(),
                        ),
                        const Icon(
                          Icons.close,
                          color: white,
                          size: 12,
                        )
                      ],
                    ),
                    15.height,
                    RatingBar.builder(
                      initialRating: rating.toDouble(),
                      minRating: 1,
                      direction: Axis.horizontal,
                      // allowHalfRating: true,
                      itemCount: 5,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rate) {
                        // print(rating);
                        rating = rate.toInt();
                        setState(() {});
                      },
                    ),
                    10.height,
                    AppTextField(
                      textFieldType: TextFieldType.OTHER,
                      minLines: 3,
                      maxLines: 5,
                      maxLength: 200,
                      controller: commentController,
                      textStyle: primaryTextStyle(color: black),
                      decoration: InputDecoration(
                          hintText: "Type here.....",
                          fillColor: white,
                          filled: true,
                          border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(20))),
                    ),
                    10.height,
                    ElevatedButton(
                      onPressed: () async {
                        if (commentController.text.isEmptyOrNull) {
                          toast("Please add comment");
                        } else {
                          reviewService.addReview(
                              review: ReviewsModel(
                            rating: rating,
                            review: commentController.text,
                            doctorId: widget.docId,
                            appointmentId: widget.appointmentId,
                            createdAt: Timestamp.now(),
                            userId: userController.userId.value,
                          ));
                          Navigator.pop(context);
                        }
                      },
                      child: const Text("Submit"),
                    ),
                  ],
                ),
              ).visible(!isReviewed),
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      var res = await reportService.getReport(
                          appointmentId: widget.appointmentId);
                      if (res != null) {
                        ReportChatInterface(
                          appointmentReport: res,
                        ).launch(context);
                      } else {
                        CreateReportScreen(
                          userId: widget.appointment.userId.validate(),
                          doctorId: widget.appointment.doctorId.validate(),
                          appointmentId: widget.appointment.id.validate(),
                        ).launch(context);
                      }
                    },
                    child: Text(
                      "Report",
                      style: primaryTextStyle(color: black),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Close",
                      style: primaryTextStyle(color: black),
                    ),
                  ),
                ],
              )
            ],
          ));
    }
  }

  @override
  void initState() {
    super.initState();
    chatController.messageController.addListener(updateSendButtonVisibility);
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
    handleGetUserToken();
    handleCheckReview();
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
      body: Container(
        decoration: const BoxDecoration(
            color: kPrimary,
            image: DecorationImage(
              image: AssetImage("assets/images/particle.png"),
              fit: BoxFit.cover,
              opacity: 0.4,
            )),
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
                                    profileImage(data, 50, 50,
                                        context: context),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: isOnline(
                                          data!.status.validate() == ONLINE),
                                    ),
                                  ],
                                ),
                                5.width,
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${data.firstName!} ${data.lastName!}",
                                      style: boldTextStyle(
                                          color: kPrimary, size: 18),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          data.status.validate() == ONLINE
                                              ? ONLINE
                                              : OFFLINE,
                                          style: secondaryTextStyle(),
                                        ),
                                        10.width,
                                        Text(
                                          timeago
                                              .format(data.lastSeen!.toDate()),
                                          style: secondaryTextStyle(),
                                        ).visible(
                                            data.status.validate() == OFFLINE)
                                      ],
                                    ),
                                    TimeRemaining(
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
                        SizedBox(
                          height: 30,
                          child: Image.asset(
                            "assets/images/video.png",
                            fit: BoxFit.cover,
                          ),
                        ).onTap(
                          () async {
                            // const MyCall().launch(context);

                            var user = await userService.getProfileById(
                                userId: userController.userId.value);
                            isExpired
                                ? null
                                : sendNotification(
                                    [token],
                                    "Incoming Call",
                                    "${user.firstName} ${user.lastName} is calling now",
                                    widget.appointmentId,
                                    NotificatonType.call);
                            isExpired
                                ? toast("Appointment Session has expired")
                                : VideoCall(appointmentId: widget.appointmentId)
                                    .launch(context);
                          },
                        ).visible(!isExpired && isOngoing),
                        5.width,
                        StreamBuilder<UserModel>(
                            stream:
                                userService.getProfile(userId: widget.docId),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                var data = snapshot.data!;
                                return DropdownButtonHideUnderline(
                                  child: DropdownButton2(
                                    customButton: SizedBox(
                                      height: 30,
                                      child: Image.asset(
                                        "assets/images/more.png",
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    items: [
                                      ...MenuItems.firstItems.map(
                                        (item) => DropdownMenuItem<MenuItem>(
                                          value: item,
                                          child: MenuItems.buildItem(item),
                                        ),
                                      ),
                                      const DropdownMenuItem<Divider>(
                                          enabled: false, child: Divider()),
                                      ...MenuItems.secondItems.map(
                                        (item) => DropdownMenuItem<MenuItem>(
                                          value: item,
                                          child: MenuItems.buildItem(item),
                                        ),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      MenuItems.onChanged(
                                          context, value! as MenuItem, data);
                                    },
                                    dropdownStyleData: DropdownStyleData(
                                      width: 160,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 6),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        color: kPrimary,
                                      ),
                                      offset: const Offset(0, 8),
                                    ),
                                    menuItemStyleData: MenuItemStyleData(
                                      customHeights: [
                                        ...List<double>.filled(
                                            MenuItems.firstItems.length, 48),
                                        8,
                                        ...List<double>.filled(
                                            MenuItems.secondItems.length, 48),
                                      ],
                                      padding: const EdgeInsets.only(
                                          left: 16, right: 16),
                                    ),
                                  ),
                                );
                              }
                              return Container();
                            })
                      ],
                    )
                  ],
                ),
              ),
              Expanded(
                child: isYetToCommence
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
                                itemCount: snapshot.data!.length,
                                reverse: true,
                                physics: const BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  var message = snapshot.data![index];
                                  appointmentService.updateChatStatus(
                                      appointmentId: widget.appointmentId,
                                      userId: widget.docId);
                                  return message.type == MessageType.image
                                      ? Column(
                                          children: [
                                            BubbleNormalImage(
                                              onTap: () {
                                                ImagePreview(
                                                        imageUrl:
                                                            message.fileUrl!)
                                                    .launch(context);
                                              },
                                              id: message.id.validate(),
                                              tail: true,
                                              image: CachedNetworkImage(
                                                imageUrl: message.fileUrl!,
                                                fit: BoxFit.cover,
                                              ),
                                              sent: message.senderId !=
                                                      userController
                                                          .userId.value
                                                  ? false
                                                  : true,
                                              delivered: message.senderId !=
                                                      userController
                                                          .userId.value
                                                  ? false
                                                  : true,
                                              seen: message.senderId !=
                                                      userController
                                                          .userId.value
                                                  ? false
                                                  : message.status ==
                                                          MessageStatus.read
                                                      ? true
                                                      : false,
                                              isSender: message.senderId ==
                                                  userController.userId.value,
                                            ),
                                            BubbleSpecialThree(
                                              isSender: message.senderId ==
                                                  userController.userId.value,
                                              sent: message.senderId !=
                                                      userController
                                                          .userId.value
                                                  ? false
                                                  : true,
                                              delivered: message.senderId !=
                                                      userController
                                                          .userId.value
                                                  ? false
                                                  : true,
                                              seen: message.senderId !=
                                                      userController
                                                          .userId.value
                                                  ? false
                                                  : message.status ==
                                                          MessageStatus.read
                                                      ? true
                                                      : false,
                                              text: message.message!,
                                              color: context.cardColor,
                                              tail: true,
                                              textStyle: const TextStyle(
                                                color: kPrimary,
                                                fontSize: 16,
                                              ),
                                            ).visible(
                                                message.message!.isNotEmpty)
                                          ],
                                        )
                                      : message.type == MessageType.voice
                                          ? BubbleNormalAudio(
                                              onSeekChanged: (s) {},
                                              onPlayPauseButtonClick: () {},
                                              textStyle: primaryTextStyle(),
                                              color: context.cardColor,
                                              sent: message.senderId !=
                                                      userController
                                                          .userId.value
                                                  ? false
                                                  : true,
                                              delivered: message.senderId !=
                                                      userController
                                                          .userId.value
                                                  ? false
                                                  : true,
                                              seen: message.senderId !=
                                                      userController
                                                          .userId.value
                                                  ? false
                                                  : message.status ==
                                                          MessageStatus.read
                                                      ? true
                                                      : false,
                                            )
                                          : message.type == MessageType.file
                                              ? SizedBox(
                                                  width: 70,
                                                  height: 70,
                                                  child: Image.asset(
                                                    "assets/images/pdf.png",
                                                    fit: BoxFit.cover,
                                                  ),
                                                )
                                              : BubbleSpecialThree(
                                                  isSender: message.senderId ==
                                                      userController
                                                          .userId.value,
                                                  sent: message.senderId !=
                                                          userController
                                                              .userId.value
                                                      ? false
                                                      : true,
                                                  delivered: message.senderId !=
                                                          userController
                                                              .userId.value
                                                      ? false
                                                      : true,
                                                  seen: message.senderId !=
                                                          userController
                                                              .userId.value
                                                      ? false
                                                      : message.status ==
                                                              MessageStatus.read
                                                          ? true
                                                          : false,
                                                  text: message.message!,
                                                  tail: true,
                                                  color: context.cardColor,
                                                  textStyle: const TextStyle(
                                                    color: kPrimary,
                                                    fontSize: 16,
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
                      AppTextField(
                        textFieldType: TextFieldType.MULTILINE,
                        controller: chatController.messageController,
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
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          filled: true,
                          fillColor: context.cardColor,
                          suffixIcon: isExpired
                              ? const Row(
                                  mainAxisSize: MainAxisSize.min,
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.dashboard_customize_outlined,
                                      color: kPrimary,
                                    ).onTap(() {
                                      return showModalBottomSheet(
                                          context: context,
                                          backgroundColor: Colors.transparent,
                                          builder: (BuildContext context1) {
                                            return Container(
                                                padding:
                                                    const EdgeInsets.all(20),
                                                height: 120,
                                                decoration: BoxDecoration(
                                                  color: context.cardColor,
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(20),
                                                    topRight:
                                                        Radius.circular(20),
                                                  ),
                                                ),
                                                child: GridView.count(
                                                  crossAxisCount: 3,
                                                  crossAxisSpacing: 10,
                                                  mainAxisSpacing: 10,
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  children: [
                                                    Column(
                                                      children: [
                                                        const CircleAvatar(
                                                          child: Icon(
                                                            Icons
                                                                .document_scanner,
                                                            size: 30,
                                                            // color: context.iconColor,
                                                          ),
                                                        ),
                                                        Text(
                                                          "Documents",
                                                          style:
                                                              primaryTextStyle(
                                                                  size: 14),
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
                                                          child: Icon(
                                                            Icons
                                                                .browse_gallery,
                                                            size: 30,
                                                            // color: context.iconColor,
                                                          ),
                                                        ),
                                                        Text(
                                                          "Gallery",
                                                          style:
                                                              primaryTextStyle(
                                                                  size: 14),
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
                                                          child: Icon(
                                                            Icons.camera,
                                                            size: 30,
                                                            // color: context.iconColor,
                                                          ),
                                                        ),
                                                        Text(
                                                          "Camera",
                                                          style:
                                                              primaryTextStyle(
                                                                  size: 14),
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
                                    const CircularProgressIndicator()
                                        .center()
                                        .visible(
                                            chatController.isLoading.value),
                                    chatController.messageController.text
                                                .isEmpty &&
                                            chatController.files.isEmpty &&
                                            chatController.images.isEmpty
                                        ? const CircleAvatar(
                                            backgroundColor: kPrimary,
                                            child: Icon(
                                              Icons.mic,
                                              color: white,
                                            ),
                                          ).onTap(() {})
                                        : const CircleAvatar(
                                            backgroundColor: kPrimary,
                                            child: Icon(
                                              Icons.send,
                                              color: white,
                                            ),
                                          ).onTap(() {
                                            chatController.handleSendMessage(
                                              docId: widget.docId,
                                              appointmentId:
                                                  widget.appointmentId,
                                              token: token.validate(),
                                            );
                                          }).visible(
                                            chatController.isLoading.isFalse),
                                    10.width,
                                  ],
                                ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
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
    );
  }
}
