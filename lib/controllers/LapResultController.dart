import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

class LapResultController extends GetxController {
  List files = [].obs;
  RxBool emailCopy = false.obs;
  handlePickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
      files.add(file);
    } else {
      toast("no file was selected");
    }
  }

  handleRemoveFile(int index) {
    files.removeAt(index);
  }
}
