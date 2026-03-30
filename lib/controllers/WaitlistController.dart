import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/component/snackBar.dart';
import 'package:instant_doctor/models/WaillistModel.dart';
import 'package:instant_doctor/services/GetUserId.dart';

import '../services/WaitlistService.dart';

class WaitlistController extends GetxController {
  var isLoading = false.obs;

  newWaitlist(BuildContext context) async {
    var data = WaitlistModel(
      userId: userController.userId.value,
      address: locationController.address.value,
      location: GeoPoint(locationController.latitude.value,
          locationController.longitude.value),
      createdAt: Timestamp.now(),
    );
    try {
      isLoading.value = true;
      await WaitlistService().newWaitlist(data);
      successSnackBar(context: context, title: "Added Waitlist");
    } catch (err) {
      print(err);
      errorSnackBar(context: context, title: "Something went wrong");
    } finally {
      isLoading.value = false;
    }
  }
}
