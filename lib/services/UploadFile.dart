import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

Future<String> uploadFile(File file, String appointmentId) async {
  FirebaseStorage storage = FirebaseStorage.instance;
  Reference storageReference = storage
      .ref('/uploads/')
      .child(appointmentId + DateTime.now().millisecond.toString());
  UploadTask uploadTask = storageReference.putFile(file);
  await uploadTask.whenComplete(() => {});
  String downloadUrl = await storageReference.getDownloadURL();
  return downloadUrl;
}


Future<String> uploadReportFile(File file, String reportId) async {
  FirebaseStorage storage = FirebaseStorage.instance;
  Reference storageReference = storage
      .ref('/reports/')
      .child(reportId + DateTime.now().millisecond.toString());
  UploadTask uploadTask = storageReference.putFile(file);
  await uploadTask.whenComplete(() => {});
  String downloadUrl = await storageReference.getDownloadURL();
  return downloadUrl;
}
