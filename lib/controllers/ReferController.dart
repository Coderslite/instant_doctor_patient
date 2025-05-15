import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:share_plus/share_plus.dart';


class ReferralController extends GetxController {
  String title =
      "Register to get excellent medical care service from our medical professionals";


  handleShare({required String link}) async {
    final result = await Share.share(
      link,
      subject: title,
    );
    if (result.status == ShareResultStatus.success) {
      toast("We will notify you once your link is used to register");
    } else {
    }
    return;
  }


}
