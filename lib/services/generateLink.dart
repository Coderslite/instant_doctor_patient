// import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
// import 'package:instant_doctor/services/GetUserId.dart';

// FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;

// Future<String> generateShortLink({required String title}) async {
//   final dynamicLinkParams = DynamicLinkParameters(
//     link: Uri.parse(
//         "https://instantdoctor.page.link/refer?userId=${userController.tag.value}"),
//     uriPrefix: "https://instantdoctor.page.link",
//     androidParameters:
//         const AndroidParameters(packageName: "com.instantdoctor"),
//     iosParameters: const IOSParameters(bundleId: "com.instantdoctor.ios"),
//     socialMetaTagParameters: SocialMetaTagParameters(
//       title: "Get Excellent Medical Care",
//       imageUrl: Uri.parse(
//           "https://parceldeliverylogistics.com/instant_assets/logo1.png"),
//       description: title,
//     ),
//   );

//   final dynamicLink = await dynamicLinks.buildShortLink(dynamicLinkParams);
//   return dynamicLink.shortUrl.toString();
// }
