import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'unity_native_controller.dart';

/// Unity as Library ネイティブ Widget
/// Unity Framework を直接埋め込んでレンダリング
class UnityNativeWidget extends StatefulWidget {
  final void Function(UnityNativeController)? onUnityCreated;
  final void Function(String)? onUnityMessage;
  final void Function()? onUnityLoaded;
  final void Function(String)? onUnityError;
  final bool fullscreen;
  final bool autoStart;
  
  const UnityNativeWidget({
    super.key,
    this.onUnityCreated,
    this.onUnityMessage,
    this.onUnityLoaded,
    this.onUnityError,
    this.fullscreen = true,
    this.autoStart = true,
  });

  @override
  State<UnityNativeWidget> createState() => _UnityNativeWidgetState();
}

class _UnityNativeWidgetState extends State<UnityNativeWidget>
    with WidgetsBindingObserver {
  UnityNativeController? _controller;
  bool _isCreated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeUnity();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.destroyUnity();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null) return;
    
    switch (state) {
      case AppLifecycleState.paused:
        _controller!.pauseUnity();
        break;
      case AppLifecycleState.resumed:
        _controller!.resumeUnity();
        break;
      case AppLifecycleState.detached:
        _controller!.destroyUnity();
        break;
      default:
        break;
    }
  }

  Future<void> _initializeUnity() async {
    _controller = UnityNativeController();
    
    // イベントハンドラー設定
    _controller!.onUnityMessage = (message) {
      widget.onUnityMessage?.call(message);
    };
    
    _controller!.onUnityLoaded = () {
      widget.onUnityLoaded?.call();
    };
    
    _controller!.onUnityError = (error) {
      widget.onUnityError?.call(error);
    };
    
    // Unity Framework 初期化
    final success = await _controller!.initializeUnity();
    
    if (success) {
      setState(() {
        _isCreated = true;
      });
      
      widget.onUnityCreated?.call(_controller!);
      
      if (widget.autoStart) {
        await _controller!.startUnityScene();
      }
    } else {
      widget.onUnityError?.call('Failed to initialize Unity Framework');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCreated) {
      return ColoredBox(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFE94560),
          ),
        ),
      );
    }
    
    // Unity ネイティブビューを埋め込み
    return UiKitView(
      viewType: 'unity_native_view',
      layoutDirection: TextDirection.ltr,
      creationParams: <String, dynamic>{
        'fullscreen': widget.fullscreen,
        'metalEnabled': true,
        'neuralEngineEnabled': true,
        'targetFPS': 60,
      },
      creationParamsCodec: const StandardMessageCodec(),
      onPlatformViewCreated: (int id) {
        debugPrint('✅ Unity native view created with ID: $id');
      },
    );
  }
}