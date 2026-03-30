// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/component/ProfileImage.dart';
import 'package:instant_doctor/component/snackBar.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/constant/constants.dart';
import 'package:instant_doctor/controllers/ChatController.dart';
import 'package:instant_doctor/controllers/UserController.dart';
import 'package:instant_doctor/models/AppointmentModel.dart';
import 'package:instant_doctor/models/UserModel.dart';
import 'package:instant_doctor/screens/chat/RateScreen.dart';
import 'package:instant_doctor/screens/doctors/SingleDoctor.dart';
import 'package:instant_doctor/screens/profile/help/Help.dart';
import 'package:instant_doctor/screens/profile/medical/MedicalData.dart';
import 'package:instant_doctor/services/ReviewService.dart';
import 'package:instant_doctor/services/UserService.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
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
import '../profile/personal/PersonalProfile.dart';
import 'ImagePreview.dart';

// ─── Palette ───────────────────────────────────────────────────────────────────
const _obsidian = Color(0xFF0A1628);
const _chatBg = Color(0xFFF0F4FA);
const _white = Colors.white;
const _ink = Color(0xFF0F2744);
const _slate = Color(0xFF5E7A99);
const _border = Color(0xFFE5EAF4);
const _green = Color(0xFF10B981);
const _redSoft = Color(0xFFFFEDED);
const _redText = Color(0xFFDC2626);
const _replyAccent = Color(0xFF3B82F6);

