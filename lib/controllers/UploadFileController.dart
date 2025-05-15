import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/services/GetUserId.dart';


class UploadFileController extends GetxController {
  RxDouble progress = 0.0.obs;

  Future<String> uploadProfileImage(File file) async {
    final Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('${userController.userId.value}/profile_image/${file.path}');
    final UploadTask uploadTask = storageReference.putFile(file);

    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      progress.value = snapshot.bytesTransferred / snapshot.totalBytes;
    });
    await uploadTask.whenComplete(() => {});
    String downloadUrl = await storageReference.getDownloadURL();
    return downloadUrl;
  }

  Future<String> uploadFileLabResult(File file) async {
    final Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('${userController.userId.value}/lab_result/${file.path}');
    final UploadTask uploadTask = storageReference.putFile(file);

    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      progress.value = snapshot.bytesTransferred / snapshot.totalBytes;
    });
    await uploadTask.whenComplete(() => {});
    String downloadUrl = await storageReference.getDownloadURL();
    return downloadUrl;
  }
}


