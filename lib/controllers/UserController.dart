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
  RxBool referralProgramApplied = false.obs;
  RxString fullName = ''.obs;
  RxString phone = ''.obs;
  RxBool isFirstTime = false.obs;
  // RxBool isTrialUsed = false.obs;
  RxString pin = ''.obs;
  RxInt referralBalance = 0.obs;
  RxBool referralEnabled = false.obs;
  RxString bankName = ''.obs;
  RxString accountName = ''.obs;
  RxString accountNumber = ''.obs;
  handleFirstTimeUsed() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool(
      'isFirstTime',
      false,
    );
  }
}