// ─────────────────────────────────────────────────────────────────────────────
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
  // ── Controllers (unchanged) ───────────────────────────────────────────────
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

  // ── Pulse for live dot ────────────────────────────────────────────────────
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  final Map<String, GlobalKey> messageKeys = {};

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    messageController.addListener(updateSendButtonVisibility);
    timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));

    handleGetUserToken();
    handleCheckReview();
    _fetchMessages();

    // Highlight animation
    _animationController =
        AnimationController(duration: const Duration(seconds: 3), vsync: this);
    _highlightAnimation = ColorTween(
      begin: kPrimary.withOpacity(0.15),
      end: Colors.transparent,
    ).animate(_animationController)
      ..addListener(() => setState(() {}));

    // Live dot pulse
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.3, end: 1.0)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    handleCheckMedicals();
  }

  void updateSendButtonVisibility() => setState(() {});

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

  // ── Logic unchanged ───────────────────────────────────────────────────────
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
        if (isReplying) {
          isReplying = false;
          repliedTo = '';
          repliedMessageText = null;
          repliedMessageSender = null;
        }
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.minScrollExtent);
        }
      });
    });
  }

  void handleReply(AppointmentConversationModel msg, String senderName) {
    String replyText;
    switch (msg.type) {
      case MessageType.text:
        replyText = SecurityHelper().decryptText(msg.message.validate());
        break;
      case MessageType.image:
        replyText = 'Photo';
        if (msg.message.validate().isNotEmpty) {
          replyText +=
              ': ${SecurityHelper().decryptText(msg.message.validate())}';
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

  void showOptions(AppointmentConversationModel msg) {
    if (msg.senderId != userController.userId.value) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _OptionsSheet(
        onEdit: () {
          Get.back();
          editText(msg);
        },
        onDelete: () {
          finish(context);
          deleteText(msg);
        },
      ),
    );
  }

  Future<void> deleteText(AppointmentConversationModel msg) async {
    showConfirmDialogCustom(
      context,
      title: 'Delete this message?',
      onAccept: (_) async => appointmentService.deleteChat(
        appointmentId: widget.appointmentId,
        chatId: msg.id.validate(),
      ),
    );
  }

  void editText(AppointmentConversationModel msg) {
    final current = SecurityHelper().decryptText(msg.message!);
    final ctrl = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (_) => _EditDialog(
        controller: ctrl,
        onSave: () async {
          final newText = ctrl.text.trim();
          if (newText.isNotEmpty && newText != current) {
            await appointmentService.updateChatText(
              appointmentId: widget.appointmentId,
              chatId: msg.id.validate(),
              message: SecurityHelper().encryptText(newText),
            );
          }
          finish(context);
        },
      ),
    );
  }

  void scrollToRepliedMessage(String repliedToId) {
    final idx =
        messages.reversed.toList().indexWhere((m) => m.id == repliedToId);
    if (idx == -1 || !_scrollController.hasClients) return;

    double totalH = 0;
    final rev = messages.reversed.toList();
    for (int i = 0; i <= idx; i++) {
      final m = rev[i];
      double h = m.type == MessageType.image ? 220.0 : 60.0;
      if (m.repliedTo != null && m.repliedTo!.isNotEmpty) h += 60;
      totalH += h;
    }
    _scrollController.animateTo(totalH,
        duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    setState(() {
      highlightedMessageId = repliedToId;
      _animationController.forward();
    });
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => highlightedMessageId = null);
        _animationController.reset();
      }
    });
  }

  Future<void> handleCheckMedicals() async {
    while (true) {
      var user =
          await userService.getProfileById(userId: userController.userId.value);

      final medicalOk = user.bloodGroup.validate().isNotEmpty &&
          user.weight.validate().isNotEmpty &&
          user.height.validate().isNotEmpty;

      if (!medicalOk) {
        await showModalBottomSheet(
          context: context,
          isDismissible: false,
          scrollControlDisabledMaxHeightRatio: 0.8,
          builder: (context) {
            return BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: MedicalDataScreen(isModal: true),
            );
          },
        );

        // After bottom sheet closes, loop runs again
        continue;
      }

      break; // Medical data is complete → exit loop
    }

    // ===============================
    // Now Check Personal Profile
    // ===============================

    while (true) {
      var user =
          await userService.getProfileById(userId: userController.userId.value);

      final personalOk = user.dob != null && user.address.validate().isNotEmpty;

      if (!personalOk) {
        await showModalBottomSheet(
          context: context,
          isDismissible: false,
          scrollControlDisabledMaxHeightRatio: 0.8,
          builder: (context) {
            return BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: PersonalProfileScreen(
                isModal: true,
              ),
            );
          },
        );

        continue;
      }

      break; // Personal data complete
    }

    // 🎉 Everything complete
  }

  // ─── BUILD ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final now = Timestamp.now();
    final startTime = widget.appointment.startTime;
    final endTime = widget.appointment.endTime;
    final isExpired = now.compareTo(endTime!) > 0;
    final isOngoing =
        now.compareTo(startTime!) >= 0 && now.compareTo(endTime) <= 0;
    final isYetToStart = now.compareTo(startTime) <= 0;

    return Scaffold(
      backgroundColor: _chatBg,
      body: KeyboardDismisser(
        child: Column(children: [
          // ── Premium header ─────────────────────────────────────────────
          _ChatHeader(
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

          internetCheck(),
          countryCheck(),

          // ── Message list ───────────────────────────────────────────────
          Expanded(child: _buildMessageArea(isExpired, isYetToStart)),

          // ── Input area ─────────────────────────────────────────────────
          _buildInputArea(isExpired, isYetToStart),
        ]),
      ),
    );
  }

  // ── Message area ───────────────────────────────────────────────────────────
  Widget _buildMessageArea(bool isExpired, bool isYetToStart) {
    if (!widget.appointment.isPaid.validate() && !widget.isExpired) {
      return _UnpaidState(onHelp: () => HelpScreen().launch(context));
    }
    if (isYetToStart) {
      return _StatusState(
        icon: Icons.schedule_rounded,
        label: 'Appointment not started yet',
        sub: 'Please wait for your scheduled time.',
      );
    }
    if (isLoading) {
      return Center(child: CircularProgressIndicator(color: kPrimary));
    }
    if (messages.isEmpty) {
      return _StatusState(
        icon: Icons.chat_bubble_outline_rounded,
        label: 'No messages yet',
        sub: 'Start the conversation below.',
      );
    }

    return Stack(children: [
      // Subtle dot-grid background
      Positioned.fill(child: CustomPaint(painter: _DotGridPainter())),

      ListView.builder(
        controller: _scrollController,
        reverse: true,
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        itemCount: messages.length,
        itemBuilder: (_, i) {
          final idx = messages.length - 1 - i;
          final msg = messages[idx];

          messageKeys[msg.id.validate()] = GlobalKey();
          appointmentService.updateChatStatus(
            appointmentId: widget.appointmentId,
            userId: widget.docId,
          );

          final isMine = msg.senderId == userController.userId.value;
          final senderName =
              isMine ? userName : '${doctor?.firstName} ${doctor?.lastName}';

          return Container(
            key: messageKeys[msg.id],
            color: highlightedMessageId == msg.id
                ? _highlightAnimation.value
                : null,
            child: msg.status == MessageStatus.deleted
                ? _DeletedBubble(isMine: isMine)
                : SwipeTo(
                    key: UniqueKey(),
                    onRightSwipe: (_) => handleReply(msg, senderName),
                    child: GestureDetector(
                      onLongPress: () => showOptions(msg),
                      child: _MessageBubble(
                        message: msg,
                        isMine: isMine,
                        senderName: senderName,
                        onReplyTap: scrollToRepliedMessage,
                        userControllerUserId: userController.userId.value,
                      ),
                    ),
                  ),
          );
        },
      ),
    ]);
  }

  // ── Input area ─────────────────────────────────────────────────────────────
  Widget _buildInputArea(bool isExpired, bool isYetToStart) {
    return Obx(() => Container(
          decoration: const BoxDecoration(
            color: _white,
            border: Border(top: BorderSide(color: _border, width: 1)),
            boxShadow: [
              BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 20,
                  offset: Offset(0, -4))
            ],
          ),
          padding: EdgeInsets.fromLTRB(
              12, 10, 12, MediaQuery.of(context).padding.bottom + 10),
          child: Column(children: [
            // Image previews
            if (chatController.images.isNotEmpty)
              _ImagePreviewStrip(
                images: chatController.images,
                onRemove: chatController.handleRemoveImage,
              ),

            // Reply banner
            if (isReplying)
              _ReplyBanner(
                sender: repliedMessageSender ?? '',
                text: repliedMessageText ?? '',
                onCancel: cancelReply,
              ),

            // ── Main input row ───────────────────────────────────────────
            if (!widget.appointment.isPaid.validate() && !widget.isExpired)
              _PaymentButton(
                isLoading: bookingController.isLoading.value,
                appointment: widget.appointment,
                userService: userService,
                userController: userController,
                paymentController: paymentController,
                bookingController: bookingController,
              )
            else if (widget.isExpired)
              _PrescriptionBar(appointment: widget.appointment)
            else
              Form(
                key: _formKey,
                child: Row(children: [
                  // Attachment button
                  _IconBtn(
                    icon: Icons.attach_file_rounded,
                    onTap: () => _showAttachments(context),
                  ),

                  const SizedBox(width: 8),

                  // Text field
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: _chatBg,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: _border, width: 1),
                      ),
                      child: AppTextField(
                        textFieldType: TextFieldType.MULTILINE,
                        controller: messageController,
                        focus: _focusNode,
                        minLines: 1,
                        maxLines: 4,
                        enabled: !isExpired && !isYetToStart,
                        decoration: InputDecoration(
                          hintText: isYetToStart
                              ? 'Waiting for appointment to start...'
                              : isExpired
                                  ? 'This session has ended'
                                  : 'Type a message...',
                          hintStyle: TextStyle(
                              fontSize: 13, color: _slate.withOpacity(0.6)),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Send / mic
                  chatController.isLoading.value
                      ? SizedBox(
                          width: 42,
                          height: 42,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: kPrimary))
                      : _SendButton(
                          hasContent: messageController.text.isNotEmpty ||
                              chatController.files.isNotEmpty ||
                              chatController.images.isNotEmpty,
                          onSend: () async {
                            if (_formKey.currentState!.validate() ||
                                chatController.images.isNotEmpty ||
                                chatController.files.isNotEmpty) {
                              await chatController.handleSendMessage(
                                docId: widget.docId,
                                myName: userName,
                                message: messageController.text,
                                appointmentId: widget.appointmentId,
                                token: token.validate(),
                                repliedTo: repliedTo,
                                repliedText: repliedMessageText,
                                repliedSender: repliedMessageSender,
                              );
                              messageController.clear();
                              cancelReply();
                            }
                          },
                          onMic: () {},
                        ),
                ]),
              ),
          ]),
        ));
  }

  void _showAttachments(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      builder: (_) => _AttachmentSheet(
        onDocuments: () {
          Get.back();
          chatController.handleGetDoc();
        },
        onGallery: () {
          Get.back();
          chatController.handleGetGallery();
        },
        onCamera: () {
          Get.back();
          chatController.handleGetCamera();
        },
      ),
    );
  }
}

