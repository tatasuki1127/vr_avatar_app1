# Unity Integration フォルダ

## 概要
Unity as Library との統合に関するファイルを配置します。

## ファイル構成
```
unity_integration/
├── unity_communication.dart    # Unity - Flutter 通信処理
├── unity_message_handler.dart  # Unity メッセージハンドラー
└── unity_commands.dart         # Unity コマンド定義
```

## Unity Framework統合手順

### 1. Unity プロジェクトからの出力
Unity側で以下を実行：
- BuildScript.cs の ExportUnityAsLibrary() を実行
- UnityFramework.framework が生成される

### 2. iOS プロジェクトへの統合
```bash
# iOS Runner.xcworkspaceを開く
open ios/Runner.xcworkspace

# UnityFramework.frameworkを追加
# Embed & Sign に設定
```

### 3. Flutter - Unity 通信
```dart
// Unity にメッセージ送信
_unityWidgetController.postMessage(
  'FlutterUnityBridge',
  'OnMessage',
  '{"type":"START_VR","value":""}',
);

// Unity からのメッセージ受信
void _onUnityMessage(dynamic message) {
  final data = message.split(':');
  final command = data[0];
  final value = data[1];
  
  switch (command) {
    case 'PHOTO_TAKEN':
      // 写真撮影完了
      break;
    case 'CHARACTER_CHANGED':
      // キャラクター切り替え完了
      break;
  }
}
```

## GPU最適化設定
- Metal API 対応
- Neural Engine 活用
- 60FPS 安定動作