import 'package:get/get.dart';
import 'package:instant_doctor/main.dart';
import 'package:instant_doctor/services/GetUserId.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ZegoCloudController extends GetxController {
  handleInit() async {
    await getUserId();
    print("Zego Cloud initialized");
    ZegoUIKitPrebuiltCallInvitationService().init(
      appID: settingsController.appId ??
          int.parse(dotenv.env['ZEGO_APP_ID'] ?? "0"),
      appSign: settingsController.appSign.isEmpty
          ? (dotenv.env['ZEGO_APP_SIGN'] ?? "")
          : settingsController.appSign,
      userID: userController.userId.value,
      userName: userController.fullName.value,
      plugins: [
        ZegoUIKitSignalingPlugin(),
      ],
      // uiConfig: ZegoCallInvitationUIConfig(
      //   invitee: ZegoCallInvitationInviteeUIConfig(),
      //   inviter: ZegoCallInvitationInviterUIConfig(),
      // ),
      config: ZegoCallInvitationConfig(
        permissions: [
          ZegoCallInvitationPermission.camera,
          ZegoCallInvitationPermission.microphone,
        ],
      ),
      ringtoneConfig: ZegoCallRingtoneConfig(
        incomingCallPath: "assets/audio/ringtone1.mp3",
        outgoingCallPath: "",
      ),
      notificationConfig: ZegoCallInvitationNotificationConfig(
        androidNotificationConfig: ZegoCallAndroidNotificationConfig(
            channelID: "ZegoUIKit",
            channelName: "Call Notifications",
            sound: "assets/audio/ringtone1.mp3",
            icon: "assets/images/logo.png",
            fullScreenBackground: 'assets/images/logo.png',
            messageVibrate: true,
            messageSound: "assets/audio/ringtone1.mp3"),
        iOSNotificationConfig: ZegoCallIOSNotificationConfig(
          appName: "Instant Doctor",
          // isSandboxEnvironment: true,
          systemCallingIconName: 'CallKitIcon',
        ),
      ),
      invitationEvents: ZegoUIKitPrebuiltCallInvitationEvents(
        onError: (err) {
          // snackBar(Get.context!,
          //     backgroundColor: fireBrick, title: err.toString());
        },
        onOutgoingCallAccepted: (callID, caller) {
          toast("User Joined");
        },
        onOutgoingCallDeclined: (callID, caller, customData) {
          toast("Call cancelled");
        },
      ),
    );
  }

  void onUserLogout() {
    ZegoUIKitPrebuiltCallInvitationService().uninit();
  }
}
