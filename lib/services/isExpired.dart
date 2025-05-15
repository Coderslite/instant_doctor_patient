// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';

bool isExpired(Timestamp timestamp) {
  Timestamp currentTime = Timestamp.now();
  return timestamp.seconds < currentTime.seconds;
}