// =============================================================================
// HEADER
// =============================================================================
class _ChatHeader extends StatelessWidget {
  final String docId;
  final AppointmentModel appointment;
  final DoctorService doctorService;
  final Animation<double> pulseAnim;
  final bool isExpired;
  final bool isYetToStart;
  final String userName;
  final String appointmentId;
  final UserModel? doctor;

  const _ChatHeader({
    required this.docId,
    required this.appointment,
    required this.doctorService,
    required this.pulseAnim,
    required this.isExpired,
    required this.isYetToStart,
    required this.userName,
    required this.appointmentId,
    required this.doctor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _obsidian,
        boxShadow: [
          BoxShadow(
              color: Color(0x30000000), blurRadius: 16, offset: Offset(0, 4))
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 6, 12, 10),
          child: Row(children: [
            // Back
            IconButton(
              onPressed: () => finish(context),
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 18, color: _white),
            ),

            // Doctor info
            Expanded(
              child: StreamBuilder<UserModel>(
                stream: doctorService.getDoc(docId: docId),
                builder: (_, snap) {
                  if (!snap.hasData) return const SizedBox();
                  final doc = snap.data!;
                  final online = doc.status.validate() == ONLINE;
                  return GestureDetector(
                    onTap: () {
                      if (doctor != null) {
                        SingleDoctorScreen(doctor: doctor!).launch(context);
                      }
                    },
                    child: Row(children: [
                      // Avatar with status ring
                      Stack(children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: online
                                  ? _green.withOpacity(0.6)
                                  : Colors.white.withOpacity(0.15),
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child: profileImage(doc, 42, 42, context: context),
                          ),
                        ),
                        if (online)
                          Positioned(
                            bottom: 1,
                            right: 1,
                            child: AnimatedBuilder(
                              animation: pulseAnim,
                              builder: (_, __) => Container(
                                width: 11,
                                height: 11,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _green,
                                  border:
                                      Border.all(color: _obsidian, width: 1.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _green
                                          .withOpacity(pulseAnim.value * 0.6),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ]),

                      const SizedBox(width: 10),

                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dr. ${doc.firstName} ${doc.lastName}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _white,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(children: [
                            if (online)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _green.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: _green.withOpacity(0.3), width: 1),
                                ),
                                child: Text('Online',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: _green,
                                      fontWeight: FontWeight.w600,
                                    )),
                              )
                            else
                              Text(
                                doc.lastSeen == null
                                    ? 'Offline'
                                    : 'Last seen ${timeago.format(doc.lastSeen!.toDate())}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white.withOpacity(0.4),
                                ),
                              ),
                          ]),
                          if (appointment.isPaid.validate() || !isExpired) ...[
                            const SizedBox(width: 8),
                            TimeRemaining(appointment: appointment),
                          ],
                        ],
                      )),
                    ]),
                  );
                },
              ),
            ),

            // Call button
            _HeaderIconBtn(
              icon: Icons.call_outlined,
              onTap: () => _showCallSheet(context),
            ),

            const SizedBox(width: 4),

            // More menu
            PopupMenuButton(
              color: _obsidian,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              icon:
                  const Icon(Icons.more_vert_rounded, color: _white, size: 22),
              itemBuilder: (_) => [
                PopupMenuItem(
                  onTap: () {
                    if (doctor != null) {
                      SingleDoctorScreen(doctor: doctor!).launch(context);
                    }
                  },
                  child: _popItem(Icons.person_outline_rounded, 'Doctor Info'),
                ),
                PopupMenuItem(
                  onTap: () => PrescriptionScreen(appointment: appointment)
                      .launch(context),
                  child: _popItem(Icons.description_outlined, 'Prescriptions'),
                ),
                PopupMenuItem(
                  onTap: () => LiveChatScreen().launch(context),
                  child: _popItem(Icons.flag_outlined, 'Report Appointment'),
                ),
              ],
            ),
          ]),
        ),
      ),
    );
  }

  Widget _popItem(IconData icon, String label) => Row(children: [
        Icon(icon, size: 18, color: Colors.white.withOpacity(0.7)),
        const SizedBox(width: 10),
        Text(label,
            style: const TextStyle(
                fontSize: 13, color: _white, fontWeight: FontWeight.w500)),
      ]);

  void _showCallSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _CallSheet(
        appointmentId: appointmentId,
        appointment: appointment,
        userName: userName,
        isExpired: isExpired,
        isYetToStart: isYetToStart,
      ),
    );
  }
}

