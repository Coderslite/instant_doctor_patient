import 'package:get/get.dart';
import 'package:instant_doctor/models/UserModel.dart';
import 'package:instant_doctor/services/UserService.dart';

class UserController extends GetxController {
  UserService userService = UserService();
  UserModel? userModel;
  RxString userId = ''.obs;
  RxString currency = ''.obs;
  RxString token = ''.obs;
  RxString videocallToken = ''.obs;
  RxString tag = ''.obs;
  
}
