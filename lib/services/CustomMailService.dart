import 'package:http/http.dart' as http;
import 'package:instant_doctor/constant/constants.dart';
import 'package:instant_doctor/services/GetUserId.dart';

Future<void> sendCustomMail({required String activityName}) async {
  await http.post(Uri.parse("$FIREBASE_URL/mail/activity_notify"), body: {
    "userId": userController.userId.value,
    "activityName": activityName,
  });
}
