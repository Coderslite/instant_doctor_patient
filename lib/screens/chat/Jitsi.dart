// import 'package:flutter/material.dart';

// import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
// import 'package:nb_utils/nb_utils.dart';

// class JitsiScreen extends StatefulWidget {
//   const JitsiScreen({super.key});

//   @override
//   State<JitsiScreen> createState() => _JitsiScreenState();
// }

// class _JitsiScreenState extends State<JitsiScreen> {
//   bool audioMuted = true;
//   bool videoMuted = true;
//   bool screenShareOn = false;
//   List<String> participants = [];
//   final _jitsiMeetPlugin = JitsiMeet();

//   join() async {
//     var options = JitsiMeetConferenceOptions(
//       serverURL: "https://meet.jit.si",
//       room: "metting-abraham-great-join",
//       configOverrides: {
//         "startWithAudioMuted": true,
//         "startWithVideoMuted": true,
//       },
//       featureFlags: {
//         // FeatureFlags.addPeopleEnabled: false,
//         // FeatureFlags.welcomePageEnabled: false,
//         // FeatureFlags.preJoinPageEnabled: false,
//         // FeatureFlags.unsafeRoomWarningEnabled: false,
//         // FeatureFlags.resolution: FeatureFlagVideoResolutions.resolution480p,
//         // FeatureFlags.audioFocusDisabled: false,
//         // FeatureFlags.audioMuteButtonEnabled: false,
//         // FeatureFlags.audioOnlyButtonEnabled: false,
//         // FeatureFlags.calenderEnabled: false,
//         // FeatureFlags.callIntegrationEnabled: false,
//         // FeatureFlags.carModeEnabled: false,
//         // FeatureFlags.closeCaptionsEnabled: false,
//         // FeatureFlags.conferenceTimerEnabled: false,
//         // FeatureFlags.chatEnabled: false,
//         // FeatureFlags.filmstripEnabled: false,
//         // FeatureFlags.fullScreenEnabled: false,
//         // FeatureFlags.helpButtonEnabled: false,
//         // FeatureFlags.inviteEnabled: false,
//         // FeatureFlags.androidScreenSharingEnabled: false,
//         // FeatureFlags.speakerStatsEnabled: false,
//         // FeatureFlags.kickOutEnabled: false,
//         // FeatureFlags.liveStreamingEnabled: false,
//         // FeatureFlags.lobbyModeEnabled: false,
//         // FeatureFlags.meetingNameEnabled: false,
//         // FeatureFlags.meetingPasswordEnabled: false,
//         // FeatureFlags.notificationEnabled: false,
//         // FeatureFlags.overflowMenuEnabled: false,
//         // FeatureFlags.pipEnabled: false,
//         // FeatureFlags.pipWhileScreenSharingEnabled: false,
//         // FeatureFlags.preJoinPageHideDisplayName: false,
//         // FeatureFlags.raiseHandEnabled: false,
//         // FeatureFlags.reactionsEnabled: false,
//         // FeatureFlags.recordingEnabled: false,
//         // FeatureFlags.replaceParticipant: false,
//         // FeatureFlags.securityOptionEnabled: false,
//         // FeatureFlags.serverUrlChangeEnabled: false,
//         // FeatureFlags.settingsEnabled: false,
//         // FeatureFlags.tileViewEnabled: false,
//         // FeatureFlags.videoMuteEnabled: false,
//         // FeatureFlags.videoShareEnabled: false,
//         // FeatureFlags.toolboxEnabled: false,
//         // FeatureFlags.iosRecordingEnabled: false,
//         // FeatureFlags.iosScreenSharingEnabled: false,
//         // FeatureFlags.toolboxAlwaysVisible: false,
//       },
//       userInfo: JitsiMeetUserInfo(
//           displayName: "Abraham Great",
//           email: "abrahamgreat@mailinator.com",
//           avatar:
//               "https://avatars.githubusercontent.com/u/57035818?s=400&u=02572f10fe61bca6fc20426548f3920d53f79693&v=4"),
//     );

