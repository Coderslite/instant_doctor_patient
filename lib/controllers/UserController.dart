import 'package:get/get.dart';
import 'package:instant_doctor/models/UserModel.dart';
import 'package:instant_doctor/services/UserService.dart';
import 'package:nb_utils/nb_utils.dart';

class UserController extends GetxController {
  UserService userService = UserService();
  UserModel? userModel;
  RxString userId = ''.obs;
  RxString currency = ''.obs;
  RxString token = ''.obs;
  RxString videocallToken = ''.obs;
  RxString tag = ''.obs;
  RxString fullName = ''.obs;
  RxBool isFirstTime = false.obs;
  RxBool isTrialUsed = false.obs;

  handleFirstTimeUsed() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool(
      'isFirstTime',
      false,
    );
  }
}
