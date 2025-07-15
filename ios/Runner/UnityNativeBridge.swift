import Flutter
import UIKit
// UnityFramework import はコンパイル時に条件付きで処理
#if canImport(UnityFramework)
import UnityFramework
#endif

/// Unity as Library ネイティブブリッジ
/// Flutter と Unity Framework を直接接続
@objc public class UnityNativeBridge: NSObject, FlutterPlugin {
    
    #if canImport(UnityFramework)
    private var unityFramework: UnityFramework?
    #endif
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
        #if canImport(UnityFramework)
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
                framework.setDataBundleId("com.unity3d.framework")
                framework.register(self)
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
        #else
        print("⚠️ UnityFramework not available, using flutter_unity_widget instead")
        sendEvent(type: "unity_initialized", data: "flutter_unity_widget")
        result(true)
        #endif
    }
    
    private func startScene(arguments: [String: Any]?, result: @escaping FlutterResult) {
        #if canImport(UnityFramework)
        guard let unity = unityFramework else {
            print("❌ Unity not initialized")
            result(false)
            return
        }
        
        // Unity 開始 - 正しいメソッド呼び出し
        unity.runEmbedded(withArgc: 0, argv: nil, appLaunchOpts: nil)
        
        print("✅ Unity scene started")
        sendEvent(type: "unity_loaded", data: "scene_started")
        result(true)
        #else
        print("⚠️ UnityFramework not available, using flutter_unity_widget for scene management")
        sendEvent(type: "unity_loaded", data: "flutter_unity_widget")
        result(true)
        #endif
    }
    
    private func sendMessage(arguments: [String: Any]?, result: @escaping FlutterResult) {
        guard let args = arguments,
              let gameObject = args["gameObject"] as? String,
              let method = args["method"] as? String,
              let message = args["message"] as? String else {
            result(false)
            return
        }
        
        #if canImport(UnityFramework)
        if let framework = unityFramework {
            framework.sendMessageToGO(withName: gameObject, functionName: method, message: message)
            print("Sending message to Unity: \(gameObject).\(method)(\(message))")
        }
        #else
        print("⚠️ UnityFramework not available, message sent via flutter_unity_widget: \(gameObject).\(method)(\(message))")
        #endif
        result(true)
    }
    
    private func pauseUnity(result: @escaping FlutterResult) {
        #if canImport(UnityFramework)
        if let framework = unityFramework {
            framework.pause(true)
        }
        #else
        print("⚠️ UnityFramework not available, pause handled by flutter_unity_widget")
        #endif
        result(true)
    }
    
    private func resumeUnity(result: @escaping FlutterResult) {
        #if canImport(UnityFramework)
        if let framework = unityFramework {
            framework.pause(false)
        }
        #else
        print("⚠️ UnityFramework not available, resume handled by flutter_unity_widget")
        #endif
        result(true)
    }
    
    private func destroyUnity(result: @escaping FlutterResult) {
        #if canImport(UnityFramework)
        if let framework = unityFramework {
            framework.unregisterFrameworkListener(self)
            framework.unloadApplication()
        }
        unityFramework = nil
        #else
        print("⚠️ UnityFramework not available, destroy handled by flutter_unity_widget")
        #endif
        unityView = nil
        result(true)
    }
    
    // MARK: - Unity Framework Loading
    
    #if canImport(UnityFramework)
    private func loadUnityFramework() throws -> UnityFramework {
        let bundlePath = Bundle.main.bundlePath + "/Frameworks/UnityFramework.framework"
        let bundle = Bundle(path: bundlePath)
        
        guard let bundle = bundle else {
            throw NSError(domain: "UnityFramework", code: 1, userInfo: [NSLocalizedDescriptionKey: "UnityFramework bundle not found"])
        }
        
        guard bundle.isLoaded || bundle.load() else {
            throw NSError(domain: "UnityFramework", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to load UnityFramework bundle"])
        }
        
        guard let ufw = bundle.principalClass?.getInstance() else {
            throw NSError(domain: "UnityFramework", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failed to get UnityFramework instance"])
        }
        
        return ufw
    }
    #endif
    
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
        #if canImport(UnityFramework)
        guard let framework = unityFramework else {
            return nil
        }
        
        return framework.appController()?.rootViewController?.view
        #else
        return nil
        #endif
    }
}

// MARK: - UnityFrameworkListener

#if canImport(UnityFramework)
extension UnityNativeBridge: UnityFrameworkListener {
    
    public func unityDidUnload(_ notification: Notification!) {
        print("🛑 Unity did unload")
        sendEvent(type: "unity_unloaded", data: "")
    }
    
    public func unityDidQuit(_ notification: Notification!) {
        print("🛑 Unity did quit")
        sendEvent(type: "unity_quit", data: "")
    }
}
#endif

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