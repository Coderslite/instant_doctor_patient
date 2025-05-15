import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../constant/constants.dart';
import '../function/send_notification.dart';
import '../services/AppointmentService.dart';
import 'UserController.dart';

class ChatController extends GetxController {
  List files = [].obs;
  List images = [].obs;
  final ImagePicker picker = ImagePicker();
  var isLoading = false.obs;

  RxList message = [].obs;
  File? audioFile;

  var msgType = MessageType.text.obs;

  handleGetDoc() async {
    images = [];
    var result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: true,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      msgType.value = MessageType.file;
      for (var element in result.files) {
        files.add(File(element.path.toString()));
      }
    } else {}
  }

  handleRemoveDoc(int index) {
    files.removeAt(index);
  }

  handleGetCamera() async {
    files = [];
    var result = await picker.pickImage(source: ImageSource.camera);
    if (result != null) {
      msgType.value = MessageType.image;
      images.add(File(result.path));
    }
  }

  handleGetGallery() async {
    files = [];

    var result = await picker.pickImage(source: ImageSource.gallery);
    if (result != null) {
      msgType.value = MessageType.image;

      images.add(File(result.path));
    }
  }

  handleRemoveImage(index) {
    images.removeAt(index);
  }

  handleSendMessage({
    required String docId,
    required String appointmentId,
    required String token,
    required String message,
    required String myName,
  }) async {
    try {
      var userController = Get.find<UserController>();
      final appointmentService = Get.find<AppointmentService>();
      
      isLoading.value = msgType.value == '' ||
              msgType.value == MessageType.text ||
              (files.isEmpty && images.isEmpty)
          ? false
          : true;
      var senderId = userController.userId.value;
      var receiverId = docId;
      var msgId = await appointmentService.handleSendMessage(
          appointmentId: appointmentId,
          senderId: senderId,
          receiverId: receiverId,
          files: msgType.value == MessageType.file
              ? files
              : msgType.value == MessageType.image
                  ? images
                  : [],
          message: message,
          type: files.isEmpty && images.isEmpty
              ? MessageType.text
              : msgType.value);
      isLoading.value = false;
      sendNotification(
        [token],
        myName,
        msgType.value == MessageType.text ? message : "Sent a file",
        msgId,
        "Chat",
      );
    } finally {
      isLoading.value = false;
    }
  }
}
