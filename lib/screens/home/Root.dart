import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/main.dart';
import 'package:instant_doctor/screens/authentication/auth_screen.dart';
import 'package:instant_doctor/screens/home/Home2.dart';
import 'package:instant_doctor/screens/drug/OrderHistory.dart';
import 'package:instant_doctor/screens/profile/Profile.dart';
import 'package:instant_doctor/services/UserService.dart';
import 'package:iconsax/iconsax.dart';
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
    // await locationController.handleGetMyLocation(isLogin: false, email: '');
    // settingsController.version.value = await getAppVersion();
    // handleShowUpdateAvailable(Get.context!);
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
        // _shouldLock = true;
        await handleOffline();
        break;
      case AppLifecycleState.inactive:
        // App is in an inactive state (e.g., during a phone call)
        // _shouldLock = true;
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
    Iconsax.home,
    Iconsax.calendar,
    Iconsax.bag_2,
    Iconsax.user,
  ];

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      showLater: false,
      showIgnore: false,
      shouldPopScope: () => false,
      upgrader: Upgrader(
        durationUntilAlertAgain: const Duration(minutes: 1),
      ),
      child: WillPopScope(
        onWillPop: () async {
          if (settingsController.selectedIndex.value == 0) {
            return exit(0); // Use exit(0) for a cleaner exit
          } else {
            selectedTab(0);
            return false;
          }
        },
        child: Scaffold(
          extendBody: true, // Allows content to be behind the floating bar
          body: IndexedStack(
            index: settingsController.selectedIndex.value,
            children: const [
              Home2(),
              AppointmentScreen(),
              OrderHistory(),
              ProfileScreen(),
            ],
          ),
          bottomNavigationBar: _buildFloatingBottomBar(),
        ),
      ),
    );
  }

  Widget _buildFloatingBottomBar() {
    const labels = ["Home", "Appt", "Orders", "Profile"];

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 34),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: obsidian,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        bottom: false, // Ensure symmetrical padding inside the bar
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(iconList.length, (index) {
            final isSelected = settingsController.selectedIndex.value == index;
            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() => settingsController.selectedIndex.value = index);
              },
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? kPrimary.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      iconList[index],
                      color: isSelected ? kPrimary : white.withOpacity(0.4),
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      labels[index],
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? kPrimary : white.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
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
