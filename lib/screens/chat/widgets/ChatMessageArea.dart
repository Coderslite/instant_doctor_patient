import 'package:flutter/material.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/constant/constants.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:instant_doctor/services/AppointmentService.dart';
import 'package:instant_doctor/screens/chat/widgets/MessageBubble.dart';
import 'package:instant_doctor/screens/profile/help/Help.dart';
import 'package:instant_doctor/models/UserModel.dart';
import 'package:instant_doctor/models/AppointmentModel.dart';

class ChatMessageArea extends StatelessWidget {
  final bool isExpired;
  final bool isYetToStart;
  final bool isLoading;
  final List<AppointmentConversationModel> messages;
  final ScrollController scrollController;
  final String appointmentId;
  final String docId;
  final String userId;
  final String userName;
  final UserModel? doctor;
  final AppointmentModel appointment;
  final AppointmentService appointmentService;
  final Map<String, GlobalKey> messageKeys;
  final String? highlightedMessageId;
  final Animation<Color?> highlightAnimation;
  final Function(AppointmentConversationModel, String) onReply;
  final Function(AppointmentConversationModel) onOptions;
  final Function(String) onReplyTap;

  const ChatMessageArea({
    super.key,
    required this.isExpired,
    required this.isYetToStart,
    required this.isLoading,
    required this.messages,
    required this.scrollController,
    required this.appointmentId,
    required this.docId,
    required this.userId,
    required this.userName,
    required this.doctor,
    required this.appointment,
    required this.appointmentService,
    required this.messageKeys,
    required this.onReply,
    required this.onOptions,
    required this.onReplyTap,
    required this.highlightAnimation,
    this.highlightedMessageId,
  });

  @override
  Widget build(BuildContext context) {
    if (!appointment.isPaid.validate() && !isExpired) {
      return _UnpaidState(onHelp: () => HelpScreen().launch(context));
    }
    if (isYetToStart) {
      return const _StatusState(
        icon: Icons.schedule_rounded,
        label: 'Appointment not started yet',
        sub: 'Please wait for your scheduled time.',
      );
    }
    if (isLoading) {
      return Center(child: CircularProgressIndicator(color: kPrimary));
    }
    if (messages.isEmpty) {
      return const _StatusState(
        icon: Icons.chat_bubble_outline_rounded,
        label: 'No messages yet',
        sub: 'Start the conversation below.',
      );
    }

    return Stack(children: [
      Positioned.fill(child: CustomPaint(painter: _DotGridPainter())),
      ListView.builder(
        controller: scrollController,
        reverse: true,
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        itemCount: messages.length,
        itemBuilder: (_, i) {
          final idx = messages.length - 1 - i;
          final msg = messages[idx];
          messageKeys[msg.id.validate()] = GlobalKey();
          appointmentService.updateChatStatus(appointmentId: appointmentId, userId: docId);

          final isMine = msg.senderId == userId;
          final senderName = isMine ? userName : '${doctor?.firstName} ${doctor?.lastName}';

          return Container(
            key: messageKeys[msg.id],
            color: highlightedMessageId == msg.id ? highlightAnimation.value : null,
            child: msg.status == MessageStatus.deleted
                ? DeletedBubble(isMine: isMine)
                : SwipeTo(
                    key: UniqueKey(),
                    onRightSwipe: (_) => onReply(msg, senderName),
                    child: GestureDetector(
                      onLongPress: () => onOptions(msg),
                      child: MessageBubble(
                        message: msg,
                        isMine: isMine,
                        senderName: senderName,
                        onReplyTap: onReplyTap,
                        userControllerUserId: userId,
                      ),
                    ),
                  ),
          );
        },
      ),
    ]);
  }
}

class _StatusState extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  const _StatusState({required this.icon, required this.label, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 64, color: const Color(0xFFE5EAF4)),
        const SizedBox(height: 16),
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F2744))),
        const SizedBox(height: 8),
        Text(sub, style: const TextStyle(fontSize: 13, color: Color(0xFF5E7A99))),
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
        padding: const EdgeInsets.all(40),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [
              BoxShadow(color: kPrimary.withOpacity(0.1), blurRadius: 40, spreadRadius: 10)
            ]),
            child: const Icon(Icons.lock_person_rounded, size: 50, color: kPrimary),
          ),
          const SizedBox(height: 32),
          const Text('Session Locked',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F2744))),
          const SizedBox(height: 12),
          const Text(
            'This session is currently locked. Complete your payment to start the conversation with your doctor.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color(0xFF5E7A99), height: 1.5),
          ),
          const SizedBox(height: 32),
          TextButton.icon(
            onPressed: onHelp,
            icon: const Icon(Icons.help_outline_rounded, size: 18),
            label: const Text('Need help?'),
            style: TextButton.styleFrom(foregroundColor: kPrimary),
          ),
        ]),
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF0F2744).withOpacity(0.03);
    for (double i = 0; i < size.width; i += 24) {
      for (double j = 0; j < size.height; j += 24) {
        canvas.drawCircle(Offset(i, j), 1.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
