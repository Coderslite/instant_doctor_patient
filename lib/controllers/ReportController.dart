import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../constant/constants.dart';
import '../services/ReportService.dart';
import 'UserController.dart';

class ReportController extends GetxController {
  final reportService = Get.find<ReportService>();

  var messageController = TextEditingController();
  List files = [].obs;
  List images = [].obs;
  final ImagePicker picker = ImagePicker();
  var isLoading = false.obs;

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
    required String reportId,
  }) async {
    final userController = Get.find<UserController>();

    try {
      isLoading.value = msgType.value == '' ||
              msgType.value == MessageType.text ||
              (files.isEmpty && images.isEmpty)
          ? false
          : true;
      var senderId = userController.userId.value;
      var msgId = await reportService.handleSendMessage(
          reportId: reportId,
          senderId: senderId,
          files: msgType.value == MessageType.file
              ? files
              : msgType.value == MessageType.image
                  ? images
                  : [],
          message: messageController.text,
          type: files.isEmpty && images.isEmpty
              ? MessageType.text
              : msgType.value);
      isLoading.value = false;

      // sendNotification([token], "New Message", "${messageController.text}",
      //     msgId, NotificatonType.chat);
      messageController.clear();
    } finally {
      isLoading.value = false;
    }
  }
}
