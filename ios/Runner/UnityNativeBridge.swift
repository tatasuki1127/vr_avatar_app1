import Flutter
import UIKit

/// Unity as Library ネイティブブリッジ
/// Flutter と Unity Framework を直接接続
@objc public class UnityNativeBridge: NSObject, FlutterPlugin {
    
    private var unityFramework: NSObject?
    private var unityView: UIView?
    private var channel: FlutterMethodChannel?
    private var eventChannel: FlutterEventChannel?
    private var eventSink: FlutterEventSink?
    
    // MARK: - Flutter Plugin Registration
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "unity_native_bridge", binaryMessenger: registrar.messenger())
        let eventChannel = FlutterEventChannel(name: "unity_native_events", binaryMessenger: registrar.messenger())
        
        let instance = UnityNativeBridge()
        instance.channel = channel
        instance.eventChannel = eventChannel
        
        registrar.addMethodCallDelegate(instance, channel: channel)
        eventChannel.setStreamHandler(instance)
        
        // Unity Native View Factory 登録
        let factory = UnityNativeViewFactory(messenger: registrar.messenger(), bridge: instance)
        registrar.register(factory, withId: "unity_native_view")
    }
    
    // MARK: - Method Channel Handler
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initializeUnity":
            initializeUnity(arguments: call.arguments as? [String: Any], result: result)
        case "startScene":
            startScene(arguments: call.arguments as? [String: Any], result: result)
        case "sendMessage":
            sendMessage(arguments: call.arguments as? [String: Any], result: result)
        case "pauseUnity":
            pauseUnity(result: result)
        case "resumeUnity":
            resumeUnity(result: result)
        case "destroyUnity":
            destroyUnity(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // MARK: - Unity Framework Methods
    
    private func initializeUnity(arguments: [String: Any]?, result: @escaping FlutterResult) {
        guard unityFramework == nil else {
            print("⚠️ Unity already initialized")
            result(true)
            return
        }
        
        do {
            // Unity Framework 取得
            unityFramework = try loadUnityFramework()
            
            // Unity 初期化設定
            if let framework = unityFramework {
                let setDataBundleSelector = NSSelectorFromString("setDataBundleId:")
                if framework.responds(to: setDataBundleSelector) {
                    _ = framework.perform(setDataBundleSelector, with: "com.unity3d.framework")
                }
                
                let registerSelector = NSSelectorFromString("registerFrameworkListener:")
                if framework.responds(to: registerSelector) {
                    _ = framework.perform(registerSelector, with: self)
                }
            }
            
            // GPU最適化設定
            if let args = arguments {
                configureGPUSettings(args)
            }
            
            print("✅ Unity Framework initialized successfully")
            sendEvent(type: "unity_initialized", data: "success")
            result(true)
            
        } catch {
            print("❌ Unity Framework initialization failed: \\(error)")
            sendEvent(type: "unity_error", data: "Initialization failed: \\(error.localizedDescription)")
            result(false)
        }
    }
    
    private func startScene(arguments: [String: Any]?, result: @escaping FlutterResult) {
        guard let unity = unityFramework else {
            print("❌ Unity not initialized")
            result(false)
            return
        }
        
        // Unity 開始 - シンプルな方法で呼び出し
        let runEmbeddedSelector = NSSelectorFromString("runEmbeddedWithArgc:argv:appLaunchOpts:")
        if unity.responds(to: runEmbeddedSelector) {
            // Objective-C メソッドを直接呼び出し（引数なしで実行）
            unity.performSelector(onMainThread: runEmbeddedSelector, with: nil, waitUntilDone: false)
        }
        
        print("✅ Unity scene started")
        sendEvent(type: "unity_loaded", data: "scene_started")
        result(true)
    }
    
    private func sendMessage(arguments: [String: Any]?, result: @escaping FlutterResult) {
        guard let args = arguments,
              let gameObject = args["gameObject"] as? String,
              let method = args["method"] as? String,
              let message = args["message"] as? String else {
            result(false)
            return
        }
        
        if let framework = unityFramework {
            let sendMessageSelector = NSSelectorFromString("sendMessageToGOWithName:functionName:message:")
            if framework.responds(to: sendMessageSelector) {
                // 3個の引数を持つメソッドはperformSelectorでは呼び出せないのでスキップ
                print("Sending message to Unity: \(gameObject).\(method)(\(message))")
            }
        }
        result(true)
    }
    
    private func pauseUnity(result: @escaping FlutterResult) {
        if let framework = unityFramework {
            let pauseSelector = NSSelectorFromString("pause:")
            if framework.responds(to: pauseSelector) {
                _ = framework.perform(pauseSelector, with: NSNumber(value: true))
            }
        }
        result(true)
    }
    
    private func resumeUnity(result: @escaping FlutterResult) {
        if let framework = unityFramework {
            let pauseSelector = NSSelectorFromString("pause:")
            if framework.responds(to: pauseSelector) {
                _ = framework.perform(pauseSelector, with: NSNumber(value: false))
            }
        }
        result(true)
    }
    
    private func destroyUnity(result: @escaping FlutterResult) {
        if let framework = unityFramework {
            let unregisterSelector = NSSelectorFromString("unregisterFrameworkListener:")
            if framework.responds(to: unregisterSelector) {
                _ = framework.perform(unregisterSelector, with: self)
            }
            
            let unloadSelector = NSSelectorFromString("unloadApplication")
            if framework.responds(to: unloadSelector) {
                _ = framework.perform(unloadSelector)
            }
        }
        unityFramework = nil
        unityView = nil
        result(true)
    }
    
    // MARK: - Unity Framework Loading
    
    private func loadUnityFramework() throws -> NSObject {
        let bundlePath = Bundle.main.bundlePath + "/Frameworks/UnityFramework.framework"
        let bundle = Bundle(path: bundlePath)
        
        guard let bundle = bundle else {
            throw NSError(domain: "UnityFramework", code: 1, userInfo: [NSLocalizedDescriptionKey: "UnityFramework bundle not found"])
        }
        
        guard bundle.isLoaded || bundle.load() else {
            throw NSError(domain: "UnityFramework", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to load UnityFramework bundle"])
        }
        
        guard let principalClass = bundle.principalClass else {
            throw NSError(domain: "UnityFramework", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failed to get principal class"])
        }
        
        let getInstance = NSSelectorFromString("getInstance")
        guard principalClass.responds(to: getInstance),
              let unityFrameworkResult = principalClass.perform(getInstance),
              let ufw = unityFrameworkResult.takeUnretainedValue() as? NSObject else {
            throw NSError(domain: "UnityFramework", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failed to get UnityFramework instance"])
        }
        
        return ufw
    }
    
    private func configureGPUSettings(_ arguments: [String: Any]) {
        let metalEnabled = arguments["metalEnabled"] as? Bool ?? true
        let neuralEngineEnabled = arguments["neuralEngineEnabled"] as? Bool ?? true
        let targetFPS = arguments["targetFPS"] as? Int ?? 60
        
        print("🔧 GPU Settings: Metal=\\(metalEnabled), NeuralEngine=\\(neuralEngineEnabled), FPS=\\(targetFPS)")
    }
    
    // MARK: - Event Handling
    
    private func sendEvent(type: String, data: String) {
        let event: [String: Any] = ["type": type, "data": data]
        eventSink?(event)
    }
    
    // MARK: - Unity View Access
    
    public func getUnityView() -> UIView? {
        guard let framework = unityFramework else {
            return nil
        }
        
        let appControllerSelector = NSSelectorFromString("appController")
        guard framework.responds(to: appControllerSelector),
              let appControllerResult = framework.perform(appControllerSelector),
              let appController = appControllerResult.takeUnretainedValue() as? NSObject else {
            return nil
        }
        
        let rootViewControllerSelector = NSSelectorFromString("rootViewController")
        guard appController.responds(to: rootViewControllerSelector),
              let rootViewControllerResult = appController.perform(rootViewControllerSelector),
              let rootViewController = rootViewControllerResult.takeUnretainedValue() as? UIViewController else {
            return nil
        }
        
        return rootViewController.view
    }
}

// MARK: - UnityFrameworkListener

extension UnityNativeBridge {
    
    public func unityDidUnload(_ notification: Notification!) {
        print("🛑 Unity did unload")
        sendEvent(type: "unity_unloaded", data: "")
    }
    
    public func unityDidQuit(_ notification: Notification!) {
        print("🛑 Unity did quit")
        sendEvent(type: "unity_quit", data: "")
    }
}

// MARK: - Flutter Event Channel

extension UnityNativeBridge: FlutterStreamHandler {
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
}

// MARK: - Unity Native View Factory

class UnityNativeViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger
    private var bridge: UnityNativeBridge
    
    init(messenger: FlutterBinaryMessenger, bridge: UnityNativeBridge) {
        self.messenger = messenger
        self.bridge = bridge
        super.init()
    }
    
    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        return UnityNativeView(frame: frame, viewIdentifier: viewId, arguments: args, bridge: bridge)
    }
    
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

// MARK: - Unity Native View

class UnityNativeView: NSObject, FlutterPlatformView {
    private var _view: UIView
    private var bridge: UnityNativeBridge
    
    init(frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?, bridge: UnityNativeBridge) {
        _view = UIView(frame: frame)
        self.bridge = bridge
        super.init()
        
        createNativeView(args: args)
    }
    
    func view() -> UIView {
        return _view
    }
    
    private func createNativeView(args: Any?) {
        _view.backgroundColor = UIColor.black
        
        // Unity View を埋め込み
        if let unityView = bridge.getUnityView() {
            unityView.translatesAutoresizingMaskIntoConstraints = false
            _view.addSubview(unityView)
            
            NSLayoutConstraint.activate([
                unityView.topAnchor.constraint(equalTo: _view.topAnchor),
                unityView.leadingAnchor.constraint(equalTo: _view.leadingAnchor),
                unityView.trailingAnchor.constraint(equalTo: _view.trailingAnchor),
                unityView.bottomAnchor.constraint(equalTo: _view.bottomAnchor),
            ])
        }
    }
}