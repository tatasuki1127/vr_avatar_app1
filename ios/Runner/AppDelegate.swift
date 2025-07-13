import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Unity as Library ネイティブブリッジ登録
    guard let controller = window?.rootViewController as? FlutterViewController else {
      fatalError("rootViewController is not type FlutterViewController")
    }
    
    let registrar = self.registrar(forPlugin: "UnityNativeBridge")!
    UnityNativeBridge.register(with: registrar)
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
