import 'dart:async';
import 'dart:io';

import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/main.dart';
import 'package:instant_doctor/screens/authentication/auth_screen.dart';
import 'package:instant_doctor/screens/home/Home2.dart';
import 'package:instant_doctor/screens/drug/OrderHistory.dart';
import 'package:instant_doctor/screens/profile/Profile.dart';
import 'package:instant_doctor/services/UserService.dart';
import 'package:ionicons/ionicons.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:upgrader/upgrader.dart';

import '../../constant/constants.dart';
import '../../controllers/OrderController.dart';
import '../../services/GetUserId.dart';
import '../appointment/Appointment.dart';

class Root extends StatefulWidget {
  static String tag = '/Root';

  const Root({super.key});

  @override
  RootState createState() => RootState();
}

class RootState extends State<Root> with WidgetsBindingObserver {
  UserService userService = UserService();
  final orderController = Get.find<OrderController>();
  bool _shouldLock = false;
  bool _isAuthScreenActive = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }

  Future<void> _initialize() async {
    await getUserId();
    await handleOnline();
    await orderController.handleGetSavedCarts();
    await handleUpdateToken();
  }

  Future<void> handleUpdateToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(MESSAGE_TOKEN) ?? '';
    if (token.isNotEmpty) {
      await userService.updateToken(
          userId: userController.userId.value, token: token);
    }
  }

  Future<void> handleOnline() async {
    await userService.updateStatus(
        userId: userController.userId.value, status: ONLINE);
  }

  Future<void> handleOffline() async {
    await userService.updateStatus(
        userId: userController.userId.value, status: OFFLINE);
  }

  Future<void> _showAuthScreen() async {
    if ((_isAuthScreenActive || !mounted)) return;
    _isAuthScreenActive = true;
    await showAdaptiveDialog(
      context: context,
      barrierColor: kPrimaryDark,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (context) => AuthScreen(
        fromApp: true,
        onAuthSuccess: () {
          _isAuthScreenActive = false;
          _shouldLock = false;
          Navigator.pop(context); // Close the dialog
        },
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        // App came to the foreground
        if (_shouldLock && userController.userId.value.isNotEmpty) {
          await _showAuthScreen();
        }
        await handleOnline();
        break;
      case AppLifecycleState.paused:
        // App went to the background
        _shouldLock = true;
        await handleOffline();
        break;
      case AppLifecycleState.inactive:
        // App is in an inactive state (e.g., during a phone call)
        await handleOffline();
        break;
      case AppLifecycleState.detached:
        // App is detached (not running)
        await handleOffline();
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  final iconList = <IconData>[
    Ionicons.home,
    CupertinoIcons.calendar_today,
    Icons.shopping_cart,
    Ionicons.person,
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (settingsController.selectedIndex.value == 0) {
          return exit(0); // Use exit(0) for a cleaner exit
        } else {
          selectedTab(0);
          return false;
        }
      },
      child: Scaffold(
        bottomNavigationBar: AnimatedBottomNavigationBar(
          elevation: 0.1,
          icons: iconList,
          iconSize: 30,
          blurEffect: false,
          safeAreaValues: SafeAreaValues(),
          scaleFactor: 2,
          activeIndex: settingsController.selectedIndex.value,
          gapLocation: GapLocation.none,
          activeColor: kPrimary,
          inactiveColor: grey,
          backgroundColor: context.cardColor,
          notchSmoothness: NotchSmoothness.defaultEdge,
          leftCornerRadius: 30,
          rightCornerRadius: 30,
          onTap: (index) =>
              setState(() => settingsController.selectedIndex.value = index),
        ),
        resizeToAvoidBottomInset: true,
        body: UpgradeAlert(
          upgrader: Upgrader(
            durationUntilAlertAgain: const Duration(minutes: 1),
          ),
          child: SafeArea(
            child: IndexedStack(
              index: settingsController.selectedIndex.value,
              children: const [
                Home2(),
                AppointmentScreen(),
                OrderHistory(),
                ProfileScreen(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void selectedTab(int index) {
    setState(() {
      settingsController.selectedIndex.value = index;
    });
  }
}
