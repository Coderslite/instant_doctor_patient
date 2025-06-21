import 'dart:io';

import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/main.dart';
import 'package:instant_doctor/screens/home/Home2.dart';
import 'package:instant_doctor/screens/drug/OrderHistory.dart';
import 'package:instant_doctor/screens/profile/Profile.dart';
import 'package:instant_doctor/services/UserService.dart';
import 'package:ionicons/ionicons.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../constant/constants.dart';
import '../../controllers/OrderController.dart';
import '../../services/GetUserId.dart';
import '../appointment/Appointment.dart';
import 'package:upgrader/upgrader.dart';

class Root extends StatefulWidget {
  static String tag = '/Root';

  const Root({super.key});

  @override
  RootState createState() => RootState();
}

class RootState extends State<Root> with WidgetsBindingObserver {
  UserService userService = UserService();
  final orderController = Get.find<OrderController>();

  @override
  void initState() {
    getUserId();
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    handleOnline();
    orderController.handleGetSavedCarts();
    handleUpdateToken();
  }

  handleUpdateToken() async {
    var prefs = await SharedPreferences.getInstance();
    var token = prefs.getString(MESSAGE_TOKEN).toString();
    if (token.isNotEmpty) {
      await userService.updateToken(
          userId: userController.userId.value, token: token);
    }
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
        await userService.updateStatus(
            userId: userController.userId.value, status: OFFLINE);
        break;
      case AppLifecycleState.inactive:
        // App is in an inactive state (e.g., during a phone call)
        await userService.updateStatus(
            userId: userController.userId.value, status: OFFLINE);
        break;
      case AppLifecycleState.detached:
        // App is detached (not running)
        await userService.updateStatus(
            userId: userController.userId.value, status: OFFLINE);
        break;
      // No need to handle AppLifecycleState.hidden as it is not typically used
      default:
        break;
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  final iconList = <IconData>[
    Ionicons.home,
    // Ionicons.cart,
    // Ionicons.chatbubble_ellipses,
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
        // bottomNavigationBar: getFooter(),
        // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        // floatingActionButton: FloatingActionButton(
        //   backgroundColor: kPrimary,
        //   onPressed: () {},
        //   child: Image.asset("assets/images/doctor.png").paddingAll(10),
        // ),

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
          //other params
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
                // HomeScreen(),
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

  // Widget getFooter() {
  //   return Container(
  //     margin: const EdgeInsets.only(
  //       left: 40,
  //       right: 40,
  //       bottom: 40,
  //     ),
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(20),
  //       gradient: LinearGradient(
  //         colors: [
  //           kPrimary,
  //           kPrimaryLight,
  //         ],
  //         begin: Alignment.centerRight,
  //       ),
  //     ),
  //     child: ClipRRect(
  //       borderRadius: BorderRadius.circular(30),
  //       child: BottomNavigationBar(
  //         selectedItemColor: white,
  //         backgroundColor: transparentColor,
  //         unselectedItemColor: gray,
  //         onTap: (index) {
  //           selectedTab(index);
  //         },
  //         type: BottomNavigationBarType.fixed,
  //         currentIndex: selectedIndex,
  //         showSelectedLabels: false,
  //         showUnselectedLabels: false,
  //         iconSize: 30,
  //         items: <BottomNavigationBarItem>[
  //           BottomNavigationBarItem(
  //             icon: Icon(Ionicons.home),
  //             tooltip: 'Home',
  //             label: 'Home',
  //             activeIcon: CircleAvatar(
  //               backgroundColor: bottomNavColor,
  //               radius: 18,
  //               child: Icon(
  //                 Ionicons.home,
  //                 size: 24,
  //                 color: gray,
  //               ),
  //             ),
  //           ),
  //           BottomNavigationBarItem(
  //             icon: Icon(Icons.shopping_cart),
  //             tooltip: 'Order History',
  //             label: 'Order History',
  //             activeIcon: CircleAvatar(
  //               backgroundColor: bottomNavColor,
  //               radius: 18,
  //               child: Stack(
  //                 clipBehavior: Clip.none,
  //                 alignment: Alignment.topRight,
  //                 children: [
  //                   Icon(
  //                     Icons.shopping_cart,
  //                     color: white,
  //                   ),
  //                   Positioned(
  //                     child: StreamBuilder<List<OrderModel>>(
  //                         stream: orderService.getMyPendOrders(),
  //                         builder: (context, snapshot) {
  //                           if (snapshot.hasData && snapshot.data!.isNotEmpty) {
  //                             return Badge(
  //                               label: Text(
  //                                 "${snapshot.data!.length}",
  //                                 style: secondaryTextStyle(
  //                                     size: 12, color: white),
  //                               ),
  //                             );
  //                           }
  //                           return SizedBox.shrink();
  //                         }),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //           BottomNavigationBarItem(
  //             icon: Icon(Ionicons.chatbubble_ellipses),
  //             tooltip: 'Appointments',
  //             label: 'Appointments',
  //             activeIcon: CircleAvatar(
  //               backgroundColor: bottomNavColor,
  //               radius: 18,
  //               child: Icon(
  //                 Ionicons.chatbubble_ellipses,
  //                 size: 24,
  //                 color: gray,
  //               ),
  //             ),
  //           ),
  //           BottomNavigationBarItem(
  //             icon: Icon(Ionicons.person),
  //             tooltip: 'Profile',
  //             label: 'Profile',
  //             activeIcon: CircleAvatar(
  //               backgroundColor: bottomNavColor,
  //               radius: 18,
  //               child: Icon(
  //                 Ionicons.person,
  //                 size: 24,
  //                 color: gray,
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  void selectedTab(int index) {
    setState(() {
      settingsController.selectedIndex.value = index;
    });
  }
}
