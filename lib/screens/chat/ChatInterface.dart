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
import 'package:instant_doctor/screens/chat/RateScreen.dart';
import 'package:instant_doctor/screens/doctors/SingleDoctor.dart';
import 'package:instant_doctor/screens/profile/help/Help.dart';
import 'package:instant_doctor/services/ReviewService.dart';
import 'package:instant_doctor/services/UserService.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import '../../component/IsOnline.dart';
import '../../component/TimeRemaining.dart';
import '../../component/check_country.dart';
import '../../component/check_internet.dart';
import '../../controllers/BookingController.dart';
import '../../controllers/PaymentController.dart';
import '../../services/AppointmentService.dart';
import '../../services/DoctorService.dart';
import '../../services/SecurityHelper.dart';
import '../prescription/Prescription.dart';
import '../profile/help/LiveChat.dart';
import 'ImagePreview.dart';

class ChatInterface extends StatefulWidget {
  final String docId;
  final AppointmentModel appointment;
  final String appointmentId;
  final String videocallToken;
  final bool isExpired;
  final Function update;

  const ChatInterface({
    super.key,
    required this.appointmentId,
    required this.docId,
    required this.videocallToken,
    required this.appointment,
    required this.isExpired,
    required this.update,
  });

  @override
  State<ChatInterface> createState() => _ChatInterfaceState();
}

