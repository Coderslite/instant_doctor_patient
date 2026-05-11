import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, User;
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
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

/// ✅ Background handler
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

/// ✅ Theme init
Future<void> initializeTheme() async {
  int themeModeIndex = getIntAsync(THEME_MODE_INDEX);
  settingsController.isDarkMode.value = themeModeIndex == ThemeModeDark;

  settingsController.setTheme(
    settingsController.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  tz.initializeTimeZones();

  try {
    /// ✅ 1. Initialize Firebase FIRST
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    /// ✅ 2. Register background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    /// ✅ 3. Initialize messaging
    await FirebaseMessagings().handleInit();

    /// ✅ 4. Initialize Zego calling
    ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);
    ZegoUIKitPrebuiltCallInvitationService().useSystemCallingUI([
      ZegoUIKitSignalingPlugin(),
    ]);

    /// ✅ 5. Load local services
    await initialize();
    await initializeTheme();
    settingsController.handleGetVideoCallKeys();

    print('🔥 App fully initialized');
  } catch (e) {
    print('❌ Initialization error: $e');
  }

  /// ✅ 6. Run app AFTER everything is ready
  runApp(MyApp(navigatorKey: navigatorKey));
}

class MyApp extends StatefulWidget {
  final GlobalKey<NavigatorState>? navigatorKey;
  const MyApp({super.key, this.navigatorKey});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppLinks _appLinks;

  @override
  void initState() {
    super.initState();
    _initTheme();
    _initAppLinks();
  }

  void _initTheme() {
    settingsController.setTheme(
      settingsController.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
    );
  }

  /// ✅ Deep link handling
  Future<void> _initAppLinks() async {
    _appLinks = AppLinks();

    _appLinks.uriLinkStream.listen((uri) {
      print('🔗 Foreground link: $uri');
      _consumeLink(uri);
    });

    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      print('🚀 Opened via link: $initialUri');
      _consumeLink(initialUri);
    }
  }

  void _consumeLink(Uri uri) {
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
