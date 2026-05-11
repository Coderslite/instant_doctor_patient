// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/constant/constants.dart';
import 'package:instant_doctor/controllers/ChatController.dart';
import 'package:instant_doctor/controllers/UserController.dart';
import 'package:instant_doctor/models/AppointmentModel.dart';
import 'package:instant_doctor/models/UserModel.dart';
import 'package:instant_doctor/screens/chat/RateScreen.dart';
import 'package:instant_doctor/screens/chat/widgets/ChatHeader.dart';
import 'package:instant_doctor/screens/chat/widgets/ChatInput.dart';
import 'package:instant_doctor/screens/chat/widgets/ChatMessageArea.dart';
import 'package:instant_doctor/screens/chat/ProfileCompletenessUpdate.dart';
import 'package:instant_doctor/services/UserService.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../controllers/BookingController.dart';
import '../../controllers/PaymentController.dart';
import '../../services/AppointmentService.dart';
import '../../services/DoctorService.dart';
import '../../services/SecurityHelper.dart';
import '../../services/ReviewService.dart';

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
    with TickerProviderStateMixin {
  final chatController = Get.find<ChatController>();
  final bookingController = Get.find<BookingController>();
  final paymentController = Get.find<PaymentController>();
  final userController = Get.find<UserController>();
  final userService = Get.find<UserService>();
  final doctorService = Get.find<DoctorService>();
  final appointmentService = Get.find<AppointmentService>();

  late Timer timer;
  String token = '';
  UserModel? doctor;
  UserModel? me;
  String userName = '';
  String repliedTo = '';
  String? repliedMessageText;
  String? repliedMessageSender;
  bool isReplying = false;

  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController messageController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isReviewed = false;
  List<AppointmentConversationModel> messages = [];
  bool isLoading = true;
  String? highlightedMessageId;

  late AnimationController _animationController;
  late Animation<Color?> _highlightAnimation;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  final Map<String, GlobalKey> messageKeys = {};

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));

    handleGetUserToken();
    handleCheckReview();
    _fetchMessages();

    _animationController =
        AnimationController(duration: const Duration(seconds: 3), vsync: this);
    _highlightAnimation = ColorTween(
      begin: kPrimary.withOpacity(0.15),
      end: Colors.transparent,
    ).animate(_animationController)
      ..addListener(() => setState(() {}));

    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.3, end: 1.0)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    handleCheckMedicals();
  }

  @override
  void dispose() {
    timer.cancel();
    messageController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> handleGetUserToken() async {
    token = await userService.getUserToken(userId: widget.docId);
    doctor = await userService.getProfileById(userId: widget.docId);
    me = await userService.getProfileById(userId: userController.userId.value);
    userName = '${me!.firstName.validate()} ${me!.lastName.validate()}';
    setState(() {});
  }

  Future<void> handleCheckReview() async {
    final reviewService = Get.find<ReviewService>();
    final res = await reviewService.getAppointmentReview(
        docId: widget.docId, appointmentId: widget.appointmentId);
    isReviewed = res != null;
    setState(() {});
    if (widget.isExpired && !isReviewed) {
      showDialog(
        context: context,
        barrierColor: Colors.black87,
        barrierDismissible: false,
        builder: (_) => Ratescreen(
          docId: widget.docId,
          appointment: widget.appointment,
          appointmentId: widget.appointmentId,
          isExpired: widget.isExpired,
          doctor: doctor!,
          isReviewed: isReviewed,
          update: widget.update,
        ),
      );
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
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.minScrollExtent);
        }
      });
    });
  }

  void handleReply(AppointmentConversationModel msg, String senderName) {
    String replyText = msg.type == MessageType.text
        ? SecurityHelper().decryptText(msg.message.validate())
        : 'Attachment';
    if (replyText.length > 100) replyText = '${replyText.substring(0, 100)}...';
    setState(() {
      isReplying = true;
      repliedTo = msg.id.validate();
      repliedMessageText = replyText;
      repliedMessageSender = senderName;
    });
    FocusScope.of(context).requestFocus(_focusNode);
  }

  void cancelReply() => setState(() {
        isReplying = false;
        repliedTo = '';
        repliedMessageText = null;
        repliedMessageSender = null;
      });

  void scrollToRepliedMessage(String messageId) {
    final key = messageKeys[messageId];
    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(key.currentContext!,
          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
      setState(() => highlightedMessageId = messageId);
      _animationController.reset();
      _animationController
          .forward()
          .then((_) => setState(() => highlightedMessageId = null));
    }
  }

  Future<void> handleSendMessage() async {
    if (messageController.text.trim().isEmpty && chatController.images.isEmpty)
      return;
    final text = messageController.text.trim();
    messageController.clear();
    final rTo = repliedTo;
    final rText = repliedMessageText;
    final rSender = repliedMessageSender;
    cancelReply();

    await chatController.handleSendChat(
      appointmentId: widget.appointmentId,
      docId: widget.docId,
      message: text,
      repliedTo: rTo,
      repliedMessageText: rText,
      repliedMessageSender: rSender,
      type: MessageType.text,
    );
  }

  void _showAttachments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _AttachOption(
              icon: Icons.image_rounded,
              label: 'Gallery',
              onTap: () {
                Get.back();
                chatController.handlePickImage(isCamera: false);
              }),
          _AttachOption(
              icon: Icons.camera_alt_rounded,
              label: 'Camera',
              onTap: () {
                Get.back();
                chatController.handlePickImage(isCamera: true);
              }),
        ]),
      ),
    );
  }

  Future<void> handleCheckMedicals() async {
    while (true) {
      var user =
          await userService.getProfileById(userId: userController.userId.value);

      final medicalOk = user.bloodGroup.validate().isNotEmpty &&
          user.height.validate().isNotEmpty &&
          user.weight.validate().isNotEmpty &&
          user.genotype.validate().isNotEmpty;

      final personalOk = user.dob != null && user.address.validate().isNotEmpty;

      if (!medicalOk || !personalOk) {
        await showModalBottomSheet(
          context: context,
          isDismissible: false,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: ProfileCompletenessUpdate(user: user),
          ),
        );
        continue;
      }
      break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = Timestamp.now();
    final startTime = widget.appointment.startTime;
    final endTime = widget.appointment.endTime;
    final isExpired = now.compareTo(endTime!) > 0;
    final isYetToStart = now.compareTo(startTime!) < 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FA),
      body: KeyboardDismisser(
        child: Column(children: [
          ChatHeader(
            docId: widget.docId,
            appointment: widget.appointment,
            doctorService: doctorService,
            pulseAnim: _pulseAnim,
            isExpired: isExpired,
            isYetToStart: isYetToStart,
            userName: userName,
            appointmentId: widget.appointmentId,
            doctor: doctor,
          ),
          Expanded(
            child: ChatMessageArea(
              isExpired: isExpired,
              isYetToStart: isYetToStart,
              isLoading: isLoading,
              messages: messages,
              scrollController: _scrollController,
              appointmentId: widget.appointmentId,
              docId: widget.docId,
              userId: userController.userId.value,
              userName: userName,
              doctor: doctor,
              appointment: widget.appointment,
              appointmentService: appointmentService,
              messageKeys: messageKeys,
              onReply: handleReply,
              onOptions: (msg) {}, // Add options sheet if needed
              onReplyTap: scrollToRepliedMessage,
              highlightAnimation: _highlightAnimation,
              highlightedMessageId: highlightedMessageId,
            ),
          ),
          ChatInput(
            controller: messageController,
            focusNode: _focusNode,
            formKey: _formKey,
            isExpired: isExpired,
            isYetToStart: isYetToStart,
            isReplying: isReplying,
            repliedMessageSender: repliedMessageSender,
            repliedMessageText: repliedMessageText,
            onCancelReply: cancelReply,
            onSend: handleSendMessage,
            onAttach: () => _showAttachments(context),
            appointment: widget.appointment,
          ),
        ]),
      ),
    );
  }
}

class _AttachOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _AttachOption(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: kPrimary),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      onTap: onTap,
    );
  }
}
