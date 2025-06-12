# インターバルタイマー

トレーニング用のFlutterインターバルタイマーアプリです。

## 機能

### カウントダウンタイマー
- 指定した時間（分単位）からカウントダウン
- 時間が0になると音と振動で通知

### インターバルタイマー
- トレーニング時間と休憩時間を設定
- 指定したサイクル数だけ繰り返し実行
- 各フェーズ（トレーニング/休憩）の切り替え時に通知
- 現在のフェーズとサイクル数を表示

### 通知機能
- **音効果**: ビープ音による通知
- **振動**: スマートフォンでの触覚フィードバック（ブル、ブル、ブル）

### 基本操作
- 開始：タイマーを開始
- 一時停止：実行中のタイマーを一時停止
- 再開：一時停止中のタイマーを再開
- 停止：タイマーを停止してクリア

## インストールと実行

### 前提条件
- Flutter SDK
- Dart SDK

### セットアップ
```bash
# 依存関係のインストール
flutter pub get

# アプリの実行
flutter run
```

### テストの実行
```bash
# 全てのテストを実行
flutter test

# 静的解析
flutter analyze
```

### ビルド
```bash
# Android
flutter build apk

# iOS
flutter build ios

# Web
flutter build web
```

## プロジェクト構成

```
lib/
├── main.dart                    # アプリのエントリーポイント
├── models/
│   └── timer_state.dart         # タイマーの状態モデル
├── services/
│   ├── timer_service.dart       # タイマーのビジネスロジック
│   └── notification_service.dart # 音と振動の通知サービス
└── screens/
    └── timer_screen.dart        # メイン画面のUI
```

## 技術仕様

- **フレームワーク**: Flutter
- **状態管理**: Stream-based architecture
- **音声再生**: audioplayers package
- **振動制御**: vibration package
- **対応プラットフォーム**: Android, iOS, Web, Windows, macOS, Linux

## 使用方法

1. **タイマーの種類を選択**：カウントダウンまたはインターバル
2. **時間を設定**：
   - カウントダウン：分単位で時間を入力
   - インターバル：トレーニング時間、休憩時間、サイクル数を入力
3. **開始ボタンをタップ**してタイマーを開始
4. **一時停止・再開・停止**ボタンでタイマーを制御

タイマーが終了すると、音と振動（対応デバイス）で通知されます。
