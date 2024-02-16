// import 'package:get/get.dart';
// import 'package:instant_doctor/services/GetUserId.dart';
// import 'package:nb_utils/nb_utils.dart';
// import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

// import '../main.dart';

// class ZegocloudController extends GetxController {
//   ZegoUIKitSignalingPlugin signalingPlugin = ZegoUIKitSignalingPlugin();
//   init() {
//     signalingPlugin.init(appID: settingsController.appId.validate());
//     // Set up listeners for incoming calls
//   }

// handleSendInvite(){
//   //  Send a call invitation.
// List<String> invitees = []; // The list of the callee. 
// invitees.add('1234'); // ID of the callee.
// ZIMCallInviteConfig config = ZIMCallInviteConfig();
// config.timeout = 200; //  The timeout duration for the call invitation. Time range: 1-600 seconds. 

// // (Optional) Fill in when it is necessary to send a call invitation to an offline user.
// ZIMPushConfig pushConfig = ZIMPushConfig();
// pushConfig.title = "your title";
// pushConfig.content = "your content";
// pushConfig.payload = "your payload";
// config.pushConfig = pushConfig;

// ZIM
//     .getInstance()!
//     .callInvite(invitees, config)
//     .then((value) {})
//     .catchError((onError) {});

// // Callback for the callee to receive the call invitation.
// ZIM.onCallInvitationReceived = (info, callID) {

// };
// }


//   handleSendInvite() {
//   /** Send call invitations to offline users */
// var invitees = ['xxxx'];  // List of invitees' IDs
// var pushConfig = {
//     title: 'push title'
//     content: 'push content',
//     payload: 'push payload'
// };

// var config = { 
//     timeout: 200, // Timeout for the invitation in seconds, range: 1-600
//     extendedData: 'your call invite extendedData',
//     pushConfig,
// };
// zim.callInvite(invitees, config)
//     .then(function({ callID, timeout, errorInvitees }){
//         // Operation succeeded
//         // The callID here is generated internally by the SDK to uniquely identify a call invitation. It will be used when the initiator cancels the call or the invitee accepts/rejects the call.
//     })
//     .catch(function(err){
//         // Operation failed
//     })
//   }
// }
