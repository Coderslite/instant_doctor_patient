import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/UserController.dart';

UserController userController = Get.put(UserController());

getUserId() async {
  var prefs = await SharedPreferences.getInstance();
  if (prefs.getString('userId').toString() != 'null' ||
      prefs.getString('userId').toString() != '') {
    userController.userId.value = prefs.getString('userId').toString();
  }
}
