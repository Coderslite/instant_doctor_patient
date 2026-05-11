import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import '../constant/constants.dart';
import '../function/send_notification.dart';
import '../services/AppointmentService.dart';
import '../services/UserService.dart';
import 'UserController.dart';

class ChatController extends GetxController {
  RxList files = [].obs;
  RxList images = [].obs;
  final ImagePicker picker = ImagePicker();
  var isLoading = false.obs;

  RxList message = [].obs;
  File? audioFile;

  var msgType = MessageType.text.obs;

  void handlePickImage({required bool isCamera}) async {
    final XFile? result = await picker.pickImage(
      source: isCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 70,
    );
    if (result != null) {
      msgType.value = MessageType.image;
      images.add(File(result.path));
    }
  }

  void handlePickFile() async {
    var result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png'],
    );
    if (result != null) {
      msgType.value = MessageType.file;
      for (var element in result.files) {
        if (element.path != null) {
          files.add(File(element.path!));
        }
      }
    }
  }

  void handleRemoveImage(int index) {
    images.removeAt(index);
  }

  void handleRemoveFile(int index) {
    files.removeAt(index);
  }

  Future<void> handleSendChat({
    required String docId,
    required String appointmentId,
    required String message,
    String? repliedTo,
    String? repliedMessageText,
    String? repliedMessageSender,
    String type = MessageType.text,
  }) async {
    try {
      isLoading.value = true;
      final userController = Get.find<UserController>();
      final appointmentService = Get.find<AppointmentService>();
      final userService = Get.find<UserService>();

      final token = await userService.getUserToken(userId: docId);
      final myProfile = await userService.getProfileById(userId: userController.userId.value);
      final myName = '${myProfile.firstName.validate()} ${myProfile.lastName.validate()}';

      final msgId = await appointmentService.handleSendMessage(
        appointmentId: appointmentId,
        senderId: userController.userId.value,
        receiverId: docId,
        files: msgType.value == MessageType.file
            ? files
            : msgType.value == MessageType.image
                ? images
                : [],
        message: message,
        type: (files.isEmpty && images.isEmpty) ? MessageType.text : msgType.value,
        repliedTo: repliedTo,
        repliedText: repliedMessageText,
        repliedSender: repliedMessageSender,
      );

      if (token.isNotEmpty) {
        sendNotification(
          [token],
          myName,
          images.isNotEmpty ? "📷 Sent a photo" : files.isNotEmpty ? "📄 Sent a file" : message,
          msgId,
          NotificationType.chat,
        );
      }

      // Clear after success
      images.clear();
      files.clear();
      msgType.value = MessageType.text;
    } catch (e) {
      toast('Failed to send message: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Legacy support
  handleGetCamera() => handlePickImage(isCamera: true);
  handleGetGallery() => handlePickImage(isCamera: false);
}
