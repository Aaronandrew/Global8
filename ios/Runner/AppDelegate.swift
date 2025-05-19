import UIKit
import Flutter
import GoogleMaps  

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
      
    GMSServices.provideAPIKey("AIzaSyDVJq8Y5c3bMY9eFZ5KyjxLa4ZjY0hRmbM")
      
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