// =============================================================================
// CALL SHEET
// =============================================================================
class _CallSheet extends StatelessWidget {
  final String appointmentId;
  final AppointmentModel appointment;
  final String userName;
  final bool isExpired;
  final bool isYetToStart;
  const _CallSheet({
    required this.appointmentId,
    required this.appointment,
    required this.userName,
    required this.isExpired,
    required this.isYetToStart,
  });

  void _guard(BuildContext ctx) {
    if (isYetToStart) {
      errorSnackBar(context: ctx, title: 'Appointment is yet to commence');
      return;
    }
    if (isExpired) {
      errorSnackBar(context: ctx, title: 'Appointment has expired');
      return;
    }
    if (!appointment.isPaid.validate()) {
      errorSnackBar(
          context: ctx, title: "Payment not made for this appointment");
      return;
    }
    finish(ctx);
  }

  @override
  Widget build(BuildContext context) {
    final canCall =
        !isExpired && appointment.isPaid.validate() && !isYetToStart;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Handle
        Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: _border, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 20),
        const Text('Start a Call',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: _ink,
                letterSpacing: -0.3)),
        const SizedBox(height: 20),

        // Video
        _CallOption(
          icon: Icons.videocam_rounded,
          label: 'Video Call',
          color: kPrimary,
          enabled: canCall,
          zegoButton: ZegoSendCallInvitationButton(
            callID: appointmentId,
            iconSize: const Size(1, 1),
            buttonSize: const Size(1, 1),
            iconVisible: false,
            isVideoCall: true,
            resourceID: 'instantdoctorservice',
            invitees: [
              ZegoUIKitUser(id: appointment.doctorId.validate(), name: userName)
            ],
          ),
          onGuard: () => _guard(context),
        ),

        const SizedBox(height: 12),

        // Audio
        _CallOption(
          icon: Icons.call_rounded,
          label: 'Audio Call',
          color: _green,
          enabled: canCall,
          zegoButton: ZegoSendCallInvitationButton(
            callID: appointmentId,
            iconSize: const Size(1, 1),
            buttonSize: const Size(1, 1),
            iconVisible: false,
            isVideoCall: false,
            resourceID: 'instantdoctorservice',
            invitees: [
              ZegoUIKitUser(id: appointment.doctorId.validate(), name: userName)
            ],
          ),
          onGuard: () => _guard(context),
        ),

        SizedBox(height: MediaQuery.of(context).padding.bottom + 12),
      ]),
    );
  }
}

