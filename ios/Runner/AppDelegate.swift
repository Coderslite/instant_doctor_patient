import Flutter
import UIKit
import GoogleMaps
import Firebase
import FirebaseMessaging
@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    GMSServices.provideAPIKey("AIzaSyD8nW2BRd9ssOWqimiF-dOS4IeaXkKoBCI")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  override func application(_ application: UIApplication,
  didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

   Messaging.messaging().apnsToken = deviceToken
   print("Token: \(deviceToken)")
   super.application(application,
   didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
 }
}
