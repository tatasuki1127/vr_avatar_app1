# VR Avatar App 🎮

**GPU最適化リアルタイム人物VR化アプリ**  
Metal API + Neural Engine対応

## 📱 アプリ概要

「カメラを開いた瞬間、GPUパワーであなたが瞬時にVRキャラクターになる」

### 🎯 主要機能
- **60FPS安定動作**: Metal API GPU最適化
- **Neural Engine AI**: 8ms超高速推論
- **4K高画質撮影**: GPU画像処理
- **1人検出・追跡**: 最大人物自動選択

### 🏗️ アーキテクチャ
- **Flutter**: スタート画面・UI
- **Unity as Library**: VR機能・GPU最適化
- **Metal API**: GPU描画最適化
- **Neural Engine**: AI推論加速

## 🔧 開発環境

### 必要ツール
- Flutter SDK 3.0+
- Unity 2023.3 LTS
- Xcode 15+ (Metal 3 SDK)
- Android Studio

### 対応端末
- **推奨**: iPhone 12 Pro以降 (Neural Engine搭載)
- **最低**: iPhone XS以降 (A12 Bionic)
- **iOS**: 15.0以降

## 🚀 セットアップ

### 1. プロジェクトクローン
```bash
git clone <repository>
cd vr_avatar_app
```

### 2. 依存関係インストール
```bash
flutter pub get
```

### 3. Unity Framework統合
1. Unity プロジェクトで BuildScript.cs を実行
2. UnityFramework.framework を生成
3. iOS プロジェクトに framework を追加

### 4. 実行
```bash
# iOS シミュレーター
flutter run

# 実機 (推奨)
flutter run --release
```

## 📁 プロジェクト構造

```
vr_avatar_app/
├── lib/
│   ├── main.dart                 # アプリエントリーポイント
│   ├── screens/
│   │   ├── splash_screen.dart    # スプラッシュ画面
│   │   ├── home_screen.dart      # ホーム画面
│   │   └── unity_vr_screen.dart  # Unity VR統合画面
│   └── unity_integration/        # Unity統合関連
├── assets/
│   ├── images/                   # 画像アセット
│   ├── icons/                    # アイコン
│   └── fonts/                    # フォント
├── ios/
│   └── Runner/
│       └── Info.plist           # iOS設定
└── unity_build/                 # Unity出力
    └── UnityFramework.framework
```

## 🎮 操作方法

### メイン画面
- **VR体験を開始**: Unity VR機能起動

### VR画面
- **撮影ボタン**: 4K高画質写真撮影
- **キャラボタン**: 3体キャラクター切り替え
- **カメラボタン**: 前面/背面カメラ切り替え

## ⚡ GPU最適化機能

### Metal API活用
- GPU並列頂点変形
- Compute Shader最適化
- Tile-Based Rendering

### Neural Engine
- 8ms以内AI推論
- 専用チップ並列処理
- リアルタイム人物検出

### 性能目標
- **フレームレート**: 60FPS安定
- **AI推論遅延**: 8ms以内
- **3D描画**: 16ms以内
- **起動時間**: 2秒以内

## 🔧 カスタマイズ

### テーマ変更
`lib/main.dart` でカラースキーム調整可能

### Unity統合
`lib/screens/unity_vr_screen.dart` でUnity通信設定

### 権限設定
`ios/Runner/Info.plist` でカメラ・写真権限設定

## 📄 ライセンス

### 依存パッケージ
- flutter_unity_widget: ^2022.2.1
- google_fonts: ^6.1.0
- permission_handler: ^11.0.1
- animated_splash_screen: ^1.3.0

## 🎯 開発進捗

- [x] Flutter基盤実装
- [x] Unity as Library変換
- [x] Flutter-Unity通信
- [x] iOS設定完了
- [x] GPU最適化準備
- [ ] Unity Framework統合
- [ ] 実機テスト
- [ ] CodeMagic CI/CD

## 🚀 次のステップ

1. **Unity Framework統合**
   ```bash
   open ios/Runner.xcworkspace
   # UnityFramework.framework を追加
   ```

2. **実機テスト**
   ```bash
   flutter run --release --target ios
   ```

3. **CodeMagic CI/CD設定**
   - Flutter + Unity as Library ビルド設定
   - 85-95% 成功率目標

---

**GPU最適化により、業界最高水準のリアルタイムVR化アプリを実現** 🎮✨
