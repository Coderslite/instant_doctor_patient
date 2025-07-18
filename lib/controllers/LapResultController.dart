import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instant_doctor/component/snackBar.dart';
import 'package:instant_doctor/controllers/UploadFileController.dart';
import 'package:instant_doctor/services/WalletService.dart';
import 'package:nb_utils/nb_utils.dart';

import '../screens/home/Root.dart';
import '../services/LabResultService.dart';

class LabResultController extends GetxController {
  UploadFileController uploadFileController = Get.put(UploadFileController());
  RxBool isUpload = false.obs;
  var files = [].obs;
  RxBool emailCopy = false.obs;
  final walletService = Get.find<WalletService>();
  final labResultService = Get.find<LabResultService>();

  handlePickFile(String type) async {
    if (type == 'Image') {
      var result = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (result != null) {
        File file = File(result.path);
        files.add({
          "file": file,
          "fileType": type,
        });
      } else {
        toast("no file was selected");
      }
    } else {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions:
            type == 'Image' ? ['png', 'jpeg', 'jpg'] : ['pdf', 'doc'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        files.add({
          "file": file,
          "fileType": type,
        });
      } else {
        toast("no file was selected");
      }
    }
  }

  handleRemoveFile(int index) {
    files.removeAt(index);
  }

  // handleRemoveFileByFileName(File file) {
  //   files.remove(file);
  // }

  handleUploadFiles(
    BuildContext context,
  ) async {
    try {
      if (files.isEmpty) {
        errorSnackBar(title: "No file has been selected");
        return;
      }
      isUpload.value = true;
      List uploadedFiles = [];
      for (int i = files.length - 1; i >= 0; i--) {
        // Iterate in reverse order
        var fileUrl =
            await uploadFileController.uploadFileLabResult(files[i]['file']);
        uploadedFiles.add({
          "fileUrl": fileUrl,
          "fileType": files[i]['fileType'],
        });
        handleRemoveFile(i);
      }
      labResultService.uploadToResult(files: uploadedFiles);
      // handleRemoveFileByFileName(files[i]);
      toast("one lab result uploaded");
      toast("Upload completed");
      const Root().launch(context);
    } catch (err) {
      toast(err.toString());
    } finally {
      isUpload.value = false;
    }
  }
}
