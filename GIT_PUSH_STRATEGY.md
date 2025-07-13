# Git Push 戦略 - Unity Framework 対応 🚨

## 🔍 **現在の問題**

### **ios/Frameworks/ が .gitignore に含まれている**
```gitignore
# 行48: Unity Framework (235MB) - CodeMagicで管理
ios/Frameworks/
```

**235MB の UnityFramework.framework が Git にプッシュされていません！**

## ⚠️ **重要な判断が必要**

### **Option 1: Framework を Git に含める**
#### ✅ **メリット**
- CodeMagic で即座にビルド可能
- Unity Framework バージョン管理
- チーム開発での一貫性

#### ❌ **デメリット**
- Git リポジトリが 235MB 増加
- クローン時間の増加
- GitHub 制限に近づく

### **Option 2: Framework を Git LFS で管理**
#### ✅ **メリット**
- 大容量ファイルの効率的管理
- Git リポジトリサイズの最適化
- バージョン管理も可能

#### ❌ **デメリット**
- Git LFS 設定が必要
- CodeMagic での LFS 対応確認が必要

### **Option 3: CodeMagic でFramework を再構築**
#### ✅ **メリット**
- Git リポジトリサイズ最小
- 最新のUnity Framework 使用

#### ❌ **デメリット**
- CodeMagic で Unity エクスポート処理が必要
- ビルド時間の大幅増加

## 🎯 **推奨戦略: Git LFS 使用**

### **.gitignore 修正**
```gitignore
# Unity Framework (Git LFS管理)
# ios/Frameworks/  ← この行を削除またはコメントアウト

# Unity Export関連（除外維持）
UnityAsLibrary-iOS/
unity_build/
```

### **Git LFS セットアップ**
```bash
# Git LFS 初期化
git lfs install

# Unity Framework を LFS 追跡
git lfs track "ios/Frameworks/**"
git lfs track "*.framework/**"

# .gitattributes 確認
git add .gitattributes
```

## 📋 **必須プッシュファイル一覧**

### **✅ 絶対にプッシュすべき**
```
# Flutter プロジェクト基盤
lib/                          # Dart コード
pubspec.yaml                  # 依存関係
analysis_options.yaml         # コード品質

# iOS 設定ファイル（修正済み）
ios/Runner/Info.plist         # Bundle ID: com.vr.avatar1
ios/Runner.xcodeproj/project.pbxproj  # Xcode設定
ios/Flutter/Debug.xcconfig    # GPU最適化設定
ios/Flutter/Release.xcconfig  # リリース設定
ios/Podfile                   # CocoaPods設定

# CI/CD 設定
codemagic.yaml               # ビルド・署名設定

# アセット構造
assets/images/.gitkeep
assets/icons/.gitkeep
assets/fonts/README.md
```

### **🔧 Unity Framework (要判断)**
```
ios/Frameworks/UnityFramework.framework/  # 235MB
├── UnityFramework                        # メインライブラリ
├── Data/                                # Unity データ
├── Headers/UnityFramework.h             # ヘッダー
├── Info.plist                          # Framework情報
└── Modules/module.modulemap             # Swift統合
```

### **❌ プッシュ不要（除外済み）**
```
build/                       # ビルド成果物
.dart_tool/                  # Flutter ツール
ios/Runner.xcworkspace/xcuserdata/  # Xcode ユーザー設定
*.mobileprovision            # 証明書関連
*.p12, *.cer, *.key         # 署名ファイル
```

## 🚀 **即座に実行すべきコマンド**

### **Framework をプッシュする場合**
```bash
# .gitignore から ios/Frameworks/ を削除
# または以下でコメントアウト:
sed -i 's/^ios\/Frameworks\//# ios\/Frameworks\//' .gitignore

# Git LFS セットアップ（推奨）
git lfs install
git lfs track "ios/Frameworks/**"

# 追加・コミット
git add .gitattributes
git add ios/Frameworks/
git add ios/Runner/Info.plist
git add ios/Runner.xcodeproj/project.pbxproj
git commit -m "Add Unity Framework with Bundle ID fixes"
git push
```

### **Framework を除外維持する場合**
```bash
# CodeMagic で Unity Framework を手動配置する設定が必要
# codemagic.yaml に Framework コピー処理を追加

git add ios/Runner/Info.plist
git add ios/Runner.xcodeproj/project.pbxproj
git add ios/Flutter/
git add ios/Podfile
git commit -m "Fix Bundle ID and iOS settings for CodeMagic"
git push
```

## 💡 **推奨アクション**

### **Phase 1: 設定ファイルを先にプッシュ**
```bash
# Bundle ID修正済みファイルをプッシュ
git add ios/Runner/Info.plist ios/Runner.xcodeproj/project.pbxproj
git commit -m "Fix Bundle ID inconsistency: com.vr.avatar1"
git push
```

### **Phase 2: Framework 戦略決定**
**Unity Framework (235MB) をどうするか決定：**
1. **Git LFS でプッシュ** (推奨)
2. **除外してCodeMagicで再構築**
3. **直接プッシュ** (リポジトリ増大)

## ⚡ **CodeMagic エラー対策**

**Bundle ID修正により以下が解決:**
- ✅ PRODUCT_BUNDLE_IDENTIFIER 統一
- ✅ Apple Developer Account との一致
- ✅ プロビジョニングプロファイル対応

**Framework 問題への対処:**
- 🔧 Git にプッシュ → 即座にビルド可能
- 🔧 CodeMagic で配置 → 別途スクリプト必要

---

**まず Bundle ID修正済みファイルをプッシュして、Unity Framework 戦略を決定することを推奨します！** 🎮✨