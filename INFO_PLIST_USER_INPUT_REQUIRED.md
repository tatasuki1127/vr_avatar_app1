# Info.plist 設定に必要な情報 📝

## 🔧 現在提供が必要な情報

### 1. アプリ表示名の確認
**現在の設定:**
- `CFBundleDisplayName`: "Vr Avatar App"
- `CFBundleName`: "vr_avatar_app"

**❓ 確認事項:**
- **App Store表示名**: "VR Avatar App" で良いですか？
- **ホーム画面表示名**: 短縮が必要な場合は何にしますか？ (例: "VR Avatar")

### 2. カメラ・写真権限の説明文
**現在の設定:**
```xml
<!-- カメラ権限 -->
<key>NSCameraUsageDescription</key>
<string>This app uses the camera for real-time VR avatar creation and pose tracking with GPU optimization. Camera access is required for Neural Engine AI processing and Metal API rendering.</string>

<!-- 写真保存権限 -->
<key>NSPhotoLibraryUsageDescription</key>
<string>This app saves VR avatar photos to your photo library with 4K GPU-enhanced quality.</string>
```

**❓ 確認事項:**
- **日本語版も必要ですか？** (App Store申請時)
- **説明文の変更希望はありますか？**

### 3. 開発者・会社情報 (オプション)
**追加を検討する項目:**

#### 著作権表示
```xml
<key>NSHumanReadableCopyright</key>
<string>© 2024 Your Company Name. All rights reserved.</string>
```

#### サポートURL (オプション)
```xml
<key>ITSAppUsesNonExemptEncryption</key>
<false/>

<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
</dict>
```

## 💡 推奨する追加設定

### 1. アプリ名の最適化
```xml
<!-- ホーム画面表示用（短縮版） -->
<key>CFBundleDisplayName</key>
<string>VR Avatar</string>

<!-- 内部名（変更不要） -->
<key>CFBundleName</key>
<string>vr_avatar_app</string>
```

### 2. 日本語ローカライゼーション
```xml
<!-- カメラ権限（日本語） -->
<key>NSCameraUsageDescription</key>
<string>リアルタイムVRアバター作成とポーズトラッキングのためにカメラを使用します。Neural Engine AI処理とMetal API描画に必要です。</string>

<!-- 写真保存権限（日本語） -->
<key>NSPhotoLibraryUsageDescription</key>
<string>4K GPU高画質処理されたVRアバター写真をフォトライブラリに保存します。</string>
```

### 3. App Store最適化
```xml
<!-- 暗号化使用の明示（App Store審査用） -->
<key>ITSAppUsesNonExemptEncryption</key>
<false/>

<!-- バックグラウンド動作制限（VRアプリ推奨） -->
<key>UIApplicationExitsOnSuspend</key>
<false/>
```

## 🎯 必要な入力情報まとめ

### **即座に必要**
1. **アプリ表示名の最終決定**
   - App Store: "VR Avatar App" or "VRアバターアプリ"？
   - ホーム画面: "VR Avatar" or "VRアバター"？

### **App Store申請時に必要**
2. **著作権表示**
   - 会社名 or 個人名
   - 例: "© 2024 [あなたの名前/会社名]. All rights reserved."

3. **日本語権限説明の確認**
   - 現在の英語版で良いか
   - 日本語版に変更するか

### **オプション（推奨）**
4. **サポート・問い合わせ情報**
   - サポートメールアドレス
   - プライバシーポリシーURL

## 🚀 次のアクション

**以下をお知らせください：**

1. **✅ アプリ名**: 最終的な表示名
2. **✅ 権限説明**: 英語のままか日本語に変更か
3. **⭐ 著作権**: 会社名・個人名
4. **⭐ サポート**: 連絡先（オプション）

**現在の設定で問題なければ、そのままCodeMagicビルドが可能です！**

---
**基本設定は完了しているので、必要に応じて上記項目をお教えください！** 🎮✨