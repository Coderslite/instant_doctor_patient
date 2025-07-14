// import 'dart:async';
// import 'dart:io';

// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:instant_doctor/component/snackBar.dart';

// class ConnectivityController extends GetxController {
//   final Connectivity _connectivity = Connectivity();

//   var isConnected = false.obs;

//   late StreamSubscription<ConnectivityResult> connectivitySubscription;

//   @override
//   void onInit() {
//     super.onInit();
//     initConnectivity();
//     connectivitySubscription =
//         _connectivity.onConnectivityChanged.listen(_handleConnectivityChange);
//   }

//   @override
//   void onClose() {
//     connectivitySubscription.cancel();
//     super.onClose();
//   }

//   Future<void> initConnectivity() async {
//     try {
//       final result = await _connectivity.checkConnectivity();
//       await _handleConnectivityChange(result);
//     } on PlatformException catch (e) {
//       print('⚠️ Failed to check connectivity: $e');
//     }
//   }

//   Future<void> _handleConnectivityChange(ConnectivityResult result) async {
//     bool hasInternet = false;

//     if (result != ConnectivityResult.none) {
//       hasInternet = await _checkInternetAccess();
//     }

//     isConnected.value = hasInternet;

//     if (hasInternet) {
//       print("✅ Internet connection is ON");
//       successSnackBar(title: "Internet Connection ON");
//     } else {
//       print("❌ Internet connection is OFF");
//       errorSnackBarWithClose(title: "Internet Connection is OFF");
//     }
//   }

//   Future<bool> _checkInternetAccess() async {
//     try {
//       final result = await InternetAddress.lookup('example.com');
//       return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
//     } on SocketException {
//       return false;
//     }
//   }
// }