class _CallOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool enabled;
  final Widget zegoButton;
  final VoidCallback onGuard;
  const _CallOption(
      {required this.icon,
      required this.label,
      required this.color,
      required this.enabled,
      required this.zegoButton,
      required this.onGuard});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onGuard,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: enabled ? color.withOpacity(0.07) : const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: enabled ? color.withOpacity(0.2) : _border, width: 1),
        ),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: enabled ? color.withOpacity(0.12) : _border,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: enabled ? color : _slate, size: 20),
          ),
          const SizedBox(width: 14),
          Text(label,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: enabled ? _ink : _slate)),
          const Spacer(),
          Opacity(opacity: 0, child: zegoButton), // Hidden but functional
          Icon(Icons.arrow_forward_ios_rounded,
              size: 13, color: enabled ? color : _slate.withOpacity(0.4)),
        ]),
      ),
    );
  }
}

// =============================================================================
// MESSAGE BUBBLE
// =============================================================================
class _MessageBubble extends StatelessWidget {
  final AppointmentConversationModel message;
  final bool isMine;
  final String senderName;
  final String userControllerUserId;
  final void Function(String) onReplyTap;
  const _MessageBubble({
    required this.message,
    required this.isMine,
    required this.senderName,
    required this.onReplyTap,
    required this.userControllerUserId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        // Reply preview
        if (message.repliedTo != null && message.repliedTo!.isNotEmpty)
          GestureDetector(
            onTap: () => onReplyTap(message.repliedTo!),
            child: Container(
              margin:
                  EdgeInsets.fromLTRB(isMine ? 60 : 12, 6, isMine ? 12 : 60, 0),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _replyAccent.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: const Border(
                    left: BorderSide(color: _replyAccent, width: 3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(message.repliedSender?.validate() ?? 'Unknown',
                      style: const TextStyle(
                          fontSize: 11,
                          color: _replyAccent,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(
                    SecurityHelper()
                        .decryptText(message.repliedText?.validate() ?? ''),
                    style: const TextStyle(fontSize: 12, color: _slate),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),

        // Bubble
        _buildBubble(context),

        // Edited
        if (message.isEdited.validate())
          Padding(
            padding: EdgeInsets.only(
                right: isMine ? 16 : 0, left: isMine ? 0 : 16, bottom: 2),
            child: Text('edited',
                style: TextStyle(
                    fontSize: 9,
                    color: _slate.withOpacity(0.5),
                    fontStyle: FontStyle.italic)),
          ),
      ],
    );
  }

  Widget _buildBubble(BuildContext context) {
    switch (message.type) {
      case MessageType.image:
        return Column(
          crossAxisAlignment:
              isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            BubbleNormalImage(
              onTap: () =>
                  ImagePreview(imageUrl: message.fileUrl!).launch(context),
              id: message.id.validate(),
              tail: true,
              image: CachedNetworkImage(
                  imageUrl: message.fileUrl!, fit: BoxFit.cover),
              isSender: isMine,
              sent: isMine && message.status == MessageStatus.sent,
              delivered: isMine && message.status == MessageStatus.delivered,
              seen: isMine && message.status == MessageStatus.read,
            ),
            if (message.message.validate().isNotEmpty)
              _PremiumBubble(
                text: SecurityHelper().decryptText(message.message.validate()),
                isMine: isMine,
                status: message.status,
              ),
          ],
        );

      case MessageType.file:
        return Container(
          margin: EdgeInsets.fromLTRB(isMine ? 80 : 12, 4, isMine ? 12 : 80, 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isMine ? kPrimary.withOpacity(0.08) : _white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _border),
          ),
          child: Row(children: [
            const Icon(Icons.insert_drive_file_outlined,
                color: kPrimary, size: 28),
            const SizedBox(width: 8),
            const Text('File attachment',
                style: TextStyle(
                    fontSize: 13, color: _ink, fontWeight: FontWeight.w500)),
          ]),
        );

      default: // text + voice
        return _PremiumBubble(
          text: SecurityHelper().decryptText(message.message!),
          isMine: isMine,
          status: message.status,
        );
    }
  }
}

// ─── Premium text bubble ──────────────────────────────────────────────────────
class _PremiumBubble extends StatelessWidget {
  final String text;
  final bool isMine;
  final String? status;
  const _PremiumBubble({required this.text, required this.isMine, this.status});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.fromLTRB(isMine ? 72 : 12, 3, isMine ? 12 : 72, 3),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: isMine
              ? LinearGradient(
                  colors: [kPrimary, kPrimaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isMine ? null : _white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMine ? 18 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 18),
          ),
          boxShadow: [
            BoxShadow(
              color: isMine
                  ? kPrimary.withOpacity(0.2)
                  : Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(text,
                style: TextStyle(
                    fontSize: 14, color: isMine ? _white : _ink, height: 1.4)),
            const SizedBox(height: 4),
            Row(mainAxisSize: MainAxisSize.min, children: [
              if (status != null && isMine)
                Icon(
                  status == MessageStatus.read
                      ? Icons.done_all_rounded
                      : status == MessageStatus.delivered
                          ? Icons.done_all_rounded
                          : Icons.done_rounded,
                  size: 13,
                  color: status == MessageStatus.read
                      ? const Color(0xFF67E8F9)
                      : _white.withOpacity(0.5),
                ),
            ]),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// DELETED BUBBLE
// =============================================================================
class _DeletedBubble extends StatelessWidget {
  final bool isMine;
  const _DeletedBubble({required this.isMine});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.fromLTRB(isMine ? 80 : 12, 3, isMine ? 12 : 80, 3),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.block_rounded, size: 12, color: _slate.withOpacity(0.5)),
          const SizedBox(width: 5),
          Text('Message unsent',
              style: TextStyle(
                  fontSize: 12,
                  color: _slate.withOpacity(0.6),
                  fontStyle: FontStyle.italic)),
        ]),
      ),
    );
  }
}

