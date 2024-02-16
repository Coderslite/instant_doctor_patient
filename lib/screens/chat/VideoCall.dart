// Flutter imports:
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:instant_doctor/main.dart';
import 'package:instant_doctor/services/GetUserId.dart';

// Package imports:
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class VideoCall extends StatefulWidget {
  final String appointmentId;
  const VideoCall({Key? key, required this.appointmentId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => VideoCallState();
}

class VideoCallState extends State<VideoCall> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ZegoUIKitPrebuiltCall(
          appID: settingsController.appId! /*input your AppID*/,
          appSign: settingsController.appSign /*input your AppSign*/,
          userID: userController.userId.value,
          userName: 'Name',
          callID: widget.appointmentId,
          config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
            ..topMenuBarConfig.isVisible = true
            ..topMenuBarConfig.buttons = [
              ZegoMenuBarButtonName.minimizingButton,
              ZegoMenuBarButtonName.showMemberListButton,
              // ZegoCallMenuBarButtonName.chatButton,
            ]),
    );
  }
}
