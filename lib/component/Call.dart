// import 'dart:async';
// import 'dart:convert';
// import 'dart:math';
// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// import 'package:flutter/material.dart';
// import 'package:nb_utils/nb_utils.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:http/http.dart' as http;
// import '../constant/color.dart';
// import '../constant/constants.dart';

// const channel = "InstantDoctor";

// class MyCall extends StatefulWidget {
//   const MyCall({Key? key}) : super(key: key);

//   @override
//   State<MyCall> createState() => _MyCallState();
// }

// class _MyCallState extends State<MyCall> {
//   int? _remoteUid;
//   bool _localUserJoined = false;
//   late RtcEngine _engine;
//   var rand = Random();
//   int? id;
//   bool isHost = false; // New variable to track the host status
//   bool muted = false;
//   bool isFront = true;
//   @override
//   void initState() {
//     super.initState();
//     initAgora();
//   }

//   Future<void> initAgora() async {
//     // retrieve permissions
//     await [Permission.microphone, Permission.camera].request();

//     // create the engine
//     _engine = createAgoraRtcEngine();
//     await _engine.initialize(RtcEngineContext(
//       appId: VideoCallKey.appId,
//       channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
//     ));

//     _engine.registerEventHandler(
//       RtcEngineEventHandler(
//         onJoinChannelSuccess: (RtcConnection connection, int elapsed) async {
//           debugPrint("local user ${connection.localUid} joined");
//           setState(() {
//             _localUserJoined = true;
//           });

//           if (_remoteUid == null && !isHost) {
//             // The first user to join is the host
//             isHost = true;
//             await _engine.setClientRole(
//                 role: ClientRoleType.clientRoleBroadcaster);
//           } else {
//             // Subsequent users are audience
//             await _engine.setClientRole(
//                 role: ClientRoleType.clientRoleAudience);
//           }
//         },
//         onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
//           debugPrint("remote user $remoteUid joined");
//           setState(() {
//             _remoteUid = remoteUid;
//           });
//         },
//         onUserOffline: (RtcConnection connection, int remoteUid,
//             UserOfflineReasonType reason) {
//           debugPrint("remote user $remoteUid left channel");
//           setState(() {
//             _remoteUid = null;
//           });
//         },
//         onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
//           debugPrint(
//               '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
//           // Regenerate temporary token if needed
//           // _regenerateTemporaryToken();
//         },
//       ),
//     );

//     await _engine.enableVideo();
//     await _engine.startPreview();
//     id = rand.nextInt(10);
//     // Initial use of the temporary token
//     await _engine.joinChannel(
//       token: VideoCallKey.token,
//       channelId: channel,
//       uid: id!,
//       options: const ChannelMediaOptions(),
//     );
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     _dispose();
//   }

//   Future<void> _dispose() async {
//     await _engine.leaveChannel();
//     await _engine.release();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Agora Video Call',
//           style: primaryTextStyle(),
//         ),
//       ),
//       body: Stack(
//         alignment: Alignment.bottomCenter,
//         children: [
//           Stack(
//             children: [
//               Center(
//                 child: _remoteVideo(),
//               ),
//               Align(
//                 alignment: Alignment.topLeft,
//                 child: SizedBox(
//                   width: 100,
//                   height: 150,
//                   child: Center(
//                     child: _localUserJoined
//                         ? AgoraVideoView(
//                             controller: VideoViewController(
//                               rtcEngine: _engine,
//                               canvas: const VideoCanvas(uid: 0),
//                             ),
//                           )
//                         : const Loader(),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           Positioned(
//               bottom: 30,
//               child: Container(
//                 height: 60,
//                 width: MediaQuery.of(context).size.width / 1.4,
//                 padding:
//                     const EdgeInsets.symmetric(vertical: 10, horizontal: 50),
//                 decoration: BoxDecoration(
//                   color: kPrimaryLight,
//                   borderRadius: BorderRadius.circular(40),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     CircleAvatar(
//                       backgroundColor: white,
//                       radius: 40,
//                       child: IconButton(
//                         onPressed: () {
//                           _endCall();
//                         },
//                         icon: const Icon(
//                           Icons.call_end,
//                           color: redColor,
//                           size: 25,
//                         ).center(),
//                       ).center(),
//                     ),
//                     IconButton(
//                       onPressed: () {
//                         _toggleMute();
//                       },
//                       icon: Icon(
//                         muted ? Icons.mic_off : Icons.mic,
//                         size: 30,
//                         color: white,
//                       ),
//                     ).center(),
//                     IconButton(
//                       onPressed: () {
//                         _switchCamera();
//                       },
//                       icon: const Icon(
//                         Icons.switch_camera,
//                         size: 30,
//                         color: white,
//                       ),
//                     ).center(),
//                   ],
//                 ),
//               ))
//         ],
//       ),
//     );
//   }

//   // Function to toggle mute/unmute
//   void _toggleMute() {
//     if (muted) {
//       _engine.muteLocalAudioStream(false);
//     } else {
//       _engine.muteLocalAudioStream(true);
//     }
//     muted = !muted;
//     setState(() {});
//   }

//   // Function to switch camera
//   void _switchCamera() {
//     _engine.switchCamera();
//     isFront = !isFront;
//     setState(() {});
//   }

//   // Function to end the call
//   void _endCall() {
//     _dispose();
//     finish(context);
//   }

//   Widget _remoteVideo() {
//     if (_remoteUid != null) {
//       return AgoraVideoView(
//         controller: VideoViewController.remote(
//           rtcEngine: _engine,
//           canvas: VideoCanvas(uid: _remoteUid),
//           connection: const RtcConnection(channelId: channel),
//         ),
//       );
//     } else {
//       return Text(
//         'Please wait for the remote user to join',
//         textAlign: TextAlign.center,
//         style: primaryTextStyle(),
//       );
//     }
//   }
// }
