# Windows Android Studio - iOS問題確認方法 🔍

## 🎯 **現状の制限**
- **Windows環境**: iOS実機デバッグ不可
- **Android Studio**: iOS Simulator使用不可
- **Flutter**: iOS固有エラーはビルド時のみ判明

## ✅ **Windows で確認可能な問題点**

### 1. **Flutter プロジェクト構文チェック**
```bash
# Android Studio Terminal で実行
cd C:\Users\nndds\StudioProjects\vr_avatar_app

# Dart構文・依存関係チェック
flutter doctor -v
flutter pub get
flutter analyze
```

### 2. **iOS設定ファイル検証**
```bash
# pubspec.yaml 依存関係確認
flutter pub deps

# iOS設定の基本検証
flutter build ios --debug --no-codesign
# エラーが出ても構文チェックとして有効
```

### 3. **Unity Framework検証**
```bash
# UnityFramework.framework の存在確認
dir ios\Frameworks\UnityFramework.framework
# サイズ確認（235MB程度が正常）
```

## 🔧 **Android Studio で確認できる項目**

### ✅ **1. pubspec.yaml 依存関係**
```yaml
dependencies:
  flutter_unity_widget: ^2022.2.1  # Unity統合
  permission_handler: ^11.0.1      # iOS権限
  google_fonts: ^6.1.0            # フォント
```
**確認方法**: Android Studio の pubspec.yaml で赤線エラーチェック

### ✅ **2. Dart コード構文**
```dart
// lib/screens/unity_vr_screen.dart の import確認
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import 'package:permission_handler/permission_handler.dart';
```
**確認方法**: Android Studio エディタで赤線・警告確認

### ✅ **3. iOS設定ファイル構文**
- `ios/Runner/Info.plist` - XML構文エラー
- `ios/Podfile` - Ruby構文エラー  
- `ios/Flutter/*.xcconfig` - 設定値エラー

## 🎮 **Unity統合チェックリスト**

### **✅ Framework配置確認**
```
ios/Frameworks/UnityFramework.framework/
├── UnityFramework          # 218MB (メインライブラリ)
├── Data/                   # Unity ゲームデータ
├── Headers/UnityFramework.h # C++ヘッダー
├── Info.plist             # Framework情報
└── Modules/module.modulemap # Swift統合
```

### **✅ Flutter-Unity通信コード**
```dart
// unity_vr_screen.dart で確認すべき項目
void _onUnityCreated(UnityWidgetController controller) {
  _unityWidgetController = controller;
}

void _startVRMode() {
  _unityWidgetController.postMessage(
    'FlutterUnityBridge',
    'OnMessage', 
    '{"type":"START_VR","value":""}',
  );
}
```

## 🚨 **よくある問題パターン**

### **1. Bundle ID不一致**
```bash
# 確認方法
grep -r "com.vr.avatar1" ios/
# 以下のファイルで一致確認:
# - ios/Runner.xcodeproj/project.pbxproj
# - codemagic.yaml
```

### **2. 依存関係バージョン競合**
```bash
flutter pub deps --style=compact
# 競合があれば Warning が表示される
```

### **3. iOS最低バージョン不一致**
```bash
# 各ファイルで 15.0 確認
# - ios/Podfile: platform :ios, '15.0'
# - ios/Flutter/Debug.xcconfig: IPHONEOS_DEPLOYMENT_TARGET = 15.0
# - ios/Runner/Info.plist: MinimumOSVersion 15.0
```

## 🔍 **Android Studio で実行すべきチェック**

### **即座に実行可能**
```bash
# 1. Flutter環境確認
flutter doctor

# 2. 依存関係確認  
flutter pub get
flutter pub deps

# 3. Dart構文確認
flutter analyze

# 4. iOS基本ビルドテスト（エラー表示目的）
flutter build ios --debug --no-codesign
```

### **Android Studio UI確認**
1. **pubspec.yaml**: 依存関係の赤線確認
2. **Dart Files**: import エラー・型エラー確認
3. **Terminal**: flutter コマンド実行結果確認
4. **File Explorer**: Framework配置確認

## ⚠️ **判明しない問題（iOS実機・Xcode必要）**

### **ビルド時のみ判明**
- Xcode署名エラー
- Unity Framework リンクエラー
- Metal API実行時エラー
- Neural Engine実行時エラー
- 実機特有の性能問題

### **CodeMagic でのみ判明**
- 証明書・プロビジョニングエラー
- App Store Connect連携エラー
- CI/CD環境特有の問題

## 🚀 **推奨確認手順**

### **Phase 1: 基本チェック（5分）**
```bash
flutter doctor -v
flutter pub get
flutter analyze
```

### **Phase 2: 構文チェック（10分）**
```bash
flutter build ios --debug --no-codesign
# エラーメッセージから iOS固有問題を特定
```

### **Phase 3: ファイル確認（10分）**
- Framework配置確認
- 設定ファイル構文確認
- Bundle ID一致確認

### **Phase 4: CodeMagic準備**
- Git push
- CodeMagic実際ビルドで最終確認

## 💡 **Windows環境での最適戦略**

**「事前チェック最大化 + CodeMagic早期テスト」**

1. **Windows**: 構文・設定の事前チェック徹底
2. **CodeMagic**: 実際のiOSビルド・実行テスト
3. **段階的修正**: エラーを1つずつ修正

---

**Windows環境でも相当数の問題を事前に発見・修正できます！まずは基本チェックを実行してみましょう！** 🎮✨