class _ChatInterfaceState extends State<ChatInterface>
    with SingleTickerProviderStateMixin {
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
  String repliedTo = '';
  String? repliedMessageText;
  String? repliedMessageSender;
  bool isReplying = false;
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  var messageController = TextEditingController();
  bool isReviewed = false;
  final _formKey = GlobalKey<FormState>();
  List<AppointmentConversationModel> messages = [];
  bool isLoading = true;
  String? highlightedMessageId;
  late AnimationController _animationController;
  late Animation<Color?> _highlightAnimation;

  @override
  void initState() {
    super.initState();
    messageController.addListener(updateSendButtonVisibility);
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
    handleGetUserToken();
    handleCheckReview();
    _fetchMessages();

    // Initialize animation controller for highlight effect
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _highlightAnimation = ColorTween(
      begin: Colors.yellow.withOpacity(0.5),
      end: Colors.transparent,
    ).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });
  }

  void updateSendButtonVisibility() {
    setState(() {});
  }

  @override
  void dispose() {
    timer.cancel();
    messageController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> handleGetUserToken() async {
    token = await userService.getUserToken(userId: widget.docId);
    doctor = await userService.getProfileById(userId: widget.docId);
    me = await userService.getProfileById(userId: userController.userId.value);
    userName = "${me!.firstName.validate()} ${me!.lastName.validate()}";
    setState(() {});
  }

  Future<void> handleCheckReview() async {
    var reviewService = Get.find<ReviewService>();
    var res = await reviewService.getAppointmentReview(
        docId: widget.docId, appointmentId: widget.appointmentId);
    isReviewed = res != null;
    setState(() {});
    if (widget.isExpired && !isReviewed) {
      showDialog(
          context: context,
          barrierColor: Colors.black87,
          barrierDismissible: false,
          builder: (context) => Ratescreen(
                docId: widget.docId,
                appointment: widget.appointment,
                appointmentId: widget.appointmentId,
                isExpired: widget.isExpired,
                doctor: doctor!,
                isReviewed: isReviewed,
                update: widget.update,
              ));
    }
  }

  void _fetchMessages() {
    appointmentService
        .getConversationQuery(widget.appointmentId)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        messages = snapshot.docs
            .map((e) => AppointmentConversationModel.fromJson(
                e.data() as Map<String, dynamic>))
            .toList()
            .reversed
            .toList();
        isLoading = false;
        if (isReplying) {
          isReplying = false;
          repliedTo = '';
          repliedMessageText = null;
          repliedMessageSender = null;
        }
      });

      // Scroll to the bottom when new messages are received
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.minScrollExtent);
        }
      });
    });
  }

  void handleReply(AppointmentConversationModel message, String senderName) {
    String replyText;
    switch (message.type) {
      case MessageType.text:
        replyText = SecurityHelper().decryptText(message.message.validate());
        break;
      case MessageType.image:
        replyText = 'Photo';
        if (message.message.validate().isNotEmpty) {
          replyText +=
              ': ${SecurityHelper().decryptText(message.message.validate())}';
        }
        break;
      case MessageType.voice:
        replyText = 'Voice message';
        break;
      case MessageType.file:
        replyText = 'File';
        break;
      default:
        replyText = 'Message';
    }
    if (replyText.length > 100) {
      replyText = '${replyText.substring(0, 100)}...';
    }
    setState(() {
      isReplying = true;
      repliedTo = message.id.validate();
      repliedMessageText = replyText;
      repliedMessageSender = senderName;
    });
    FocusScope.of(context).requestFocus(_focusNode);
  }

  void cancelReply() {
    setState(() {
      isReplying = false;
      repliedTo = '';
      repliedMessageText = null;
      repliedMessageSender = null;
    });
  }

  void showOptions(AppointmentConversationModel message) {
    if (message.senderId != userController.userId.value) return;

    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: Text('Edit', style: boldTextStyle()),
                  onTap: () {
                    Get.back();
                    editText(message);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: Text('Delete', style: boldTextStyle()),
                  onTap: () async {
                    finish(context);
                    deleteText(message);
                  },
                ),
              ],
            ),
          );
        });
  }

  Future<void> deleteText(AppointmentConversationModel message) async {
    showConfirmDialogCustom(
      context,
      title: "Are you sure you want to delete this message?",
      onAccept: (v) async {
        await appointmentService.deleteChat(
          appointmentId: widget.appointmentId,
          chatId: message.id.validate(),
        );
      },
    );
  }

  void editText(AppointmentConversationModel message) {
    String currentText = SecurityHelper().decryptText(message.message!);
    TextEditingController editController =
        TextEditingController(text: currentText);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.cardColor,
        title: Text('Edit Message', style: boldTextStyle()),
        content: TextField(
          controller: editController,
          minLines: 1,
          maxLines: 5,
          style: primaryTextStyle(),
          decoration: const InputDecoration(hintText: 'Edit your message...'),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              String newText = editController.text.trim();
              if (newText.isNotEmpty && newText != currentText) {
                String encrypted = SecurityHelper().encryptText(newText);
                await appointmentService.updateChatText(
                    appointmentId: widget.appointmentId,
                    chatId: message.id.validate(),
                    message: encrypted);
              }
              finish(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void scrollToRepliedMessage(String repliedToId) {
    // Find the index of the message with the repliedToId in the reversed list
    int index = messages.reversed
        .toList()
        .indexWhere((message) => message.id == repliedToId);
    if (index == -1 || !_scrollController.hasClients) return;

    // Calculate the total height of messages up to the target index
    double totalHeight = 0.0;
    final reversedMessages = messages.reversed.toList();

    for (int i = 0; i <= index; i++) {
      final message = reversedMessages[i];
      double messageHeight = 0.0;

      // Base height based on message type
      switch (message.type) {
        case MessageType.text:
          // Approximate height for text messages (adjust based on content if needed)
          messageHeight = 50.0; // Base height for short text
          if (message.isEdited.validate()) {
            messageHeight += 20.0; // Add height for "edited" label
          }
          break;
        case MessageType.image:
          messageHeight = 200.0; // Height for image
          if (message.message.validate().isNotEmpty) {
            messageHeight += 50.0; // Add height for caption
          }
          break;
        case MessageType.voice:
          messageHeight = 50.0; // Height for voice message
          break;
        case MessageType.file:
          messageHeight = 70.0; // Height for file icon
          break;
        default:
          messageHeight = 50.0; // Fallback height
      }

      // Add height for "replied to" section if present
      if (message.repliedTo != null && message.repliedTo!.isNotEmpty) {
        messageHeight += 60.0; // Approximate height for reply container
      }

      totalHeight += messageHeight;
    }

    // Scroll to the calculated position
    _scrollController.animateTo(
      totalHeight,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );

    // Highlight the message
    setState(() {
      highlightedMessageId = repliedToId;
      _animationController.forward();
    });

    // Clear highlight after animation
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          highlightedMessageId = null;
        });
        _animationController.reset();
      }
    });
  }

  final Map<String, GlobalKey> messageKeys = {};

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
                internetCheck(),
                countryCheck(),
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
                      ),
                    ],
                  ),
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
                                  const Icon(Icons.arrow_back_ios).onTap(() {
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
                                        "${data.firstName} ${data.lastName}",
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
                                            data.lastSeen == null
                                                ? ''
                                                : timeago.format(
                                                    data.lastSeen!.toDate()),
                                            style: secondaryTextStyle(size: 10),
                                          ).visible(data.status.validate() ==
                                              OFFLINE),
                                        ],
                                      ),
                                      if (widget.appointment.isPaid
                                              .validate() ||
                                          !widget.isExpired)
                                        TimeRemaining(
                                            appointment: widget.appointment),
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
                                    backgroundColor: Colors.transparent,
                                    builder: (context) {
                                      return Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: context.cardColor,
                                          borderRadius: const BorderRadius.only(
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
                                                Text("Select an action",
                                                    style: boldTextStyle(
                                                        size: 18)),
                                                CircleAvatar(
                                                  backgroundColor: context
                                                      .scaffoldBackgroundColor,
                                                  child: Icon(
                                                      Icons.close_rounded,
                                                      color:
                                                          context.primaryColor),
                                                ).onTap(() => finish(context)),
                                              ],
                                            ),
                                            10.height,
                                            const Divider(),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text("Video Call",
                                                    style: boldTextStyle()),
                                                ZegoSendCallInvitationButton(
                                                  callID: widget.appointmentId,
                                                  iconSize: const Size(30, 30),
                                                  iconVisible: !isExpired &&
                                                      widget.appointment.isPaid
                                                          .validate() &&
                                                      !isYetToCommence,
                                                  icon: ButtonIcon(
                                                    icon: Image.asset(
                                                        "assets/images/video.png",
                                                        color: kPrimary),
                                                  ),
                                                  verticalLayout: false,
                                                  buttonSize:
                                                      const Size(50, 50),
                                                  isVideoCall: true,
                                                  resourceID:
                                                      "instantdoctorservice",
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
                                              if (!widget.appointment.isPaid
                                                  .validate()) {
                                                errorSnackBar(
                                                    title:
                                                        "You haven't made payment for this appointment");
                                                return;
                                              }
                                            }),
                                            const Divider(),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text("Audio Call",
                                                    style: boldTextStyle()),
                                                ZegoSendCallInvitationButton(
                                                  callID: widget.appointmentId,
                                                  iconSize: const Size(30, 30),
                                                  iconVisible: !isExpired &&
                                                      widget.appointment.isPaid
                                                          .validate() &&
                                                      !isYetToCommence,
                                                  icon: ButtonIcon(
                                                      icon: const Icon(
                                                          Icons.call,
                                                          color: kPrimary)),
                                                  verticalLayout: false,
                                                  buttonSize:
                                                      const Size(50, 50),
                                                  isVideoCall: false,
                                                  resourceID:
                                                      "instantdoctorservice",
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
                                              if (!widget.appointment.isPaid
                                                  .validate()) {
                                                errorSnackBar(
                                                    title:
                                                        "You haven't made payment for this appointment");
                                                return;
                                              }
                                            }),
                                            const Divider(),
                                          ],
                                        ),
                                      );
                                    });
                              },
                              icon: const Icon(Icons.add_call)),
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
                              ),
                            ),
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                onTap: () => SingleDoctorScreen(doctor: doctor!)
                                    .launch(context),
                                child: Text("Doctor Info",
                                    style: primaryTextStyle(color: white)),
                              ),
                              PopupMenuItem(
                                onTap: () => PrescriptionScreen(
                                        appointment: widget.appointment)
                                    .launch(context),
                                child: Text("Prescriptions",
                                    style: primaryTextStyle(color: white)),
                              ),
                              PopupMenuItem(
                                onTap: () => LiveChatScreen().launch(context),
                                child: Text("Report Appointment",
                                    style: primaryTextStyle(color: white)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child:
                      !widget.appointment.isPaid.validate() && !widget.isExpired
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
                                  style: boldTextStyle(size: 20),
                                ),
                                10.height,
                                Text(
                                  "Contact support",
                                  style:
                                      boldTextStyle(size: 14, color: fireBrick),
                                ).onTap(() => HelpScreen().launch(context)),
                              ],
                            ).center()
                          : isYetToCommence
                              ? Center(
                                  child: Text(
                                    "Appointment is yet to commence",
                                    style: boldTextStyle(size: 14),
                                  ),
                                )
                              : isLoading
                                  ? const Center(child: Loader())
                                  : messages.isEmpty
                                      ? Center(
                                          child: Text(
                                            "No conversation yet",
                                            style: boldTextStyle(color: white),
                                          ),
                                        )
                                      : ListView.builder(
                                          controller: _scrollController,
                                          reverse: true, // Changed to false
                                          itemCount: messages.length,
                                          itemBuilder: (context, index) {
                                            // Display messages in reverse order
                                            int reversedIndex =
                                                messages.length - 1 - index;
                                            AppointmentConversationModel
                                                message =
                                                messages[reversedIndex];

                                            // Assign a GlobalKey to each message
                                            messageKeys[message.id.validate()] =
                                                GlobalKey();
                                            appointmentService.updateChatStatus(
                                                appointmentId:
                                                    widget.appointmentId,
                                                userId: widget.docId);

                                            String senderName = message
                                                        .senderId ==
                                                    userController.userId.value
                                                ? userName
                                                : "${doctor?.firstName} ${doctor?.lastName}";

                                            String getReplyText() {
                                              switch (message.type) {
                                                case MessageType.text:
                                                  return SecurityHelper()
                                                      .decryptText(message
                                                          .message
                                                          .validate());
                                                case MessageType.image:
                                                  String text = 'Photo';
                                                  if (message.message
                                                      .validate()
                                                      .isNotEmpty) {
                                                    text +=
                                                        ': ${SecurityHelper().decryptText(message.message.validate())}';
                                                  }
                                                  return text;
                                                case MessageType.voice:
                                                  return 'Voice message';
                                                case MessageType.file:
                                                  return 'File';
                                                default:
                                                  return 'Message';
                                              }
                                            }

                                            return Container(
                                              key: messageKeys[message.id],
                                              color: highlightedMessageId ==
                                                      message.id
                                                  ? _highlightAnimation.value
                                                  : null,
                                              child:
                                                  message.status ==
                                                          MessageStatus.deleted
                                                      ? BubbleSpecialThree(
                                                          isSender: message
                                                                  .senderId ==
                                                              userController
                                                                  .userId.value,
                                                          text:
                                                              'unsent message',
                                                          textStyle:
                                                              secondaryTextStyle(
                                                                  size: 10,
                                                                  fontStyle:
                                                                      FontStyle
                                                                          .italic),
                                                        )
                                                      : SwipeTo(
                                                          key: UniqueKey(),
                                                          onRightSwipe:
                                                              (details) =>
                                                                  handleReply(
                                                                      message,
                                                                      senderName),
                                                          child:
                                                              GestureDetector(
                                                            onLongPress: () =>
                                                                showOptions(
                                                                    message),
                                                            child: Column(
                                                              crossAxisAlignment: message
                                                                          .senderId ==
                                                                      userController
                                                                          .userId
                                                                          .value
                                                                  ? CrossAxisAlignment
                                                                      .end
                                                                  : CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                if (message.repliedTo !=
                                                                        null &&
                                                                    message
                                                                        .repliedTo!
                                                                        .isNotEmpty)
                                                                  GestureDetector(
                                                                    onTap: () =>
                                                                        scrollToRepliedMessage(
                                                                            message.repliedTo!),
                                                                    child:
                                                                        Container(
                                                                      padding:
                                                                          const EdgeInsets
                                                                              .all(
                                                                              8),
                                                                      margin: const EdgeInsets
                                                                          .only(
                                                                          bottom:
                                                                              4),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: Colors
                                                                            .grey
                                                                            .withOpacity(0.2),
                                                                        borderRadius:
                                                                            BorderRadius.circular(8),
                                                                        border: const Border(
                                                                            left:
                                                                                BorderSide(color: Colors.blue, width: 4)),
                                                                      ),
                                                                      child:
                                                                          Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Text(
                                                                            message.repliedSender?.validate() ??
                                                                                'Unknown',
                                                                            style:
                                                                                secondaryTextStyle(size: 12, color: Colors.blue),
                                                                          ),
                                                                          Text(
                                                                            SecurityHelper().decryptText(message.repliedText?.validate() ??
                                                                                ''),
                                                                            style:
                                                                                secondaryTextStyle(size: 12),
                                                                            maxLines:
                                                                                3,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                message.type ==
                                                                        MessageType
                                                                            .image
                                                                    ? Column(
                                                                        children: [
                                                                          BubbleNormalImage(
                                                                            onTap: () =>
                                                                                ImagePreview(imageUrl: message.fileUrl!).launch(context),
                                                                            id: message.id.validate(),
                                                                            tail:
                                                                                true,
                                                                            image:
                                                                                CachedNetworkImage(
                                                                              imageUrl: message.fileUrl!,
                                                                              fit: BoxFit.cover,
                                                                            ),
                                                                            sent: message.senderId != userController.userId.value
                                                                                ? false
                                                                                : message.status == MessageStatus.sent,
                                                                            delivered: message.senderId != userController.userId.value
                                                                                ? false
                                                                                : message.status == MessageStatus.delivered,
                                                                            seen: message.senderId != userController.userId.value
                                                                                ? false
                                                                                : message.status == MessageStatus.read,
                                                                            isSender:
                                                                                message.senderId == userController.userId.value,
                                                                          ),
                                                                          BubbleSpecialThree(
                                                                            isSender:
                                                                                message.senderId == userController.userId.value,
                                                                            sent:
                                                                                message.status == MessageStatus.sent,
                                                                            delivered: message.senderId != userController.userId.value
                                                                                ? false
                                                                                : message.status == MessageStatus.delivered,
                                                                            seen: message.senderId != userController.userId.value
                                                                                ? false
                                                                                : message.status == MessageStatus.read,
                                                                            text:
                                                                                SecurityHelper().decryptText(message.message.validate()),
                                                                            color:
                                                                                context.cardColor,
                                                                            tail:
                                                                                true,
                                                                            textStyle:
                                                                                primaryTextStyle(size: 16),
                                                                          ).visible(message
                                                                              .message!
                                                                              .isNotEmpty),
                                                                        ],
                                                                      )
                                                                    : message.type ==
                                                                            MessageType
                                                                                .voice
                                                                        ? BubbleNormalAudio(
                                                                            onSeekChanged:
                                                                                (s) {},
                                                                            onPlayPauseButtonClick:
                                                                                () {},
                                                                            textStyle:
                                                                                primaryTextStyle(),
                                                                            color:
                                                                                context.cardColor,
                                                                            sent: message.senderId != userController.userId.value
                                                                                ? false
                                                                                : message.status == MessageStatus.sent,
                                                                            delivered: message.senderId != userController.userId.value
                                                                                ? false
                                                                                : message.status == MessageStatus.delivered,
                                                                            seen: message.senderId != userController.userId.value
                                                                                ? false
                                                                                : message.status == MessageStatus.read,
                                                                          )
                                                                        : message.type ==
                                                                                MessageType.file
                                                                            ? SizedBox(
                                                                                width: 70,
                                                                                height: 70,
                                                                                child: Image.asset("assets/images/pdf.png", fit: BoxFit.cover),
                                                                              )
                                                                            : Column(
                                                                                children: [
                                                                                  BubbleSpecialThree(
                                                                                    isSender: message.senderId == userController.userId.value,
                                                                                    sent: message.status == MessageStatus.sent,
                                                                                    delivered: message.senderId != userController.userId.value ? false : message.status == MessageStatus.delivered,
                                                                                    seen: message.senderId != userController.userId.value ? false : message.status == MessageStatus.read,
                                                                                    text: SecurityHelper().decryptText(message.message!),
                                                                                    tail: true,
                                                                                    color: context.cardColor,
                                                                                    textStyle: primaryTextStyle(size: 16),
                                                                                  ),
                                                                                  BubbleSpecialTwo(
                                                                                    color: transparentColor,
                                                                                    text: "edited",
                                                                                    textStyle: secondaryTextStyle(
                                                                                      size: 10,
                                                                                      fontStyle: FontStyle.italic,
                                                                                    ),
                                                                                  ).visible(message.isEdited.validate()),
                                                                                ],
                                                                              ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                            );
                                          },
                                        ),
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
                                        child: const Icon(Icons.delete,
                                                color: fireBrick)
                                            .onTap(() {
                                          chatController.handleRemoveImage(x);
                                        }),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (isReplying)
                          Container(
                            padding: const EdgeInsets.all(8),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: context.cardColor.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(8),
                              border: const Border(
                                  left: BorderSide(
                                      color: Colors.green, width: 4)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.reply, color: Colors.green),
                                8.width,
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        repliedMessageSender?.validate() ??
                                            'Unknown',
                                        style: secondaryTextStyle(
                                            color: Colors.green),
                                      ),
                                      Text(
                                        repliedMessageText?.validate() ?? '',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: secondaryTextStyle(size: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.close, color: grey)
                                    .onTap(cancelReply),
                              ],
                            ),
                          ),
                        !widget.appointment.isPaid.validate() &&
                                !widget.isExpired
                            ? Obx(() => bookingController.isLoading.value
                                ? const Loader()
                                : Column(
                                    children: [
                                      AppButton(
                                        width: double.infinity,
                                        onTap: () async {
                                          showModalBottomSheet(
                                              context: context,
                                              builder: (context) {
                                                return Column(
                                                  children: [
                                                    AppButton(
                                                      onTap: () async {
                                                        try {
                                                          bookingController
                                                              .isLoading
                                                              .value = true;
                                                          setState(() {});
                                                          var userInfo = await userService
                                                              .getProfileById(
                                                                  userId:
                                                                      userController
                                                                          .userId
                                                                          .value);
                                                          await paymentController
                                                              .makePaystackPayment(
                                                            email: userInfo
                                                                .email
                                                                .validate(),
                                                            context: context,
                                                            amount: widget
                                                                .appointment
                                                                .price
                                                                .validate(),
                                                            paymentFor:
                                                                'Appointment',
                                                            productId: widget
                                                                .appointment.id,
                                                          );
                                                        } finally {
                                                          bookingController
                                                              .isLoading
                                                              .value = false;
                                                        }
                                                      },
                                                      width: double.infinity,
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            "Paystack",
                                                            style:
                                                                boldTextStyle(
                                                                    color:
                                                                        white),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    AppButton(
                                                      onTap: () async {
                                                        try {
                                                          bookingController
                                                              .isLoading
                                                              .value = true;
                                                          setState(() {});
                                                          var userInfo = await userService
                                                              .getProfileById(
                                                                  userId:
                                                                      userController
                                                                          .userId
                                                                          .value);
                                                          await paymentController
                                                              .makeFlutterwavePayment(
                                                            email: userInfo
                                                                .email
                                                                .validate(),
                                                            context: context,
                                                            amount: widget
                                                                .appointment
                                                                .price
                                                                .validate(),
                                                            paymentFor:
                                                                'Appointment',
                                                            productId: widget
                                                                .appointment.id,
                                                          );
                                                        } finally {
                                                          bookingController
                                                              .isLoading
                                                              .value = false;
                                                        }
                                                      },
                                                      width: double.infinity,
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            "Flutterwave",
                                                            style:
                                                                boldTextStyle(
                                                                    color:
                                                                        white),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              });
                                        },
                                        text: "Make Payment",
                                        color: white,
                                        textColor: kPrimary,
                                      ),
                                    ],
                                  ))
                            : widget.isExpired
                                ? Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: context.cardColor,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(20),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text("View prescription",
                                            style: boldTextStyle()),
                                      ],
                                    ),
                                  ).onTap(() => PrescriptionScreen(
                                        appointment: widget.appointment)
                                    .launch(context))
                                : Form(
                                    key: _formKey,
                                    child: AppTextField(
                                      textFieldType: TextFieldType.MULTILINE,
                                      controller: messageController,
                                      focus: _focusNode,
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
                                                          color: kPrimary)
                                                      .onTap(() {
                                                    showModalBottomSheet(
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
                                                                  .circular(20),
                                                              topRight: Radius
                                                                  .circular(20),
                                                            ),
                                                          ),
                                                          child: GridView.count(
                                                            crossAxisCount: 3,
                                                            crossAxisSpacing:
                                                                10,
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
                                                                        size:
                                                                            30),
                                                                  ),
                                                                  Text(
                                                                      "Documents",
                                                                      style: primaryTextStyle(
                                                                          size:
                                                                              14)),
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
                                                                        size:
                                                                            30),
                                                                  ),
                                                                  Text(
                                                                      "Gallery",
                                                                      style: primaryTextStyle(
                                                                          size:
                                                                              14)),
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
                                                                        Icons
                                                                            .camera,
                                                                        size:
                                                                            30),
                                                                  ),
                                                                  Text("Camera",
                                                                      style: primaryTextStyle(
                                                                          size:
                                                                              14)),
                                                                ],
                                                              ).onTap(() {
                                                                Get.back();
                                                                chatController
                                                                    .handleGetCamera();
                                                              }),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    );
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
                                                          child: Icon(Icons.mic,
                                                              color: white),
                                                        ).onTap(() {})
                                                      : const CircleAvatar(
                                                          backgroundColor:
                                                              kPrimary,
                                                          child: Icon(
                                                              Icons.send,
                                                              color: white),
                                                        ).onTap(() async {
                                                          if (_formKey
                                                                  .currentState!
                                                                  .validate() ||
                                                              chatController
                                                                  .images
                                                                  .isNotEmpty ||
                                                              chatController
                                                                  .files
                                                                  .isNotEmpty) {
                                                            await chatController
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
                                                              repliedTo:
                                                                  repliedTo,
                                                              repliedText:
                                                                  repliedMessageText,
                                                              repliedSender:
                                                                  repliedMessageSender,
                                                            );
                                                            messageController
                                                                .clear();
                                                            cancelReply();
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
