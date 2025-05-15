// ignore_for_file: file_names
// import 'dart:io';

// import 'package:flutter_foreground_task/flutter_foreground_task.dart';

// void initForegroundTask() {
//    _requestPermissionForAndroid();
//   FlutterForegroundTask.init(
//     androidNotificationOptions: AndroidNotificationOptions(
//       channelId: 'com.instantdoctor',
//       channelName: 'Foreground Service Notification',
//       channelDescription:
//           'This notification appears when the foreground service is running.',
//       channelImportance: NotificationChannelImportance.HIGH,
//       priority: NotificationPriority.HIGH,
//       iconData: const NotificationIconData(
//         resType: ResourceType.mipmap,
//         resPrefix: ResourcePrefix.ic,
//         name: 'launcher',
//       ),
//       buttons: [
//         const NotificationButton(id: 'sendButton', text: 'Send'),
//         const NotificationButton(id: 'testButton', text: 'Test'),
//       ],
//     ),
//     iosNotificationOptions: const IOSNotificationOptions(
//       showNotification: true,
//       playSound: false,
//     ),
//     foregroundTaskOptions: const ForegroundTaskOptions(
//       interval: 5000,
//       isOnceEvent: false,
//       autoRunOnBoot: true,
//       allowWakeLock: true,
//       allowWifiLock: true,
//     ),
//   );
// }

// Future<void> _requestPermissionForAndroid() async {
//   if (!Platform.isAndroid) {
//     return;
//   }

//   // "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted for
//   // onNotificationPressed function to be called.
//   //
//   // When the notification is pressed while permission is denied,
//   // the onNotificationPressed function is not called and the app opens.
//   //
//   // If you do not use the onNotificationPressed or launchApp function,
//   // you do not need to write this code.
//   if (!await FlutterForegroundTask.canDrawOverlays) {
//     // This function requires `android.permission.SYSTEM_ALERT_WINDOW` permission.
//     await FlutterForegroundTask.openSystemAlertWindowSettings();
//   }

//   // Android 12 or higher, there are restrictions on starting a foreground service.
//   //
//   // To restart the service on device reboot or unexpected problem, you need to allow below permission.
//   if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
//     // This function requires `android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` permission.
//     await FlutterForegroundTask.requestIgnoreBatteryOptimization();
//   }

//   // Android 13 and higher, you need to allow notification permission to expose foreground service notification.
//   final NotificationPermission notificationPermissionStatus =
//       await FlutterForegroundTask.checkNotificationPermission();
//   if (notificationPermissionStatus != NotificationPermission.granted) {
//     await FlutterForegroundTask.requestNotificationPermission();
//   }
// }