// =============================================================================
// STATUS STATES
// =============================================================================
class _StatusState extends StatelessWidget {
  final IconData icon;
  final String label, sub;
  const _StatusState(
      {required this.icon, required this.label, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: kPrimary.withOpacity(0.07),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: kPrimary.withOpacity(0.5), size: 32),
        ),
        const SizedBox(height: 14),
        Text(label,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w700, color: _ink)),
        const SizedBox(height: 6),
        Text(sub,
            style: TextStyle(fontSize: 12, color: _slate.withOpacity(0.7))),
      ]),
    );
  }
}

class _UnpaidState extends StatelessWidget {
  final VoidCallback onHelp;
  const _UnpaidState({required this.onHelp});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _redSoft,
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.payment_outlined, color: _redText, size: 36),
          ),
          const SizedBox(height: 16),
          const Text('Payment Required',
              style: TextStyle(
                  fontSize: 17, fontWeight: FontWeight.w800, color: _ink)),
          const SizedBox(height: 8),
          Text('Complete your payment to access this consultation.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: _slate, height: 1.5)),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: onHelp,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: _redSoft,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _redText.withOpacity(0.3), width: 1),
              ),
              child: const Text('Contact Support',
                  style: TextStyle(
                      fontSize: 13,
                      color: _redText,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ]),
      ),
    );
  }
}

