import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/screens/drug/ChangePickup.dart';
import 'package:nb_utils/nb_utils.dart';

class LocationController extends GetxController {
  var latitude = 0.0.obs;
  var longitude = 0.0.obs;
  var address = ''.obs;

  Rx<CameraPosition> cameraPosition = const CameraPosition(
    target: LatLng(0, 0),
    zoom: 18,
  ).obs;
  // Request permission and get the current position
  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    // Check permission status
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // If permissions are granted, get the current location
    return await Geolocator.getCurrentPosition();
  }

  // Get and update location
  Future<void> handleGetMyLocation() async {
    try {
      Position position = await determinePosition();
      latitude.value = position.latitude;
      longitude.value = position.longitude;
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
              "please kindly update your locatiom to proceed",
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
    } else {}
  }


  
}
