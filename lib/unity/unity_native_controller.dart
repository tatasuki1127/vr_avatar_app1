import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// Unity as Library ネイティブ制御クラス
/// flutter_unity_widget の代替として Unity Framework を直接制御
class UnityNativeController {
  static const MethodChannel _channel = MethodChannel('unity_native_bridge');
  static const EventChannel _eventChannel = EventChannel('unity_native_events');
  
  // Unity 状態管理
  bool _isInitialized = false;
  bool _isUnityLoaded = false;
  void Function(String)? onUnityMessage;
  void Function()? onUnityLoaded;
  void Function(String)? onUnityError;
  
  // Unity Framework 初期化
  Future<bool> initializeUnity() async {
    if (_isInitialized) return true;
    
    try {
      debugPrint('🚀 Initializing Unity Framework...');
      
      final result = await _channel.invokeMethod('initializeUnity', {
        'metalEnabled': true,
        'neuralEngineEnabled': true,
        'targetFPS': 60,
        'renderMode': '4K',
      });
      
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
      
      final result = await _channel.invokeMethod('startScene', {
        'sceneName': 'VRScene',
        'vrMode': true,
        'aiTracking': true,
      });
      
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
    if (!_isUnityLoaded) {
      debugPrint('⚠️ Unity not loaded, message ignored: $message');
      return;
    }
    
    try {
      await _channel.invokeMethod('sendMessage', {
        'gameObject': gameObjectName,
        'method': methodName,
        'message': message,
      });
      
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
      await _channel.invokeMethod('pauseUnity');
      debugPrint('⏸️ Unity paused');
    } catch (e) {
      debugPrint('❌ Failed to pause Unity: $e');
    }
  }
  
  // Unity 再開
  Future<void> resumeUnity() async {
    try {
      await _channel.invokeMethod('resumeUnity');
      debugPrint('▶️ Unity resumed');
    } catch (e) {
      debugPrint('❌ Failed to resume Unity: $e');
    }
  }
  
  // Unity 終了
  Future<void> destroyUnity() async {
    try {
      await _channel.invokeMethod('destroyUnity');
      _isInitialized = false;
      _isUnityLoaded = false;
      debugPrint('🛑 Unity destroyed');
    } catch (e) {
      debugPrint('❌ Failed to destroy Unity: $e');
    }
  }
  
  // Unity からのイベント監視
  void _setupEventListener() {
    _eventChannel.receiveBroadcastStream().listen(
      (dynamic event) {
        if (event is Map) {
          final type = event['type'] as String?;
          final data = event['data'] as String?;
          
          switch (type) {
            case 'unity_loaded':
              _isUnityLoaded = true;
              onUnityLoaded?.call();
              break;
            case 'unity_message':
              onUnityMessage?.call(data ?? '');
              break;
            case 'unity_error':
              onUnityError?.call(data ?? 'Unknown Unity error');
              break;
            case 'photo_taken':
              onUnityMessage?.call('PHOTO_TAKEN:${data ?? ''}');
              break;
            case 'character_changed':
              onUnityMessage?.call('CHARACTER_CHANGED:${data ?? '0'}');
              break;
            case 'fps_update':
              onUnityMessage?.call('FPS_UPDATE:${data ?? '60'}');
              break;
            default:
              debugPrint('🔄 Unity event: $type -> $data');
          }
        }
      },
      onError: (dynamic error) {
        debugPrint('❌ Unity event stream error: $error');
        onUnityError?.call('Event stream error: $error');
      },
    );
  }
  
  // Unity 状態確認
  bool get isInitialized => _isInitialized;
  bool get isUnityLoaded => _isUnityLoaded;
}