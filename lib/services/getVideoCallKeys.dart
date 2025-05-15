// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/ZegoCloudModel.dart';

Future<ZegocloudModel> getVideoCallKeys() async {
  var result = await FirebaseFirestore.instance
      .collection("ZegoCloud")
      .where('inUse', isEqualTo: true)
      .get();
  var res = result.docs.first.data();
  return ZegocloudModel.fromJson(res);
}
