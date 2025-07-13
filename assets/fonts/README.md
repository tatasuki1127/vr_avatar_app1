# フォントファイル配置場所

## NotoSansJP フォント
このプロジェクトでは Noto Sans Japanese フォントを使用します。

### ダウンロード手順：
1. Google Fonts から Noto Sans JP をダウンロード
   - https://fonts.google.com/noto/specimen/Noto+Sans+JP
2. 以下のファイルをこのフォルダに配置：
   - `NotoSansJP-Regular.ttf`
   - `NotoSansJP-Bold.ttf` (オプション)

### 代替方法：
google_fonts パッケージを使用することも可能：
```dart
import 'package:google_fonts/google_fonts.dart';

TextStyle(
  fontFamily: GoogleFonts.notoSansJp().fontFamily,
)
```

### 現在の設定：
pubspec.yaml で設定済み：
```yaml
fonts:
  - family: NotoSansJP
    fonts:
      - asset: assets/fonts/NotoSansJP-Regular.ttf
```