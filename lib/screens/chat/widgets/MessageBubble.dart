import 'package:flutter/material.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/constant/constants.dart';
import 'package:instant_doctor/models/AppointmentModel.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:intl/intl.dart';
import 'package:instant_doctor/services/SecurityHelper.dart';
import 'package:instant_doctor/screens/chat/ImagePreview.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_bubbles/chat_bubbles.dart';

class MessageBubble extends StatelessWidget {
  final AppointmentConversationModel message;
  final bool isMine;
  final String senderName;
  final Function(String) onReplyTap;
  final String userControllerUserId;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMine,
    required this.senderName,
    required this.onReplyTap,
    required this.userControllerUserId,
  });

  @override
  Widget build(BuildContext context) {
    const obsidian = Color(0xFF0A1628);
    const slate = Color(0xFF5E7A99);
    const replyAccent = Color(0xFF3B82F6);

    final String decryptedMsg = SecurityHelper().decryptText(message.message.validate());
    final DateTime time = message.createdAt?.toDate() ?? DateTime.now();
    final String timeStr = DateFormat('hh:mm a').format(time);

    return Column(
      crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (message.repliedTo != null && message.repliedTo!.isNotEmpty)
          Transform.translate(
            offset: const Offset(0, 8),
            child: _buildReplyPreview(message, isMine, onReplyTap, replyAccent),
          ),
        
        if (message.type == MessageType.image)
          _buildImageMessage(message, isMine, decryptedMsg, context)
        else if (message.type == MessageType.voice)
          _buildVoiceMessage(message, isMine)
        else if (message.type == MessageType.file)
          _buildFileMessage(message, isMine, decryptedMsg)
        else
          _buildTextMessage(message, isMine, decryptedMsg, obsidian),

        Padding(
          padding: EdgeInsets.only(left: isMine ? 0 : 12, right: isMine ? 12 : 0, top: 4, bottom: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isMine) ...[
                Icon(
                  message.status == MessageStatus.read ? Icons.done_all_rounded : Icons.done_rounded,
                  size: 14,
                  color: message.status == MessageStatus.read ? kPrimary : slate.withOpacity(0.5),
                ),
                const SizedBox(width: 4),
              ],
              Text(
                timeStr,
                style: TextStyle(fontSize: 10, color: slate.withOpacity(0.5), fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReplyPreview(AppointmentConversationModel msg, bool isMine, Function(String) onTap, Color accent) {
    return GestureDetector(
      onTap: () => onTap(msg.repliedTo!),
      child: Container(
        margin: EdgeInsets.only(
          left: isMine ? 50 : 12,
          right: isMine ? 12 : 50,
          bottom: 0,
        ),
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
          border: Border.all(color: const Color(0xFFE5EAF4), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 3,
              height: 24,
              decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Replying to',
                    style: TextStyle(fontSize: 10, color: accent, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    msg.repliedText.validate(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF5E7A99)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextMessage(AppointmentConversationModel msg, bool isMine, String text, Color obsidian) {
    return BubbleSpecialThree(
      text: text,
      color: isMine ? kPrimary : Colors.white,
      tail: true,
      textStyle: TextStyle(
        color: isMine ? Colors.white : obsidian,
        fontSize: 14,
        height: 1.4,
        fontWeight: FontWeight.w500,
      ),
      isSender: isMine,
    );
  }

  Widget _buildImageMessage(AppointmentConversationModel msg, bool isMine, String caption, BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: isMine ? 50 : 12, right: isMine ? 12 : 50),
      decoration: BoxDecoration(
        color: isMine ? kPrimary : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => ImagePreview(imageUrl: msg.fileUrl.validate()).launch(context),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: msg.fileUrl.validate(),
                placeholder: (_, __) => const SizedBox(width: 200, height: 200, child: Center(child: CircularProgressIndicator())),
                fit: BoxFit.cover,
              ),
            ),
          ),
          if (caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                caption,
                style: TextStyle(color: isMine ? Colors.white : const Color(0xFF0F2744), fontSize: 14),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVoiceMessage(AppointmentConversationModel msg, bool isMine) {
    return BubbleNormalAudio(
      color: isMine ? kPrimary : Colors.white,
      duration: 0, // Placeholder
      position: 0, // Placeholder
      isPlaying: false,
      isLoading: false,
      isPause: false,
      onPlayPauseButtonClick: () {},
      onSeekChanged: (_) {},
      isSender: isMine,
      sent: true,
      seen: message.status == MessageStatus.read,
    );
  }

  Widget _buildFileMessage(AppointmentConversationModel msg, bool isMine, String name) {
    return BubbleSpecialThree(
      text: '📄 $name',
      color: isMine ? kPrimary : Colors.white,
      isSender: isMine,
      textStyle: TextStyle(color: isMine ? Colors.white : const Color(0xFF0F2744), fontWeight: FontWeight.bold),
    );
  }
}

class DeletedBubble extends StatelessWidget {
  final bool isMine;
  const DeletedBubble({super.key, required this.isMine});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F4FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5EAF4), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.block_flipped, size: 14, color: Color(0xFF94A3B8)),
            const SizedBox(width: 8),
            Text(
              'This message was deleted',
              style: TextStyle(fontSize: 12, color: const Color(0xFF94A3B8), fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
