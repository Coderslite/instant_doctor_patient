import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

CircleAvatar isOnline(bool isOnline) {
  return CircleAvatar(
    radius: 5,
    backgroundColor: isOnline ? mediumSeaGreen : Colors.grey,
  );
}