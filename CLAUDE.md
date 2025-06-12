# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## プロジェクト概要

トレーニング用のFlutterインターバルタイマーアプリです。2つのタイマーモードをサポート：
- **カウントダウンタイマー**: 指定した時間からシンプルにカウントダウン
- **インターバルタイマー**: 指定したサイクル数でトレーニングと休憩時間を交互に繰り返し

## 必須コマンド

```bash
# 依存関係のインストール
flutter pub get

# アプリの実行
flutter run

# テストの実行
flutter test

# 静的解析
flutter analyze

# 各プラットフォーム向けビルド
flutter build apk          # Android
flutter build ios          # iOS
flutter build web          # Web
flutter build windows      # Windows
flutter build macos        # macOS
flutter build linux        # Linux
```

## アーキテクチャ概要

### コアコンポーネント

**状態管理**: `TimerService`がタイマー状態を管理し、`StreamController<TimerState>`を通じて更新をブロードキャストするストリームベースアーキテクチャ。

**タイマーロジック**: 
- `TimerService`がすべてのタイマー操作（開始、一時停止、再開、停止）を処理
- `TimerState`は現在の残り時間、ステータス、タイプ、インターバル固有データを含む不変状態クラス
- タイマーは`Timer.periodic`を使用して1秒間隔で実行

**通知システム**:
- `NotificationService`が音声（ビープ音）と触覚フィードバック（振動）の両方を処理
- Webプラットフォームは音声にbase64エンコードされたWAVデータを使用
- モバイルプラットフォームは触覚フィードバックに`vibration`パッケージを使用

### 主要依存関係

- `audioplayers: ^6.0.0` - クロスプラットフォーム音声再生
- `vibration: ^2.0.0` - デバイス振動サポート

### タイマー状態フロー

1. **Initial** → ユーザーがタイマー設定を構成
2. **Running** → タイマーがカウントダウンし、UIを毎秒更新
3. **Paused** → タイマーが停止、再開可能
4. **Finished** → タイマー完了、通知をトリガー

インターバルタイマーの場合、サービスは自動的にワーク/レスト フェーズ間を遷移し、サイクル進行を追跡します。

### UI構造

- `TimerScreen`は`TimerState`ストリームに基づくリアクティブUIのメインインターフェース
- セッション中の設定変更を防ぐため、タイマー動作中は設定が無効化
- タイマー表示は現在の状態とフェーズに基づいて異なる色を表示
- 小さな画面でのオーバーフローを防ぐScrollViewレイアウト

## 開発ノート

### 新しいタイマータイプの追加
`TimerType`列挙型を拡張し、`TimerService._handleTimerEnd()`に対応するロジックを追加。

### プラットフォーム固有機能
音声と振動の実装には、段階的劣化のためのプラットフォームチェック（`kIsWeb`、`Vibration.hasVibrator()`）が含まれています。

### テスト
Widgetテストはアプリ初期化と基本UI要素を検証。タイマーロジックは`NotificationService`をモックすることでテスト可能。

### 言語設定
このプロジェクトは日本語UIで構築されており、すべてのユーザー向けテキストは日本語で記述されています。新機能やUIコンポーネントを追加する際は日本語を使用してください。

### コミット前の必須タスク
コミットを行う前に、以下のドキュメントを必要に応じて更新してください：

1. **CLAUDE.md**: 新機能や構造的変更がある場合は、アーキテクチャ概要や開発ノートを更新
2. **README.md**: ユーザー向け機能や使用方法に変更がある場合は、機能説明や使用方法セクションを更新

これにより、ドキュメントと実装の整合性が保たれ、将来の開発者が正確な情報にアクセスできます。