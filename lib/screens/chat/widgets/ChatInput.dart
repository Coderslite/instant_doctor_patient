import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:instant_doctor/controllers/ChatController.dart';
import 'package:instant_doctor/controllers/UserController.dart';
import 'package:instant_doctor/controllers/BookingController.dart';
import 'package:instant_doctor/controllers/PaymentController.dart';
import 'package:instant_doctor/services/UserService.dart';
import 'package:instant_doctor/services/PricingService.dart';
import 'package:instant_doctor/models/AppointmentModel.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/screens/prescription/Prescription.dart';
import '../../../component/PremiumButton.dart';

class ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final GlobalKey<FormState> formKey;
  final bool isExpired;
  final bool isYetToStart;
  final bool isReplying;
  final String? repliedMessageSender;
  final String? repliedMessageText;
  final VoidCallback onCancelReply;
  final VoidCallback onSend;
  final VoidCallback onAttach;
  final AppointmentModel appointment;

  const ChatInput({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.formKey,
    required this.isExpired,
    required this.isYetToStart,
    required this.isReplying,
    required this.onCancelReply,
    required this.onSend,
    required this.onAttach,
    required this.appointment,
    this.repliedMessageSender,
    this.repliedMessageText,
  });

  @override
  Widget build(BuildContext context) {
    const chatBg = Color(0xFFF0F4FA);

    final chatController = Get.find<ChatController>();
    final bookingController = Get.find<BookingController>();
    final userService = Get.find<UserService>();
    final userController = Get.find<UserController>();
    final paymentController = Get.find<PaymentController>();

    final isOngoing =
        Get.find<PricingService>().isAppointmentOngoing(appointment);
    final isInputEnabled = !isExpired && !isYetToStart && isOngoing;

    return Obx(() => Container(
          decoration: const BoxDecoration(
            color: white,
            border: Border(top: BorderSide(color: border, width: 1)),
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
            if (chatController.images.isNotEmpty)
              _ImagePreviewStrip(
                images: chatController.images,
                onRemove: chatController.handleRemoveImage,
              ),
            if (isReplying)
              _ReplyBanner(
                sender: repliedMessageSender ?? '',
                text: repliedMessageText ?? '',
                onCancel: onCancelReply,
              ),
            if (!appointment.isPaid.validate() && !isExpired)
              _PaymentButton(
                isLoading: bookingController.isLoading.value,
                appointment: appointment,
                userService: userService,
                userController: userController,
                paymentController: paymentController,
                bookingController: bookingController,
              )
            else if (isExpired)
              _PrescriptionBar(appointment: appointment)
            else
              Form(
                key: formKey,
                child: Row(children: [
                  _IconBtn(
                    icon: Icons.attach_file_rounded,
                    onTap: isInputEnabled ? onAttach : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: chatBg,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: border, width: 1),
                      ),
                      child: AppTextField(
                        textFieldType: TextFieldType.MULTILINE,
                        controller: controller,
                        focus: focusNode,
                        minLines: 1,
                        maxLines: 4,
                        enabled: isInputEnabled,
                        decoration: InputDecoration(
                          hintText: isYetToStart
                              ? 'Waiting for appointment to start...'
                              : isExpired
                                  ? 'This session has ended'
                                  : !isOngoing
                                      ? 'Follow-up slot is not active yet'
                                      : 'Type a message...',
                          hintStyle: TextStyle(
                              fontSize: 13, color: slate.withOpacity(0.6)),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedScale(
                    scale: (isInputEnabled &&
                            (controller.text.isNotEmpty ||
                                chatController.images.isNotEmpty))
                        ? 1.0
                        : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: GestureDetector(
                      onTap: onSend,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                            color: kPrimary, shape: BoxShape.circle),
                        child: const Icon(Icons.send_rounded,
                            color: white, size: 20),
                      ),
                    ),
                  ),
                ]),
              ),
          ]),
        ));
  }
}

class _ImagePreviewStrip extends StatelessWidget {
  final List<dynamic> images;
  final Function(int) onRemove;
  const _ImagePreviewStrip({required this.images, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (_, i) => Stack(children: [
          Container(
            width: 70,
            height: 70,
            margin: const EdgeInsets.only(right: 10, top: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                  image: FileImage(images[i]), fit: BoxFit.cover),
              border: Border.all(color: const Color(0xFFE5EAF4), width: 1),
            ),
          ),
          Positioned(
            right: 2,
            top: 0,
            child: GestureDetector(
              onTap: () => onRemove(i),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                    color: Color(0xFFDC2626), shape: BoxShape.circle),
                child: const Icon(Icons.close, color: Colors.white, size: 12),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _ReplyBanner extends StatelessWidget {
  final String sender;
  final String text;
  final VoidCallback onCancel;
  const _ReplyBanner(
      {required this.sender, required this.text, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    const replyAccent = Color(0xFF3B82F6);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FA),
        borderRadius: BorderRadius.circular(12),
        border: const Border(left: BorderSide(color: replyAccent, width: 4)),
      ),
      child: Row(children: [
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Replying to $sender',
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: replyAccent)),
            const SizedBox(height: 2),
            Text(text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Color(0xFF5E7A99))),
          ]),
        ),
        GestureDetector(
          onTap: onCancel,
          child: const Icon(Icons.close_rounded,
              size: 18, color: Color(0xFF5E7A99)),
        ),
      ]),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _IconBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFF0F4FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5EAF4), width: 1),
        ),
        child: Icon(
          icon,
          color: onTap == null
              ? const Color(0xFF5E7A99).withOpacity(0.4)
              : const Color(0xFF0F2744),
          size: 20,
        ),
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
    return PremiumButton(
      onTap: () async {
        // final email = (await userService.getProfileById(userId: userController.userId.value)).email;
        // handleShowPaymentOption(context, appointment: appointment);
      },
      isLoading: isLoading,
      text: 'Complete Payment to Chat',
    );
  }
}

class _PrescriptionBar extends StatelessWidget {
  final AppointmentModel appointment;
  const _PrescriptionBar({required this.appointment});

  @override
  Widget build(BuildContext context) {
    return PremiumButton(
      onTap: () => PrescriptionScreen(appointment: appointment).launch(context),
      text: 'View Prescriptions & Notes',
    );
  }
}
