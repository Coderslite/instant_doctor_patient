import 'package:package_info/package_info.dart';

Future<String> getAppVersion() async {
  PackageInfo packageInfo;

    packageInfo = await PackageInfo.fromPlatform();
      String version = packageInfo.version;
  return version;
 

}
