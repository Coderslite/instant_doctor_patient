// ignore_for_file: file_names
import 'package:get/get.dart';
import 'package:instant_doctor/main.dart';
import 'package:nb_utils/nb_utils.dart';

import '../controllers/LocationController.dart';
import '../controllers/UserController.dart';
import 'UserService.dart';
import 'PricingService.dart';

final userController = Get.find<UserController>();
final userService = Get.find<UserService>();
final locationController = Get.find<LocationController>();

getUserId() async {
  var prefs = await SharedPreferences.getInstance();
  if (prefs.getString('userId').toString() != 'null' ||
      prefs.getString('userId').toString() != '') {
    userController.userId.value = prefs.getString('userId').toString();
    userController.pin.value = prefs.getString('pin').toString();
    var userProf =
        await userService.getProfileById(userId: userController.userId.value);
    
    // Sync pricing region and currency
    final pricingService = Get.find<PricingService>();
    if (userProf.country.validate().isNotEmpty) {
      pricingService.userCountry.value = userProf.country.validate();
      prefs.setString('userCountry', userProf.country.validate());
    }
    if (userProf.currency.validate().isNotEmpty) {
      pricingService.userCurrency.value = userProf.currency.validate();
      prefs.setString('userCurrency', userProf.currency.validate());
    } else if (userProf.country.validate().isNotEmpty) {
      final mappedCurrency = pricingService.getCurrencyFromCountry(userProf.country.validate());
      pricingService.userCurrency.value = mappedCurrency;
      prefs.setString('userCurrency', mappedCurrency);
    }
    pricingService.fetchExchangeRate();

    // userController.isTrialUsed.value = userProf.isTrialUsed.validate();
    locationController.latitude.value = userProf.location!.latitude;
    locationController.longitude.value = userProf.location!.longitude;
    locationController.address.value = userProf.address.validate();
    locationController.myCountry.value = userProf.country.validate();
    settingsController.trialAvailable.value =
        userProf.isTrialAvailable.validate();
    userController.isFirstTime.value =
        prefs.getBool('isFirstTime').toString() == 'null'
            ? true
            : prefs.getBool('isFirstTime').validate();
    userController.tag.value = userProf.tag.validate();
    userController.fullName.value =
        "${userProf.firstName.validate()} ${userProf.lastName.validate()}";
    userController.phone.value = userProf.phoneNumber.validate();
    userController.referralBalance.value =
        userProf.referralBalance.validate().toInt();
    userController.referralProgramApplied.value =
        userProf.referralProgramApplied.validate();
    userController.referralEnabled.value = userProf.referralEnabled.validate();
  }
}
