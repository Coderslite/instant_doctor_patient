import 'dart:async';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/controllers/AlarmController.dart';
import 'package:instant_doctor/services/DoctorService.dart';
import 'package:instant_doctor/services/NotificationService.dart';
import 'package:instant_doctor/services/TransactionService.dart';
import 'package:instant_doctor/services/WalletService.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'AppTheme.dart';
import 'constant/color.dart';
import 'constant/constants.dart';
import 'controllers/FirebaseMessaging.dart';
import 'controllers/SettingController.dart';
import 'firebase_options.dart';
import 'screens/splash_screen/splash_screen.dart';
import 'services/AppointmentService.dart';
import 'services/MedicationService.dart';
import 'services/UserService.dart';
import 'package:timezone/data/latest.dart' as tz;

SettingsController settingsController = Get.put(SettingsController());
WalletService walletService = WalletService();
UserService userService = UserService();
NotificationService notificationService = NotificationService();
TransactionService transactionService = TransactionService();
var db = FirebaseFirestore.instance;
AppointmentService appointmentService = AppointmentService();
MedicationService medicationService = MedicationService();
DoctorService doctorService = DoctorService();
User? user = FirebaseAuth.instance.currentUser;
// Initialize Flutter Local Notifications Plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
  var firebaseStorage = FirebaseStorage.instance;
AlarmController alarmController = Get.put(AlarmController());
// BackgroundService backgroundService = BackgroundService();

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    alarmController.displayNotification();
    return Future.value(true);
  });
}

@pragma('vm:entry-point')
void alarmNotification() {
  alarmController.displayNotification();
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  FirebaseMessagings().displayLocalNotification(message);
}

Future<void> handleCheckMedication() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userToken = prefs.getString(MESSAGE_TOKEN);
  print(userToken);
}

Future<void> initializeTheme() async {
  int themeModeIndex = getIntAsync(THEME_MODE_INDEX);
  if (themeModeIndex == ThemeModeLight) {
    settingsController.isDarkMode.value = false;
  } else if (themeModeIndex == ThemeModeDark) {
    settingsController.isDarkMode.value = true;
  }
  settingsController.setTheme(
    settingsController.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
  );
}

Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  await initialize();
  await initializeTheme();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  //  await FirebaseAnalytics().logEvent(name: 'app_start');
  await initMethod();
  FirebaseMessagings().handleInit();
  Workmanager().initialize(
      callbackDispatcher, // The top level function, aka callbackDispatcher
      isInDebugMode:
          false // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
      );
  settingsController.handleGetVideoCallKeys();
}

Future<void> main() async {
  tz.initializeTimeZones();
  await initializeApp();
  runApp(const MyApp());
}

Future<void> initMethod() async {
  await initialize(aLocaleLanguageList: [
    LanguageDataModel(
        id: 1,
        name: 'English',
        languageCode: 'en',
        flag: 'assets/flag/ic_us.png'),
    // ... (other languages)
  ]);
  defaultLoaderAccentColorGlobal = kPrimary;
  selectedLanguageDataModel =
      getSelectedLanguageModel(defaultLanguage: defaultLanguage);
  if (selectedLanguageDataModel != null) {
    settingsController
        .setLanguage(selectedLanguageDataModel!.languageCode.validate());
  } else {
    selectedLanguageDataModel = localeLanguageList.first;
    settingsController
        .setLanguage(selectedLanguageDataModel!.languageCode.validate());
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<void> init() async {
    settingsController.setTheme(
        settingsController.isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    setOrientationPortrait();
    return Obx(
      () => GetMaterialApp(
        title: 'Instant Doctor',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: settingsController.isDarkMode.value
            ? ThemeMode.dark
            : ThemeMode.light,
        locale: Locale(settingsController.selectedLanguage),
        supportedLocales: LanguageDataModel.languageLocales(),
        localeResolutionCallback: (locale, supportedLocales) => locale,
        home: const SplashScreen(),
        builder: scrollBehaviour(),
      ),
    );
  }
}