// =============================================================================
// INPUT COMPONENTS
// =============================================================================
class _SendButton extends StatelessWidget {
  final bool hasContent;
  final VoidCallback onSend;
  final VoidCallback onMic;
  const _SendButton(
      {required this.hasContent, required this.onSend, required this.onMic});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: hasContent ? onSend : onMic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [kPrimary, kPrimaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: kPrimary.withOpacity(0.35),
                blurRadius: 10,
                offset: const Offset(0, 3))
          ],
        ),
        child: Icon(
          hasContent ? Icons.send_rounded : Icons.mic_rounded,
          color: _white,
          size: 19,
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _chatBg,
          shape: BoxShape.circle,
          border: Border.all(color: _border, width: 1),
        ),
        child: Icon(icon, color: _slate, size: 20),
      ),
    );
  }
}

class _HeaderIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HeaderIconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
        ),
        child: Icon(icon, color: _white, size: 18),
      ),
    );
  }
}

class _ReplyBanner extends StatelessWidget {
  final String sender, text;
  final VoidCallback onCancel;
  const _ReplyBanner(
      {required this.sender, required this.text, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _replyAccent.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: const Border(left: BorderSide(color: _replyAccent, width: 3)),
      ),
      child: Row(children: [
        const Icon(Icons.reply_rounded, color: _replyAccent, size: 16),
        const SizedBox(width: 8),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(sender,
                style: const TextStyle(
                    fontSize: 11,
                    color: _replyAccent,
                    fontWeight: FontWeight.w600)),
            Text(text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: _slate)),
          ],
        )),
        GestureDetector(
          onTap: onCancel,
          child: Icon(Icons.close_rounded,
              size: 16, color: _slate.withOpacity(0.6)),
        ),
      ]),
    );
  }
}

class _ImagePreviewStrip extends StatelessWidget {
  final List images;
  final void Function(int) onRemove;
  const _ImagePreviewStrip({required this.images, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(bottom: 8),
        itemCount: images.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => Stack(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(File(images[i].path),
                width: 70, height: 70, fit: BoxFit.cover),
          ),
          Positioned(
            top: 2,
            right: 2,
            child: GestureDetector(
              onTap: () => onRemove(i),
              child: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                    color: _redText, shape: BoxShape.circle),
                child: const Icon(Icons.close, color: _white, size: 11),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _PaymentButton extends StatelessWidget {
  final bool isLoading;
  final AppointmentModel appointment;
  final UserService userService;
  final UserController userController;
  final PaymentController paymentController;
  final BookingController bookingController;
  const _PaymentButton({
    required this.isLoading,
    required this.appointment,
    required this.userService,
    required this.userController,
    required this.paymentController,
    required this.bookingController,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: Loader());
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) => _PaymentSheet(
          appointment: appointment,
          userService: userService,
          userController: userController,
          paymentController: paymentController,
          bookingController: bookingController,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [kPrimary, kPrimaryDark]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: kPrimary.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_open_rounded, color: _white, size: 18),
            SizedBox(width: 10),
            Text('Complete Payment to Chat',
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700, color: _white)),
          ],
        ),
      ),
    );
  }
}

class _PaymentSheet extends StatelessWidget {
  final AppointmentModel appointment;
  final UserService userService;
  final UserController userController;
  final PaymentController paymentController;
  final BookingController bookingController;
  const _PaymentSheet({
    required this.appointment,
    required this.userService,
    required this.userController,
    required this.paymentController,
    required this.bookingController,
  });

  Future<void> _pay(BuildContext ctx, bool isPaystack) async {
    try {
      bookingController.isLoading.value = true;
      final info =
          await userService.getProfileById(userId: userController.userId.value);
      if (isPaystack) {
        await paymentController.makePaystackPayment(
          email: info.email.validate(),
          context: ctx,
          amount: appointment.price.validate(),
          paymentFor: 'Appointment',
          productId: appointment.id,
        );
      } else {
        await paymentController.makeFlutterwavePayment(
          email: info.email.validate(),
          context: ctx,
          amount: appointment.price.validate(),
          paymentFor: 'Appointment',
          productId: appointment.id,
        );
      }
    } finally {
      bookingController.isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: _border, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 20),
        const Text('Choose Payment Method',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w800, color: _ink)),
        const SizedBox(height: 20),
        _PayOption(
            label: 'Paystack',
            color: const Color(0xFF00C3F7),
            onTap: () => _pay(context, true)),
        const SizedBox(height: 12),
        _PayOption(
            label: 'Flutterwave',
            color: const Color(0xFFF5A623),
            onTap: () => _pay(context, false)),
        SizedBox(height: MediaQuery.of(context).padding.bottom + 12),
      ]),
    );
  }
}

