import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      // Thêm dòng này để đảm bảo window có root view controller
      self.window = UIWindow(frame: UIScreen.main.bounds)
      let controller = FlutterViewController.init()
      self.window?.rootViewController = controller
      self.window?.makeKeyAndVisible()

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
