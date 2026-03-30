import 'package:flutter/material.dart';
import 'package:instant_doctor/component/snackBar.dart';
import 'package:location/location.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:permission_handler/permission_handler.dart'
    hide PermissionStatus;

import '../constant/color.dart';
import '../services/GetUserId.dart';

handleShowRequestLocation(BuildContext context) async {
  final Location location = Location();
  bool serviceEnabled = await location.serviceEnabled();
  PermissionStatus permissionGranted = await location.hasPermission();

  if (permissionGranted == PermissionStatus.denied ||
      permissionGranted == PermissionStatus.deniedForever ||
      serviceEnabled == false) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      isDismissible: true,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => true,
          child: AnimatedPadding(
            padding: MediaQuery.of(context).viewInsets,
            duration: const Duration(milliseconds: 100),
            curve: Curves.decelerate,
            child: Container(
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          kPrimary.withOpacity(0.2),
                          kPrimary.withOpacity(0.4),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Icon(
                      Icons.location_on_outlined,
                      size: 60,
                      color: kPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      "Location Access Needed",
                      textAlign: TextAlign.center,
                      style: boldTextStyle(size: 22, height: 1.3),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      "To provide you with the best service experience, we need access to your location. Your data is always secure.",
                      textAlign: TextAlign.center,
                      style: secondaryTextStyle(size: 15, height: 1.4),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        gradient: const LinearGradient(
                          colors: [kPrimary, kPrimaryDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: kPrimary.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(15),
                          onTap: () async {
                            // 1. Check if location service is enabled

                            if (!serviceEnabled) {
                              serviceEnabled = await location.requestService();
                              if (!serviceEnabled) {
                                // Show dialog to enable location services
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text(
                                        "Location Services Disabled"),
                                    content: const Text(
                                      "Please enable location services in your device settings.",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("OK"),
                                      ),
                                    ],
                                  ),
                                );
                                return;
                              }
                            }

                            // 2. Check permission status
                            permissionGranted = await location.hasPermission();
                            if (permissionGranted == PermissionStatus.denied) {
                              permissionGranted =
                                  await location.requestPermission();
                            }

                            // 3. Handle different permission states
                            if (permissionGranted == PermissionStatus.granted ||
                                permissionGranted ==
                                    PermissionStatus.grantedLimited) {
                              // Success - get location
                              locationController.handleGetMyLocation(
                                isLogin: false,
                                email: '',
                              );
                              Navigator.pop(context);
                            } else if (permissionGranted ==
                                PermissionStatus.deniedForever) {
                              // Permanently denied - show dialog to open app settings
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text(
                                      "Location Permission Required"),
                                  content: const Text(
                                    "You've permanently denied location permissions. "
                                    "Please enable them in app settings to continue.",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        openAppSettings(); // From permission_handler package
                                      },
                                      child: const Text("Open Settings"),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              errorSnackBar(
                                  context: context,
                                  title: "Location permission denied");
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 24,
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "Continue",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  } else {
    await locationController.handleGetMyLocation(isLogin: false, email: '');
  }
}
