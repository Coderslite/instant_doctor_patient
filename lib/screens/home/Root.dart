import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/controllers/UserController.dart';
import 'package:instant_doctor/main.dart';
import 'package:instant_doctor/screens/profile/Profile.dart';
import 'package:instant_doctor/services/UserService.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../constant/constants.dart';
import '../appointment/Appointment.dart';
import '../wallet/WalletScreen.dart';
import 'HomeScreen.dart';

class Root extends StatefulWidget {
  static String tag = '/Root';

  @override
  RootState createState() => RootState();
}

class RootState extends State<Root> with WidgetsBindingObserver {
  int selectedIndex = 0;
  UserService userService = UserService();
  UserController userController = Get.put(UserController());
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    handleOnline();
    handleUpdateToken();
  }

  handleUpdateToken() async {
    var prefs = await SharedPreferences.getInstance();
    var token = prefs.getString(MESSAGE_TOKEN).toString();
    await userService.updateToken(
        userId: userController.userId.value, token: token);
  }


  handleOnline() async {
    await userService.updateStatus(
        userId: userController.userId.value, status: ONLINE);
  }

  @override
  void didUpdateWidget(covariant Root oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {});
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        // App came to the foreground
        await userService.updateStatus(
            userId: userController.userId.value, status: ONLINE);
        break;
      case AppLifecycleState.paused:
        // App went to the background
        // await userService.updateStatus(userId: userController.userId.value, status: OFFLINE);

        break;
      case AppLifecycleState.inactive:
        // App is in an inactive state (e.g., during a phone call)
        await userService.updateStatus(userId: userController.userId.value, status: OFFLINE);

        break;
      case AppLifecycleState.detached:
        // App is detached (not running)
        await userService.updateStatus(
            userId: userController.userId.value, status: ONLINE);

        break;
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (selectedIndex == 0) {
          return exit(1);
        } else {
          return selectedTab(0);
        }
      },
      child: Scaffold(
        bottomNavigationBar: getFooter(),
        body: SafeArea(
          child: IndexedStack(
            index: selectedIndex,
            children: const [
              HomeScreen(),
              WalletScreen(),
              AppointmentScreen(),
              ProfileScreen(),
            ],
          ),
        ),
      ),
    );
  }

  getFooter() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      height: 59,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BottomNavigationBar(
          selectedItemColor: white,
          backgroundColor: bottomNavColor,
          unselectedItemColor: black,
          onTap: (index) {
            selectedTab(index);
          },
          type: BottomNavigationBarType.fixed,
          currentIndex: selectedIndex,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          iconSize: 26,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              tooltip: 'Home',
              label: 'Home',
              activeIcon: CircleAvatar(
                backgroundColor: kPrimary,
                radius: 14,
                child: Icon(
                  Icons.home,
                  size: 24,
                  color: white,
                ),
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.wallet),
              tooltip: 'Wallet',
              label: 'Wallet',
              activeIcon: CircleAvatar(
                backgroundColor: kPrimary,
                radius: 14,
                child: Icon(
                  Icons.wallet,
                  size: 24,
                  color: white,
                ),
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.file_open),
              tooltip: 'Appointments',
              label: 'Appointments',
              activeIcon: CircleAvatar(
                backgroundColor: kPrimary,
                radius: 14,
                child: Icon(
                  Icons.file_open,
                  size: 24,
                  color: white,
                ),
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              tooltip: 'Profile',
              label: 'Profile',
              activeIcon: CircleAvatar(
                backgroundColor: kPrimary,
                radius: 14,
                child: Icon(
                  Icons.person,
                  size: 24,
                  color: white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  selectedTab(index) {
    selectedIndex = index;
    setState(() {});
  }
}
