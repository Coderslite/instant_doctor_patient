// main.dart
import 'dart:async';

import 'package:app_links/app_links.dart';
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
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  // ✅ Initialize Firebase safely
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 10));
    print('🔥 Firebase initialized successfully');
  } catch (e) {
    print('❌ Firebase initialization failed: $e');
  }

  // Run the Flutter app first
  runApp(MyApp(navigatorKey: navigatorKey));

  // ✅ Then perform platform-dependent setups after runApp()
  unawaited(_postRunInitialization());
}

Future<void> _postRunInitialization() async {
  try {
    // Initialize FCM handling
    await FirebaseMessagings().handleInit();

    // Initialize Zego calling service
    ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);
    ZegoUIKitPrebuiltCallInvitationService().useSystemCallingUI([
      ZegoUIKitSignalingPlugin(),
    ]);

    // Load local app settings
    await initialize();
    await initializeTheme();
    settingsController.handleGetVideoCallKeys();

    print('✅ Post-run initialization completed successfully');
  } catch (e) {
    print('⚠️ Post-run initialization error: $e');
  }
}

class MyApp extends StatefulWidget {
  final GlobalKey<NavigatorState>? navigatorKey;
  const MyApp({super.key, this.navigatorKey});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppLinks _appLinks;

  Future<void> init() async {
    settingsController.setTheme(
      settingsController.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
    );
  }

  @override
  void initState() {
    super.initState();
    init();
    _initAppLinks(); // Initialize deep link listener
  }

  Future<void> _initAppLinks() async {
    _appLinks = AppLinks();

    // When app is already running or in background
    _appLinks.uriLinkStream.listen((uri) {
      print('🔗 App link detected (foreground): $uri');
      _consumeLink(uri);
    });

    // When app is opened from a terminated state
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      print('🚀 App opened via link: $initialUri');
      _consumeLink(initialUri);
    }
  }

  void _consumeLink(Uri uri) {
    // 👇 Do nothing except log it — this tells iOS that the app handled it
    print('✅ Consumed link: $uri');
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
