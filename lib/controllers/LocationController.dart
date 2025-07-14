import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/screens/drug/ChangePickup.dart';
import 'package:location/location.dart';
import 'package:nb_utils/nb_utils.dart';

class LocationController extends GetxController {
  var latitude = 0.0.obs;
  var longitude = 0.0.obs;
  var address = ''.obs;
  final Location _location = Location();

  Rx<CameraPosition> cameraPosition = const CameraPosition(
    target: LatLng(0, 0),
    zoom: 18,
  ).obs;

  // Request permission and get the current position
  Future<bool> _checkAndRequestPermission() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        return false;
      }
    }

    PermissionStatus permissionStatus = await _location.hasPermission();
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await _location.requestPermission();
      if (permissionStatus != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  // Get and update location
  Future<void> handleGetMyLocation() async {
    try {
      bool hasPermission = await _checkAndRequestPermission();
      if (!hasPermission) {
        throw Exception('Location permissions are denied');
      }

      LocationData locationData = await _location.getLocation();
      latitude.value = locationData.latitude ?? 0.0;
      longitude.value = locationData.longitude ?? 0.0;
      cameraPosition.value = CameraPosition(
          target: LatLng(latitude.value, longitude.value), zoom: 14);
    } catch (e) {
      print("Failed to get location: $e");
    }
  }

  handleCheckLocation() async {
    if (address.isEmpty) {
      await Future.delayed(Duration(seconds: 2));
      showInDialog(
        Get.context!,
        barrierDismissible: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Location update request",
              style: boldTextStyle(
                size: 18,
              ),
            ),
            10.height,
            Text(
              "please kindly update your location to proceed",
              textAlign: TextAlign.center,
              style: primaryTextStyle(size: 14),
            ),
            20.height,
            AppButton(
              onTap: () {
                Navigator.pop(Get.context!);
                ChangePickup().launch(Get.context!);
              },
              text: "Update Location",
              textColor: white,
              color: kPrimary,
            )
          ],
        ),
      );
    }
  }
}
