import 'package:flutter/material.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/main.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/backButton.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                backButton(context),
                Text(
                  "Settings",
                  style: boldTextStyle(),
                ),
                const Text("   "),
              ],
            ),
            20.height,
            SwitchListTile(
              value: settingsController.isDarkMode.value ? true : false,
              // activeColor: kPrimary,
              activeTrackColor: kPrimary,
              // trackOutlineColor: MaterialStateColor.
              inactiveTrackColor: kPrimaryLight,
              onChanged: (val) {
                settingsController.handleChangeTheme();
                setState(() {});
              },
              title: Text(
                "Dark Mode",
                style: primaryTextStyle(),
              ),
            ),
          ],
        ),
      )),
    );
  }
}
