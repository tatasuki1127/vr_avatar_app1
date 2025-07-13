# Unity Framework 管理戦略 📦

## 📊 **圧縮結果**
- **元サイズ**: 235MB (UnityFramework.framework)
- **圧縮後**: 78MB (UnityFramework.zip)
- **圧縮率**: 67% 削減

## 🎯 **自動化戦略**

### **Git 管理**
```gitignore
# Unity Framework は zip 圧縮で管理
ios/Frameworks/
!ios/UnityFramework.zip
```

### **CodeMagic 自動展開**
```yaml
- name: Unity Framework の自動展開
  script: |
    cd ios
    if [ -f "UnityFramework.zip" ]; then
      unzip -o UnityFramework.zip
      echo "✅ Unity Framework extracted"
    fi
```

## 🚀 **実行手順**

### **1. 初回セットアップ**
```bash
# Unity Framework を圧縮
cd ios
zip -r UnityFramework.zip Frameworks/UnityFramework.framework/

# Git コミット
git add UnityFramework.zip
git add .gitignore
git commit -m "Add compressed Unity Framework (78MB)"
git push
```

### **2. 更新時**
```bash
# 新しい Unity Framework で再圧縮
cd ios
rm UnityFramework.zip
zip -r UnityFramework.zip Frameworks/UnityFramework.framework/
git add UnityFramework.zip
git commit -m "Update Unity Framework"
git push
```

## ✅ **メリット**
- **Git サイズ削減**: 235MB → 78MB
- **自動展開**: CodeMagic で自動処理
- **バージョン管理**: Git で Framework 履歴管理
- **ビルド高速化**: 圧縮により転送時間短縮

## ⚠️ **注意点**
- UnityFramework.framework は .gitignore で除外
- UnityFramework.zip のみ Git 管理
- CodeMagic で毎回自動展開
- 展開エラー時はビルド停止