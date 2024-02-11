import 'package:flutter_incoming_call/flutter_incoming_call.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/screens/chat/VideoCall.dart';

class IncomingCall {
  showCalling(String appointmentId) async {
    FlutterIncomingCall.configure(
        appName: 'instant doctor',
        duration: 30000,
        android: ConfigAndroid(
          vibration: true,
          ringtonePath: 'default',
          channelId: 'calls',
          channelName: 'Calls channel name',
          channelDescription: 'Calls channel description',
        ),
        ios: ConfigIOS(
          iconName: 'AppIcon40x40',
          ringtonePath: null,
          includesCallsInRecents: false,
          supportsVideo: true,
          maximumCallGroups: 2,
          maximumCallsPerCallGroup: 1,
        ));

    FlutterIncomingCall.onEvent.listen((event) {
      if (event is CallEvent) {
        // Android | IOS
        if (event.action == CallAction.accept) {
          Get.to(VideoCall(appointmentId: appointmentId));
        }
        if (event.action == CallAction.decline) {
          FlutterIncomingCall.endCall(appointmentId);
        }
      } else if (event is HoldEvent) {
        // IOS
      } else if (event is MuteEvent) {
        // IOS
      } else if (event is DmtfEvent) {
        // IOS
      } else if (event is AudioSessionEvent) {
        // IOS
      }
    });

    FlutterIncomingCall.displayIncomingCall(
        appointmentId, 'Incoming Call...', '', '', HandleType.generic, true);
  }
}
