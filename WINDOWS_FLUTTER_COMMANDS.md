# Windows Flutter コマンド確認 🔍

## 🚨 **Windows環境での制限**

### **flutter build ios は Windows で利用不可**
- **理由**: iOS ビルドはmacOS + Xcode が必須
- **Windows**: iOS関連コマンドは存在しない
- **解決策**: 代替検証方法を使用

## ✅ **Windows で実行可能な検証コマンド**

### **1. Flutter 環境確認**
```bash
# Flutter SDK状態確認
flutter doctor

# 詳細情報表示
flutter doctor -v
```

### **2. プロジェクト基本検証**
```bash
# 依存関係取得・検証
flutter pub get

# Dart構文解析（最重要）
flutter analyze

# 依存関係ツリー確認
flutter pub deps
```

### **3. 利用可能なビルドコマンド確認**
```bash
# 利用可能なビルドターゲット表示
flutter build -h

# 一般的な利用可能コマンド例
flutter build apk          # Android APK
flutter build appbundle    # Android App Bundle  
flutter build web          # Web アプリ
# flutter build ios        # ← Windows では利用不可
```

### **4. iOS設定ファイル構文確認**
```bash
# Podfile 構文確認（Ruby）
Get-Content ios\Podfile | Select-String "error"

# Info.plist 構文確認（XML）
Get-Content ios\Runner\Info.plist | Select-String "error"

# xcconfig 確認
Get-Content ios\Flutter\Debug.xcconfig
Get-Content ios\Flutter\Release.xcconfig
```

## 🔧 **代替検証方法**

### **iOS プロジェクト構造確認**
```bash
# Unity Framework 配置確認
dir ios\Frameworks\UnityFramework.framework

# Framework サイズ確認
Get-ChildItem ios\Frameworks\UnityFramework.framework -Recurse | Measure-Object -Property Length -Sum

# 設定ファイル存在確認
Test-Path ios\Runner\Info.plist
Test-Path ios\Podfile
Test-Path ios\Flutter\Debug.xcconfig
```

### **Bundle ID 一致確認**
```bash
# プロジェクト内 Bundle ID 検索
Select-String -Path ios\Runner.xcodeproj\project.pbxproj -Pattern "com.vr.avatar1"
Select-String -Path codemagic.yaml -Pattern "com.vr.avatar1"
```

## 📊 **Windows環境チェックリスト**

### ✅ **実行可能な検証**
- [x] `flutter doctor` - Flutter SDK確認
- [x] `flutter pub get` - 依存関係解決  
- [x] `flutter analyze` - 構文・型チェック
- [x] Framework配置確認 - Unity統合
- [x] 設定ファイル構文 - iOS設定
- [x] Bundle ID一致 - 署名準備

### ❌ **実行不可能（macOS必須）**
- [ ] `flutter build ios` - iOS実際ビルド
- [ ] Xcode プロジェクト確認
- [ ] iOS Simulator実行
- [ ] 実機デバッグ
- [ ] Metal API実行時確認

## 🚀 **推奨ワークフロー**

### **Phase 1: Windows 事前確認（現在）**
```bash
# 1. Flutter環境
flutter doctor -v

# 2. 依存関係
flutter pub get
flutter analyze

# 3. ファイル確認
dir ios\Frameworks\UnityFramework.framework
```

### **Phase 2: CodeMagic CI/CD テスト**
```yaml
# CodeMagic で iOS ビルドテスト
- flutter pub get
- cd ios && pod install  
- flutter build ios --release
```

### **Phase 3: 段階的問題解決**
1. **Windows**: 構文・依存関係エラー解決
2. **CodeMagic**: iOS固有エラー解決
3. **反復**: エラー→修正→再テスト

## 💡 **現在実行すべきコマンド**

### **即座に実行**
```bash
# Flutter環境確認
flutter doctor

# 依存関係・構文確認
flutter pub get
flutter analyze

# Unity Framework確認  
dir ios\Frameworks\UnityFramework.framework
Get-ChildItem ios\Frameworks\UnityFramework.framework -Recurse | Measure-Object -Property Length -Sum
```

### **設定確認**
```bash
# Bundle ID 一致確認
Select-String -Path ios\Runner.xcodeproj\project.pbxproj -Pattern "com.vr.avatar1"

# 設定ファイル存在確認
Test-Path ios\Podfile
Test-Path ios\Runner\Info.plist
```

## ⚡ **Windows環境での成果**

**Windows でも以下が確認できます：**

- ✅ **Dart/Flutter コード品質**: analyze で検証
- ✅ **依存関係の整合性**: pub get で確認
- ✅ **iOS設定ファイル**: 構文・設定値確認
- ✅ **Unity Framework**: 配置・サイズ確認
- ✅ **Bundle ID統一**: 全ファイル一致確認

**これらの事前確認により、CodeMagic でのビルド成功率が大幅に向上します！**

---

**iOS ビルドはできませんが、Windows環境でも多くの問題を事前発見・解決できます！**  
**上記コマンドを実行して、iOS ビルドの準備状況を確認しましょう！** 🎮✨