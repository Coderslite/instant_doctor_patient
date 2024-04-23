import 'package:flutter/material.dart';
import 'package:instant_doctor/models/UserModel.dart';
import 'package:instant_doctor/screens/doctors/SingleDoctor.dart';
import 'package:nb_utils/nb_utils.dart';

class MenuItem {
  const MenuItem({
    required this.text,
    required this.icon,
  });

  final String text;
  final IconData icon;
}

abstract class MenuItems {
  static const List<MenuItem> firstItems = [doctor, report];
  static const List<MenuItem> secondItems = [];

  static const doctor = MenuItem(text: 'Doctor Info', icon: Icons.person);
  static const report = MenuItem(text: 'Report Doctor', icon: Icons.error);
  static const settings = MenuItem(text: 'Settings', icon: Icons.settings);
  static const logout = MenuItem(text: 'Log Out', icon: Icons.logout);

  static Widget buildItem(MenuItem item) {
    return Row(
      children: [
        Icon(item.icon, color: Colors.white, size: 22),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: Text(
            item.text,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  static void onChanged(BuildContext context, MenuItem item, UserModel doctor) {
    switch (item) {
      case MenuItems.doctor:
        //Do something
        SingleDoctorScreen(doctor: doctor).launch(context);
        break;
      case MenuItems.settings:
        //Do something
        break;
      case MenuItems.report:
        //Do something
        break;
      case MenuItems.logout:
        //Do something
        break;
    }
  }
}
