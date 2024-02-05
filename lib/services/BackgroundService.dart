// import 'dart:io';

// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// import '../main.dart';

// class BackgroundService {
//   Future<void> initializeService() async {
//     final service = FlutterBackgroundService();

//     await service.configure(
//       androidConfiguration: AndroidConfiguration(
//         // this will be executed when app is in foreground or background in separated isolate
//         onStart: onStart,

//         // auto start service
//         autoStart: true,
//         isForegroundMode: true,

//         notificationChannelId: 'com.instantdoctor',
//         initialNotificationTitle: 'AWESOME SERVICE',
//         initialNotificationContent: 'Initializing',
//         foregroundServiceNotificationId: 0,
//       ),
//       iosConfiguration: IosConfiguration(
//         // auto start service
//         autoStart: true,

//         // this will be executed when app is in foreground in separated isolate
//         onForeground: onStart,

//         // you have to enable background fetch capability on xcode project
//         onBackground: onIosBackground,
//       ),
//     );
//   }
// }
