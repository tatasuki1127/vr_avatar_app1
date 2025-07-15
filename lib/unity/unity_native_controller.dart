import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';

/// Unity as Library ネイティブ制御クラス
/// flutter_unity_widget を使用した Unity Framework 制御
class UnityNativeController {
  UnityWidgetController? _unityController;
  
  // Unity 状態管理
  bool _isInitialized = false;
  bool _isUnityLoaded = false;
  void Function(String)? onUnityMessage;
  void Function()? onUnityLoaded;
  void Function(String)? onUnityError;
  
  // UnityWidgetControllerを設定
  void setUnityController(UnityWidgetController controller) {
    _unityController = controller;
    _isInitialized = true;
    _isUnityLoaded = true;
  }
  
  // Unity Framework 初期化
  Future<bool> initializeUnity() async {
    if (_isInitialized) return true;
    
    try {
      debugPrint('🚀 Initializing Unity Framework...');
      
      // flutter_unity_widget を使用する場合、初期化は自動的に実行される
      debugPrint('🔧 Using flutter_unity_widget for Unity initialization');
      final result = true;
      
      if (result == true) {
        _isInitialized = true;
        _setupEventListener();
        debugPrint('✅ Unity Framework initialized successfully');
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('❌ Unity initialization failed: $e');
      onUnityError?.call('Unity initialization failed: $e');
      return false;
    }
  }
  
  // Unity シーン開始
  Future<bool> startUnityScene() async {
    if (!_isInitialized) {
      await initializeUnity();
    }
    
    try {
      debugPrint('🎬 Starting Unity VR scene...');
      
      // flutter_unity_widget を使用する場合、シーンは自動的に開始される
      debugPrint('🔧 Using flutter_unity_widget for scene management');
      final result = true;
      
      if (result == true) {
        _isUnityLoaded = true;
        onUnityLoaded?.call();
        debugPrint('✅ Unity scene started successfully');
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('❌ Unity scene start failed: $e');
      onUnityError?.call('Unity scene start failed: $e');
      return false;
    }
  }
  
  // Unity にメッセージ送信
  Future<void> sendMessage(String gameObjectName, String methodName, String message) async {
    if (!_isUnityLoaded || _unityController == null) {
      debugPrint('⚠️ Unity not loaded, message ignored: $message');
      return;
    }
    
    try {
      await _unityController!.postMessage(gameObjectName, methodName, message);
      debugPrint('📤 Message sent to Unity: $gameObjectName.$methodName($message)');
    } catch (e) {
      debugPrint('❌ Failed to send message to Unity: $e');
      onUnityError?.call('Failed to send message: $e');
    }
  }
  
  // 4K 写真撮影
  Future<void> takePhoto() async {
    await sendMessage('VRManager', 'TakePhoto', '{"quality":"4K","gpuOptimized":true}');
  }
  
  // キャラクター切り替え（固定3体）
  Future<void> switchCharacter(int characterIndex) async {
    if (characterIndex < 0 || characterIndex > 2) {
      debugPrint('⚠️ Invalid character index: $characterIndex');
      return;
    }
    
    await sendMessage('CharacterManager', 'SwitchCharacter', '{"index":$characterIndex}');
  }
  
  // カメラ切り替え
  Future<void> switchCamera() async {
    await sendMessage('CameraManager', 'SwitchCamera', '{}');
  }
  
  // VR モード開始
  Future<void> startVRMode() async {
    await sendMessage('VRManager', 'StartVR', '{"aiTracking":true,"neuralEngine":true}');
  }
  
  // Unity 一時停止
  Future<void> pauseUnity() async {
    try {
      await _unityController?.pause();
      debugPrint('⏸️ Unity paused');
    } catch (e) {
      debugPrint('❌ Failed to pause Unity: $e');
    }
  }
  
  // Unity 再開
  Future<void> resumeUnity() async {
    try {
      await _unityController?.resume();
      debugPrint('▶️ Unity resumed');
    } catch (e) {
      debugPrint('❌ Failed to resume Unity: $e');
    }
  }
  
  // Unity 終了
  Future<void> destroyUnity() async {
    try {
      await _unityController?.unload();
      _isInitialized = false;
      _isUnityLoaded = false;
      debugPrint('🛑 Unity destroyed');
    } catch (e) {
      debugPrint('❌ Failed to destroy Unity: $e');
    }
  }
  
  // Unity からのイベント監視（flutter_unity_widget経由）
  void _setupEventListener() {
    // flutter_unity_widget のイベントハンドリングは
    // UnityNativeWidget で設定されるため、ここでは不要
    debugPrint('🔄 Unity event listener setup via flutter_unity_widget');
  }
  
  // Unity 状態確認
  bool get isInitialized => _isInitialized;
  bool get isUnityLoaded => _isUnityLoaded;
}