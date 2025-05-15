// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/constant/constants.dart';
import 'package:instant_doctor/controllers/UserController.dart';
import 'package:instant_doctor/models/AppointmentReportModel.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../controllers/ReportController.dart';
import '../../../services/ReportService.dart';
import '../../chat/ImagePreview.dart';

class ReportChatInterface extends StatefulWidget {
  final AppointmentReportModel appointmentReport;

  const ReportChatInterface({
    super.key,
    required this.appointmentReport,
  });

  @override
  State<ReportChatInterface> createState() => _ReportChatInterfaceState();
}

class _ReportChatInterfaceState extends State<ReportChatInterface> {
  final reportService = Get.find<ReportService>();
  final userController = Get.find<UserController>();
  final reportController = Get.find<ReportController>();

  String token = '';
  late Timer timer;

  // handleGetUserToken() async {
  //   token = await userService.getUserToken(userId: widget.appointmentReport.);
  // }

  @override
  void initState() {
    super.initState();
    reportController.messageController.addListener(updateSendButtonVisibility);
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
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
                    Column(
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.arrow_back_ios,
                              size: 22,
                              color: kPrimary,
                            ).onTap(() {
                              Navigator.pop(context);
                            }),
                            SizedBox(
                              width: 50,
                              height: 50,
                              child: Image.asset("assets/images/logo.png"),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Column(
                          children: [
                            Text(
                              "Customer Care",
                              style: boldTextStyle(),
                            ),
                            Text(
                              "Talk with our customer care",
                              style: secondaryTextStyle(size: 12),
                            ),
                          ],
                        )
                      ],
                    ),
                    const Text("         ")
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<List<AppointmentReportConversation>>(
                    stream: reportService.getReportConversation(
                        id: widget.appointmentReport.id.validate()),
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

                              return message.type == MessageType.image
                                  ? Column(
                                      children: [
                                        BubbleNormalImage(
                                          onTap: () {
                                            ImagePreview(
                                                    imageUrl: message.fileUrl!)
                                                .launch(context);
                                          },
                                          id: message.id.validate(),
                                          tail: true,
                                          image: CachedNetworkImage(
                                            imageUrl: message.fileUrl!,
                                            fit: BoxFit.cover,
                                          ),
                                          sent: message.senderId !=
                                                  userController.userId.value
                                              ? false
                                              : true,
                                          delivered: message.senderId !=
                                                  userController.userId.value
                                              ? false
                                              : true,
                                          seen: message.senderId !=
                                                  userController.userId.value
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
                                                  userController.userId.value
                                              ? false
                                              : true,
                                          delivered: message.senderId !=
                                                  userController.userId.value
                                              ? false
                                              : true,
                                          seen: message.senderId !=
                                                  userController.userId.value
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
                                        ).visible(message.message!.isNotEmpty)
                                      ],
                                    )
                                  : message.type == MessageType.voice
                                      ? BubbleNormalAudio(
                                          onSeekChanged: (s) {},
                                          onPlayPauseButtonClick: () {},
                                          textStyle: primaryTextStyle(),
                                          color: context.cardColor,
                                          sent: message.senderId !=
                                                  userController.userId.value
                                              ? false
                                              : true,
                                          delivered: message.senderId !=
                                                  userController.userId.value
                                              ? false
                                              : true,
                                          seen: message.senderId !=
                                                  userController.userId.value
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
                                  x < reportController.images.length;
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
                                          File(reportController.images[x].path),
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
                                          reportController.handleRemoveImage(x);
                                        }),
                                      )
                                    ],
                                  ),
                                )
                            ],
                          )),
                      AppTextField(
                        textFieldType: TextFieldType.MULTILINE,
                        controller: reportController.messageController,
                        minLines: 1,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: "Type Here.....",
                          hintStyle: primaryTextStyle(),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          filled: true,
                          fillColor: context.cardColor,
                          suffixIcon: Row(
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
                                          padding: const EdgeInsets.all(20),
                                          height: 120,
                                          decoration: BoxDecoration(
                                            color: context.cardColor,
                                            borderRadius:
                                                const BorderRadius.only(
                                              topLeft: Radius.circular(20),
                                              topRight: Radius.circular(20),
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
                                                      Icons.document_scanner,
                                                      size: 30,
                                                      // color: context.iconColor,
                                                    ),
                                                  ),
                                                  Text(
                                                    "Documents",
                                                    style: primaryTextStyle(
                                                        size: 14),
                                                  ),
                                                ],
                                              ).onTap(() {
                                                Get.back();
                                                reportController.handleGetDoc();
                                              }),
                                              Column(
                                                children: [
                                                  const CircleAvatar(
                                                    child: Icon(
                                                      Icons.browse_gallery,
                                                      size: 30,
                                                      // color: context.iconColor,
                                                    ),
                                                  ),
                                                  Text(
                                                    "Gallery",
                                                    style: primaryTextStyle(
                                                        size: 14),
                                                  ),
                                                ],
                                              ).onTap(() {
                                                Get.back();
                                                reportController
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
                                                    style: primaryTextStyle(
                                                        size: 14),
                                                  ),
                                                ],
                                              ).onTap(() {
                                                Get.back();
                                                reportController
                                                    .handleGetCamera();
                                              }),
                                            ],
                                          ));
                                    });
                              }),
                              10.width,
                            Loader()
                                  .center()
                                  .visible(reportController.isLoading.value),
                              reportController.messageController.text.isEmpty &&
                                      reportController.files.isEmpty &&
                                      reportController.images.isEmpty
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
                                      reportController.handleSendMessage(
                                        reportId: widget.appointmentReport.id
                                            .validate(),
                                      );
                                      reportController.messageController
                                          .clear();
                                    }).visible(
                                      reportController.isLoading.isFalse),
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