class _PayOption extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _PayOption(
      {required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(children: [
          Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Text(label,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600, color: _ink)),
          const Spacer(),
          Icon(Icons.arrow_forward_ios_rounded,
              size: 13, color: _slate.withOpacity(0.4)),
        ]),
      ),
    );
  }
}

class _PrescriptionBar extends StatelessWidget {
  final AppointmentModel appointment;
  const _PrescriptionBar({required this.appointment});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => PrescriptionScreen(appointment: appointment).launch(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F7FF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kPrimary.withOpacity(0.2)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.description_outlined, color: kPrimary, size: 18),
          const SizedBox(width: 10),
          Text('View Prescription',
              style: TextStyle(
                  fontSize: 14, color: kPrimary, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

// =============================================================================
// BOTTOM SHEETS
// =============================================================================
class _OptionsSheet extends StatelessWidget {
  final VoidCallback onEdit, onDelete;
  const _OptionsSheet({required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
                color: _border, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 16),
        _SheetOption(
            icon: Icons.edit_outlined, label: 'Edit Message', onTap: onEdit),
        const SizedBox(height: 8),
        _SheetOption(
            icon: Icons.delete_outline_rounded,
            label: 'Delete Message',
            onTap: onDelete,
            destructive: true),
        SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
      ]),
    );
  }
}

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;
  const _SheetOption(
      {required this.icon,
      required this.label,
      required this.onTap,
      this.destructive = false});

  @override
  Widget build(BuildContext context) {
    final color = destructive ? _redText : _ink;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: destructive ? _redSoft : const Color(0xFFF8FAFF),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(label,
              style: TextStyle(
                  fontSize: 14, color: color, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

class _AttachmentSheet extends StatelessWidget {
  final VoidCallback onDocuments, onGallery, onCamera;
  const _AttachmentSheet(
      {required this.onDocuments,
      required this.onGallery,
      required this.onCamera});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
                color: _border, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 20),
        const Text('Share Something',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w800, color: _ink)),
        const SizedBox(height: 20),
        Row(children: [
          _AttachOption(
              icon: Icons.insert_drive_file_outlined,
              label: 'Documents',
              color: kPrimary,
              onTap: onDocuments),
          const SizedBox(width: 12),
          _AttachOption(
              icon: Icons.photo_library_outlined,
              label: 'Gallery',
              color: _green,
              onTap: onGallery),
          const SizedBox(width: 12),
          _AttachOption(
              icon: Icons.camera_alt_outlined,
              label: 'Camera',
              color: const Color(0xFF8B5CF6),
              onTap: onCamera),
        ]),
        SizedBox(height: MediaQuery.of(context).padding.bottom + 12),
      ]),
    );
  }
}

class _AttachOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _AttachOption(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.07),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                    fontSize: 11, color: color, fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
    );
  }
}

class _EditDialog extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSave;
  const _EditDialog({required this.controller, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: _white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Edit Message',
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w800, color: _ink)),
      content: TextField(
        controller: controller,
        minLines: 1,
        maxLines: 5,
        style: const TextStyle(fontSize: 14, color: _ink),
        decoration: InputDecoration(
          hintText: 'Edit your message...',
          hintStyle: TextStyle(color: _slate.withOpacity(0.6)),
          filled: true,
          fillColor: _chatBg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(12),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child:
              Text('Cancel', style: TextStyle(color: _slate.withOpacity(0.7))),
        ),
        GestureDetector(
          onTap: onSave,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [kPrimary, kPrimaryDark]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text('Save',
                style: TextStyle(color: _white, fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}

// =============================================================================
// DOT GRID BACKGROUND PAINTER
// =============================================================================
class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFF94A3B8).withOpacity(0.10)
      ..style = PaintingStyle.fill;
    const sp = 28.0;
    for (double x = sp / 2; x < size.width; x += sp) {
      for (double y = sp / 2; y < size.height; y += sp) {
        canvas.drawCircle(Offset(x, y), 1.2, p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}
