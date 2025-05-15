// ignore_for_file: file_names
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../controllers/LocationController.dart';
import '../controllers/UserController.dart';
import 'UserService.dart';

final userController = Get.find<UserController>();
final userService = Get.find<UserService>();
final locationController = Get.find<LocationController>();


getUserId() async {
  var prefs = await SharedPreferences.getInstance();
  if (prefs.getString('userId').toString() != 'null' ||
      prefs.getString('userId').toString() != '') {
    userController.userId.value = prefs.getString('userId').toString();
    var userProf =
        await userService.getProfileById(userId: userController.userId.value);
    userController.currency.value = userProf.currency.validate();
    userController.isTrialUsed.value = userProf.isTrialUsed.validate();
    locationController.latitude.value = userProf.location!.latitude;
    locationController.longitude.value = userProf.location!.longitude;
    locationController.address.value = userProf.address.validate();
    userController.isFirstTime.value =
        prefs.getBool('isFirstTime').toString() == 'null'
            ? true
            : prefs.getBool('isFirstTime').validate();
    userController.tag.value = userProf.tag.validate();
    userController.fullName.value =
        "${userProf.firstName.validate()} ${userProf.lastName.validate()}";
  }
}
