import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:share_plus/share_plus.dart';

import '../services/generateLink.dart';

class ReferralController extends GetxController {
  RxString shareLink = ''.obs;
  String title =
      "Register to get excellent medical care service from our medical professionals";
  handleRefer() async {
    if (shareLink.value.isNotEmpty) {
      await handleShare(
        link: shareLink.value,
      );
    }
  }

  handleShare({required String link}) async {
    final result = await Share.shareWithResult(
      link,
      subject: title,
    );
    if (result.status == ShareResultStatus.success) {
      toast("We will notify you once your link is used to register");
    } else {
      handleGetLink();
    }
    return;
  }

  handleGetLink() async {
    var link = await generateShortLink(title: title);
    shareLink.value = link;
  }

  @override
  void onInit() {
    handleGetLink();
    super.onInit();
  }
}
