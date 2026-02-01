import 'package:get/get.dart';
import 'package:instant_doctor/services/GetUserId.dart';
import 'package:instant_doctor/services/ReferralService.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:share_plus/share_plus.dart';

class ReferralController extends GetxController {
  var isLoading = false.obs;
  String title =
      "Register to get excellent medical care service from our medical professionals";

  handleShare({required String code}) async {
    const String appLink = 'https://instantdoctor.co/app';

    final String shareText = 'Download Instant Doctor here: $appLink\n\n'
        'Use my referral code: $code\n'
        'Get rewarded when you sign up!';

    final result = await Share.share(
      shareText,
      subject: 'Instant Doctor Referral – Code: $code',
    );

    if (result.status == ShareResultStatus.success) {
      toast("We'll notify you when someone joins with your code");
    }
  }

  handleNewReferral({required String referralCode}) async {
    var referralService = Get.find<ReferralService>();
    var userId = userController.userId.value;
    try {
      isLoading.value = true;
      await referralService.newReferral(
          userId: userId, referredBy: referralCode.trim());
    } finally {
      isLoading.value = false;
    }
  }
}
