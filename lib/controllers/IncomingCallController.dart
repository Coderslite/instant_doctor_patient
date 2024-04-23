import 'package:flutter_incoming_call/flutter_incoming_call.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/main.dart';
import 'package:instant_doctor/screens/chat/VideoCall.dart';

import '../screens/home/Root.dart';

class IncomingCall {
  showCalling(String appointmentId) async {
    var appointment =
        await appointmentService.getAppointment(appointmentId: appointmentId);
    var docId = appointment.doctorId;
    var doctor = await userService.getProfileById(userId: docId!);
    FlutterIncomingCall.configure(
        appName: 'instant doctor',
        duration: 30000,
        android: ConfigAndroid(
          vibration: true,
          channelId: 'calls',
          channelName: 'Calls channel name',
          channelDescription: 'Calls channel description',
        ),
        ios: ConfigIOS(
          iconName: 'AppIcon40x40',
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
          Get.off(const Root());
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
        "${doctor.id}",
        'Incoming Call from ${doctor.firstName}  ${doctor.lastName}...',
        doctor.photoUrl ??
            "https://www.pngarts.com/files/5/Avatar-Face-Transparent.png",
        '',
        HandleType.generic,
        true);
  }
}
