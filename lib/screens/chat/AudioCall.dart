// // Flutter imports:
// // ignore_for_file: deprecated_member_use

// import 'package:flutter/material.dart';
// import 'package:instant_doctor/main.dart';
// import 'package:instant_doctor/services/GetUserId.dart';

// // Package imports:
// import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

// class VideoCall extends StatefulWidget {
//   final String appointmentId;
//   const VideoCall({super.key, required this.appointmentId});

//   @override
//   State<StatefulWidget> createState() => VideoCallState();
// }

// class VideoCallState extends State<VideoCall> {
//   var userName = '';

//   handleGetUsername() async {
//     var user =
//         await userService.getProfileById(userId: userController.userId.value);
//     userName = "${user.firstName} ${user.lastName}";
//   }

//   @override
//   void initState() {
//     handleGetUsername();
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: ZegoUIKitPrebuiltCall(
//           appID: settingsController.appId! /*input your AppID*/,
//           appSign: settingsController.appSign /*input your AppSign*/,
//           userID: userController.userId.value,
//           userName: userName,
//           callID: widget.appointmentId,
//           config: ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall()
//             ..topMenuBarConfig.isVisible = true
//             ..topMenuBarConfig.buttons = [
//               ZegoMenuBarButtonName.minimizingButton,
//               ZegoMenuBarButtonName.showMemberListButton,
//               ZegoCallMenuBarButtonName.toggleCameraButton,
//             ]),
//     );
//   }
// }
