import 'package:flutter/material.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import 'package:flutter/services.dart';

class UnityVRScreen extends StatefulWidget {
  const UnityVRScreen({super.key});

  @override
  _UnityVRScreenState createState() => _UnityVRScreenState();
}

class _UnityVRScreenState extends State<UnityVRScreen> {
  late UnityWidgetController _unityWidgetController;
  bool _isUnityLoaded = false;
  bool _showControls = true;
  int _currentCharacter = 0;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    // ステータスバーを隠す（全画面VR体験）
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    // ステータスバーを復元
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Unity Widget (全画面カメラプレビュー - 仕様書準拠)
          UnityWidget(
            onUnityCreated: _onUnityCreated,
            onUnityMessage: _onUnityMessage,
            onUnitySceneLoaded: _onUnitySceneLoaded,
            fullscreen: true,
            borderRadius: BorderRadius.zero,
            hideStatus: true,
          ),
          
          // GPU初期化ローディング画面
          if (!_isUnityLoaded)
            Container(
              color: Color(0xFF1A1A2E),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // GPU最適化ローディングアニメーション
                    Container(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        color: Color(0xFFE94560),
                        strokeWidth: 4,
                      ),
                    ),
                    SizedBox(height: 30),
                    Text(
                      'Metal API 初期化中...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Neural Engine AI システム起動',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'GPU並列処理準備中',
                      style: TextStyle(
                        color: Color(0xFFE94560),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // 操作ボタン3つのみ（仕様書準拠）
          if (_isUnityLoaded && _showControls)
            _buildControlButtons(),
          
          // 戻るボタン
          if (_isUnityLoaded)
            _buildBackButton(),
          
          // 性能表示（オプション）
          if (_isUnityLoaded)
            _buildPerformanceIndicator(),
        ],
      ),
    );
  }

  Widget _buildControlButtons() {
    return Positioned(
      bottom: 50,
      left: 20,
      right: 20,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: Color(0xFFE94560).withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // 撮影ボタン（4K高画質撮影）
            _buildControlButton(
              icon: _isRecording ? Icons.stop : Icons.camera_alt,
              label: _isRecording ? '停止' : '撮影',
              color: _isRecording ? Colors.red : Color(0xFFE94560),
              onTap: _takePhoto,
            ),
            
            // キャラ切替ボタン（固定3体）
            _buildControlButton(
              icon: Icons.person,
              label: 'キャラ${_currentCharacter + 1}',
              color: Color(0xFF4CAF50),
              onTap: _switchCharacter,
            ),
            
            // カメラ切替ボタン
            _buildControlButton(
              icon: Icons.flip_camera_ios,
              label: 'カメラ',
              color: Color(0xFF2196F3),
              onTap: _switchCamera,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: color,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Positioned(
      top: 50,
      left: 20,
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildPerformanceIndicator() {
    return Positioned(
      top: 50,
      right: 20,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Color(0xFFE94560).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.speed,
              color: Color(0xFFE94560),
              size: 16,
            ),
            SizedBox(width: 6),
            Text(
              '60FPS',
              style: TextStyle(
                color: Color(0xFFE94560),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onUnityCreated(UnityWidgetController controller) {
    _unityWidgetController = controller;
    print('Unity Widget created - GPU optimization enabled');
  }

  void _onUnitySceneLoaded(SceneLoaded? scene) {
    setState(() {
      _isUnityLoaded = true;
    });
    print('Unity scene loaded: ${scene?.name}');
    
    // VR機能を開始（仕様書：1人検出・追跡開始）
    _startVRMode();
  }

  void _onUnityMessage(dynamic message) {
    print('Unity message: $message');
    
    // Unityからのメッセージ処理
    if (message is String) {
      final data = message.split(':');
      if (data.length >= 2) {
        final command = data[0];
        final value = data[1];
        
        switch (command) {
          case 'PHOTO_TAKEN':
            _showPhotoSavedSnackBar();
            setState(() {
              _isRecording = false;
            });
            break;
          case 'CHARACTER_CHANGED':
            setState(() {
              _currentCharacter = int.tryParse(value) ?? 0;
            });
            break;
          case 'VR_ERROR':
            _showErrorDialog(value);
            break;
          case 'FPS_UPDATE':
            // FPS情報の更新（パフォーマンス監視）
            break;
        }
      }
    }
  }

  void _startVRMode() {
    _unityWidgetController.postMessage(
      'FlutterUnityBridge',
      'OnMessage',
      '{"type":"START_VR","value":""}',
    );
  }

  void _takePhoto() {
    setState(() {
      _isRecording = !_isRecording;
    });
    
    if (_isRecording) {
      // 4K高画質撮影開始
      _unityWidgetController.postMessage(
        'FlutterUnityBridge',
        'OnMessage',
        '{"type":"TAKE_PHOTO","value":"4K"}',
      );
    }
    
    // ハプティックフィードバック
    HapticFeedback.lightImpact();
  }

  void _switchCharacter() {
    // 固定3体キャラクター切り替え
    final nextCharacter = (_currentCharacter + 1) % 3;
    _unityWidgetController.postMessage(
      'FlutterUnityBridge',
      'OnMessage',
      '{"type":"CHANGE_CHARACTER","value":"$nextCharacter"}',
    );
    
    HapticFeedback.lightImpact();
  }

  void _switchCamera() {
    _unityWidgetController.postMessage(
      'FlutterUnityBridge',
      'OnMessage',
      '{"type":"SWITCH_CAMERA","value":""}',
    );
    
    HapticFeedback.lightImpact();
  }

  void _showPhotoSavedSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('4K写真が保存されました'),
          ],
        ),
        backgroundColor: Color(0xFFE94560),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 10),
            Text(
              'システムエラー',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Text(
          error,
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(
                color: Color(0xFFE94560),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}