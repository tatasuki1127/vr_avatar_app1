# Unity Framework 統合ガイド 🎮

## 📁 推奨ディレクトリ構造

```
C:\Users\nndds\
├── VRAvatar/                    # Unity プロジェクト
│   ├── Assets/
│   └── Unity出力フォルダ/
│       └── ios_build/           # Unity as Library 出力
│           └── UnityFramework.framework
│
└── StudioProjects/
    └── vr_avatar_app/           # Flutter プロジェクト  
        ├── lib/
        ├── ios/
        │   └── Frameworks/      # ここに Framework を配置
        │       └── UnityFramework.framework
        └── unity_framework/     # Unity 統合用フォルダ
```

## 🔧 Unity Framework 配置手順

### 1. Unity Export 実行
```bash
# Unity プロジェクトディレクトリで
cd /mnt/c/Users/nndds/VRAvatar

# Build Script 実行 (Unity Editor)
# Window → General → Console
# Assets/Editor/BuildScript.cs の ExportUnityAsLibrary() を実行
```

### 2. Framework の配置場所

#### **推奨配置場所 (Flutter プロジェクト内)**
```bash
# Flutter プロジェクトに統合フォルダを作成
mkdir -p "/mnt/c/Users/nndds/StudioProjects/vr_avatar_app/unity_framework"
mkdir -p "/mnt/c/Users/nndds/StudioProjects/vr_avatar_app/ios/Frameworks"
```

#### **Unity 出力から Flutter へコピー**
```bash
# Unity の出力場所を確認
ls /mnt/c/Users/nndds/VRAvatar/

# UnityFramework.framework を Flutter に配置
# (実際のパスは Unity エクスポート後に確認)
cp -r "Unity出力パス/UnityFramework.framework" \
      "/mnt/c/Users/nndds/StudioProjects/vr_avatar_app/ios/Frameworks/"
```

## 🎯 iOS プロジェクト設定

### 1. Xcode でプロジェクトを開く
```bash
open "/mnt/c/Users/nndds/StudioProjects/vr_avatar_app/ios/Runner.xcworkspace"
```

### 2. Framework を追加
1. **Project Navigator** で `Runner` を選択
2. **TARGETS** → `Runner` → **General** タブ
3. **Frameworks, Libraries, and Embedded Content** セクション
4. **+** ボタンをクリック
5. **Add Files to "Runner"** で `UnityFramework.framework` を選択
6. **Embed & Sign** に設定

### 3. Build Settings 調整
```
Build Settings → Linking:
- Other Linker Flags: -framework UnityFramework
- Enable Bitcode: No
- Validate Workspace: Yes
```

## 📂 Unity 出力先の確認方法

### BuildScript.cs の出力設定
```csharp
// Assets/Editor/BuildScript.cs 内
string buildPath = Path.Combine(
    Application.dataPath.Replace("Assets", ""), 
    "ios_build"  // この名前でフォルダが作成される
);
```

### 出力先フォルダ
Unity エクスポート後、以下の場所に出力されます：
```
C:\Users\nndds\VRAvatar\ios_build\
└── UnityFramework.framework\
    ├── UnityFramework
    ├── Info.plist
    ├── Headers/
    └── Modules/
```

## ⚠️ 重要な注意点

### 1. Framework のサイズ
- UnityFramework.framework は通常 100-500MB
- Git LFS の使用を推奨

### 2. バージョン管理
```bash
# .gitignore に追加推奨
echo "ios/Frameworks/" >> .gitignore
echo "unity_framework/" >> .gitignore
```

### 3. CI/CD 対応
```yaml
# codemagic.yaml 設定例
scripts:
  - name: Copy Unity Framework
    script: |
      cp -r unity_framework/UnityFramework.framework ios/Frameworks/
```

## 🚀 動作確認手順

### 1. Flutter ビルドテスト
```bash
cd /mnt/c/Users/nndds/StudioProjects/vr_avatar_app
flutter clean
flutter pub get
flutter build ios --debug
```

### 2. Unity 統合確認
```bash
# iOS シミュレーターで実行
flutter run --debug
# メイン画面 → VR体験を開始 → Unity シーンロード確認
```

## 🔗 次のステップ

1. **Unity プロジェクトでエクスポート実行**
2. **Framework を Flutter プロジェクトにコピー**
3. **Xcode で Framework 設定**
4. **実機テスト実行**

---
**Unity Framework統合により、Flutter + Unity as Library が完成します！** 🎮✨