//     var listener = JitsiMeetEventListener(
//       conferenceJoined: (url) {
//         debugPrint("conferenceJoined: url: $url");
//       },
//       conferenceTerminated: (url, error) {
//         debugPrint("conferenceTerminated: url: $url, error: $error");
//       },
//       conferenceWillJoin: (url) {
//         debugPrint("conferenceWillJoin: url: $url");
//       },
//       participantJoined: (email, name, role, participantId) {
//         debugPrint(
//           "participantJoined: email: $email, name: $name, role: $role, "
//           "participantId: $participantId",
//         );
//         participants.add(participantId!);
//       },
//       participantLeft: (participantId) {
//         debugPrint("participantLeft: participantId: $participantId");
//       },
//       audioMutedChanged: (muted) {
//         debugPrint("audioMutedChanged: isMuted: $muted");
//       },
//       videoMutedChanged: (muted) {
//         debugPrint("videoMutedChanged: isMuted: $muted");
//       },
//       endpointTextMessageReceived: (senderId, message) {
//         debugPrint(
//             "endpointTextMessageReceived: senderId: $senderId, message: $message");
//       },
//       screenShareToggled: (participantId, sharing) {
//         debugPrint(
//           "screenShareToggled: participantId: $participantId, "
//           "isSharing: $sharing",
//         );
//       },
//       chatMessageReceived: (senderId, message, isPrivate, timestamp) {
//         debugPrint(
//           "chatMessageReceived: senderId: $senderId, message: $message, "
//           "isPrivate: $isPrivate, timestamp: $timestamp",
//         );
//       },
//       chatToggled: (isOpen) => debugPrint("chatToggled: isOpen: $isOpen"),
//       participantsInfoRetrieved: (participantsInfo) {
//         debugPrint(
//             "participantsInfoRetrieved: participantsInfo: $participantsInfo, ");
//       },
//       readyToClose: () {
//         debugPrint("readyToClose");
//       },
//     );
//     await _jitsiMeetPlugin.join(options, listener);
//   }

//   hangUp() async {
//     await _jitsiMeetPlugin.hangUp();
//     finish(context);
//   }

//   setAudioMuted(bool? muted) async {
//     var a = await _jitsiMeetPlugin.setAudioMuted(muted!);
//     debugPrint("$a");
//     setState(() {
//       audioMuted = muted;
//     });
//   }

//   setVideoMuted(bool? muted) async {
//     var a = await _jitsiMeetPlugin.setVideoMuted(muted!);
//     debugPrint("$a");
//     setState(() {
//       videoMuted = muted;
//     });
//   }

//   sendEndpointTextMessage() async {
//     var a = await _jitsiMeetPlugin.sendEndpointTextMessage(message: "HEY");
//     debugPrint("$a");

//     for (var p in participants) {
//       var b =
//           await _jitsiMeetPlugin.sendEndpointTextMessage(to: p, message: "HEY");
//       debugPrint("$b");
//     }
//   }

//   toggleScreenShare(bool? enabled) async {
//     await _jitsiMeetPlugin.toggleScreenShare(enabled!);

//     setState(() {
//       screenShareOn = enabled;
//     });
//   }

//   openChat() async {
//     await _jitsiMeetPlugin.openChat();
//   }

//   sendChatMessage() async {
//     var a = await _jitsiMeetPlugin.sendChatMessage(message: "HEY1");
//     debugPrint("$a");

//     for (var p in participants) {
//       a = await _jitsiMeetPlugin.sendChatMessage(to: p, message: "HEY2");
//       debugPrint("$a");
//     }
//   }

//   closeChat() async {
//     await _jitsiMeetPlugin.closeChat();
//   }

//   retrieveParticipantsInfo() async {
//     var a = await _jitsiMeetPlugin.retrieveParticipantsInfo();
//     debugPrint("$a");
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//           appBar: AppBar(
//             title: const Text('Plugin example app'),
//           ),
//           body: Center(
//             child: Column(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: <Widget>[
//                   TextButton(
//                     onPressed: join,
//                     child: const Text("Join"),
//                   ),
//                   TextButton(onPressed: hangUp, child: const Text("Hang Up")),
//                   Row(children: [
//                     const Text("Set Audio Muted"),
//                     Checkbox(
//                       value: audioMuted,
//                       onChanged: setAudioMuted,
//                     ),
//                   ]),
//                   Row(children: [
//                     const Text("Set Video Muted"),
//                     Checkbox(
//                       value: videoMuted,
//                       onChanged: setVideoMuted,
//                     ),
//                   ]),
//                   TextButton(
//                       onPressed: sendEndpointTextMessage,
//                       child: const Text("Send Hey Endpoint Message To All")),
//                   Row(children: [
//                     const Text("Toggle Screen Share"),
//                     Checkbox(
//                       value: screenShareOn,
//                       onChanged: toggleScreenShare,
//                     ),
//                   ]),
//                   TextButton(
//                       onPressed: openChat, child: const Text("Open Chat")),
//                   TextButton(
//                       onPressed: sendChatMessage,
//                       child: const Text("Send Chat Message to All")),
//                   TextButton(
//                       onPressed: closeChat, child: const Text("Close Chat")),
//                   TextButton(
//                       onPressed: retrieveParticipantsInfo,
//                       child: const Text("Retrieve Participants Info")),
//                 ]),
//           )),
//     );
//   }
// }
