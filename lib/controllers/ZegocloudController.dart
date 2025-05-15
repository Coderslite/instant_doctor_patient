import 'package:get/get.dart';
import 'package:instant_doctor/main.dart';
import 'package:instant_doctor/services/GetUserId.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

class ZegoCloudController extends GetxController {
  handleInit() async {
    await getUserId();
    print("Zego Cloud initialized");
    ZegoUIKitPrebuiltCallInvitationService().init(
      appID: settingsController.appId ?? 1629680479 /*input your AppID*/,
      appSign: settingsController.appSign.isEmpty
          ? '32f49c8bef297a57bc73cb0a2d952c0f4704a060e9c888a41b998da21dc5520d'
          : settingsController.appSign /*input your AppSign*/,
      userID: userController.userId.value,
      userName: userController.fullName.value,
      plugins: [
        ZegoUIKitSignalingPlugin(),
      ],
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
            showFullScreen: true,
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
