import 'package:instant_doctor/main.dart';
import 'package:instant_doctor/models/SettingModel.dart';

class SettingService {
  var settingCol = db.collection("Settings");

  Future<SettingModel> getSettings() async {
    var res = await settingCol.get();
    return SettingModel.fromJson(res.docs.first.data());
  }
}
