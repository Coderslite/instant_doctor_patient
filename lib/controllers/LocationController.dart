import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/screens/drug/ChangePickup.dart';
import 'package:instant_doctor/services/GetUserId.dart';
import 'package:location/location.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import '../constant/constants.dart';
import '../services/LocationService.dart';

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
  Future<void> handleGetMyLocation(
      {required bool isLogin, required String? email}) async {
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
      await handleSaveAddress();
      if (isLogin) {
        await notifyLogin(
            email: email.validate(),
            location:
                "$address -- (latitude: ${longitude.value}, longitude: ${latitude.value})");
      }
    } catch (e) {
      print("Failed to get location: $e");
    }
  }

  handleSaveAddress() async {
    await updateAddress(
      LatLng(latitude.value, longitude.value),
    );
    if (address.value.isNotEmpty) {
      userService.updateProfile(data: {
        "address": address.value,
        "location": GeoPoint(latitude.value, longitude.value)
      }, userId: userController.userId.value);
    }
  }

  Future<void> updateAddress(LatLng position) async {
    final LocationService locationService = LocationService();
    try {
      // First try with Google's reverse geocoding
      final url = 'https://maps.googleapis.com/maps/api/geocode/json?'
          'latlng=${position.latitude},${position.longitude}'
          '&key=${LocationService.apiKey}';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'].isNotEmpty) {
          final components = data['results'][0]['address_components'];
          address.value = locationService.parseAddressComponents(components);
          return;
        }
      }
    } catch (e) {
      toast('Could not get address details');
    } finally {}
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

  Future<void> notifyLogin(
      {required String email, required String location}) async {
    var deviceId = await handleGetDeviceInfo();
    await http.post(
      Uri.parse("$FIREBASE_URL/mail/login_notify"),
      body: {
        "email": email,
        "deviceId": deviceId,
        "location": location,
      },
    );
  }

  Future<String> handleGetDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return "${androidInfo.brand} ${androidInfo.model}";
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      print('Running on ${iosInfo.utsname.machine}'); // e.g. "iPod7,1"
      return iosInfo.utsname.machine;
    }
    return 'NULL';
  }
}
