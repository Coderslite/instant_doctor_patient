// main.dart
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/controllers/FirebaseMessaging.dart';
import 'package:instant_doctor/firebase_options.dart';
import 'package:instant_doctor/screens/splash_screen/splash_screen.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

import 'AppTheme.dart';
import 'constant/color.dart';
import 'constant/constants.dart';
import 'services_initializer.dart';
import 'controllers/SettingController.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();


User? user = FirebaseAuth.instance.currentUser;
var db = FirebaseFirestore.instance;
var firebaseStorage = FirebaseStorage.instance;

SettingsController settingsController = Get.put(SettingsController());

    
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  var payload = message.data;

  if (payload['type'] == 'Call') {
    var appointmentId = payload['id'];
    var prefs = await SharedPreferences.getInstance();
    prefs.setString('AppointmentId', appointmentId);
    FirebaseMessagings().showIncomingCallNotification(message);
  } else {
    if (message.notification != null) {
      FirebaseMessagings().displayLocalNotification(message);
    }
  }
}

Future<void> initializeTheme() async {
  int themeModeIndex = getIntAsync(THEME_MODE_INDEX);
  settingsController.isDarkMode.value = themeModeIndex == ThemeModeDark;
  settingsController.setTheme(
    settingsController.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
  );
}


Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessagings().handleInit();

  ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);
  // await ZegoUIKit().initLog();
  ZegoUIKitPrebuiltCallInvitationService().useSystemCallingUI([
    ZegoUIKitSignalingPlugin(),
  ]);

  await initialize();
  await initializeTheme();
  settingsController.handleGetVideoCallKeys();
}

Future<void> main() async {
  tz.initializeTimeZones();
  await initializeApp();

  defaultToastBackgroundColor = Colors.black;
  defaultToastTextColor = Colors.white;
  defaultToastGravityGlobal = ToastGravity.CENTER;
  defaultRadius = 30;
  defaultAppButtonRadius = 30;
  defaultLoaderAccentColorGlobal = kPrimary;

  runApp(MyApp(navigatorKey: navigatorKey));
}

class MyApp extends StatefulWidget {
  final GlobalKey<NavigatorState>? navigatorKey;
  const MyApp({super.key, this.navigatorKey});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<void> init() async {
    settingsController.setTheme(
      settingsController.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
    );
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    setOrientationPortrait();
    return Obx(() => GetMaterialApp(
          title: 'Instant Doctor',
          initialBinding: InitialBindings(),
          debugShowCheckedModeBanner: false,
          navigatorKey: widget.navigatorKey,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settingsController.isDarkMode.value
              ? ThemeMode.dark
              : ThemeMode.light,
          home: const SplashScreen(),
          builder: scrollBehaviour(),
        ));
  }
}
