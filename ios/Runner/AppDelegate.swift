Phạm Minh Tân
import Flutter
import UIKit
import flutter_local_notifications

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

      // Thêm dòng này để đảm bảo FlutterLocalNotificationsPlugin hoạt động
      FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { registry in
        GeneratedPluginRegistrant.register(with: registry)
      }
      GeneratedPluginRegistrant.register(with: self)

      if #available(iOS 10.0, *) {
        UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
      }

    // GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}