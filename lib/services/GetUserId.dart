import 'package:get/get.dart';
import 'package:instant_doctor/main.dart';
import 'package:nb_utils/nb_utils.dart';

import '../controllers/UserController.dart';

UserController userController = Get.put(UserController());

getUserId() async {
  var prefs = await SharedPreferences.getInstance();
  if (prefs.getString('userId').toString() != 'null' ||
      prefs.getString('userId').toString() != '') {
    userController.userId.value = prefs.getString('userId').toString();
    var userProf =
        await userService.getProfileById(userId: userController.userId.value);
    userController.currency.value = userProf.currency.validate();
    userController.tag.value = userProf.tag.validate();
  }
}
