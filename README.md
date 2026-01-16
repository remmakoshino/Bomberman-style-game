# 🎮 ボンバーマン風アクションゲーム for iOS

![iOS](https://img.shields.io/badge/iOS-17.0+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)
![SpriteKit](https://img.shields.io/badge/SpriteKit-2D%20Game-green.svg)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)

Swift + SpriteKitで開発されたボンバーマン風2Dアクションゲームです。GitHub Actionsを活用したCI/CDパイプラインにより、自動ビルド・テスト・配布を実現しています。

## 📱 スクリーンショット

*（実機ビルド後にスクリーンショットを追加）*

## ✨ 特徴

### ゲームシステム
- 🎯 **13×11グリッドベースのクラシックなゲームプレイ**
- 💣 **爆弾設置と十字方向への爆発**
- 🧱 **破壊可能なソフトブロックと破壊不可のハードブロック**
- 🎁 **7種類のパワーアップアイテム**
- 👾 **5種類のAI敵キャラクター（5段階のAIレベル）**
- 🏆 **ステージクリア型の進行システム**

### 技術的特徴
- 🚀 **Swift 5.9+ / SpriteKit**
- 📦 **GitHub Actions CI/CD**
- 🔧 **fastlane による自動デプロイ**
- ✅ **70%以上のユニットテストカバレッジ**
- ⚙️ **調整可能なゲームバランスパラメータ**

## 📋 動作要件

- iOS 17.0以上
- iPhone / iPad（横向き対応）
- Xcode 15.0以上（ビルド用）

## 🎮 ゲームの遊び方

### 操作方法
- **仮想ジョイスティック**: 左側でプレイヤーを4方向に移動
- **爆弾ボタン**: 右側のボタンで爆弾を設置
- **ポーズボタン**: 画面右上でゲームを一時停止

### 目標
1. 爆弾を設置してソフトブロックを破壊
2. 敵を全滅させてステージクリア
3. アイテムを収集してパワーアップ
4. 自分の爆発に巻き込まれないように注意！

### アイテム一覧

| アイテム | 効果 |
|---------|------|
| 🔥 火力UP | 爆発範囲が1マス拡大 |
| 💣 爆弾UP | 同時設置可能な爆弾が1個増加 |
| ⚡ スピードUP | 移動速度が上昇 |
| 📡 リモコン | 爆弾を任意のタイミングで起爆可能 |
| 🚪 壁抜け | ソフトブロックを通過可能 |
| 💨 爆弾抜け | 爆弾を通過可能 |
| ⭐ 無敵 | 一定時間無敵状態 |

### 敵キャラクター

| 敵タイプ | 特徴 | スコア |
|---------|------|--------|
| バルーン | 最も遅い敵、ランダム移動 | 100 |
| オニル | やや速い、プレイヤーを追跡 | 200 |
| ダール | 高速移動 | 400 |
| ミンボ | 壁抜け能力あり | 800 |
| オバペ | 最速、壁抜け能力あり | 1000 |

### 難易度設定

| 難易度 | ライフ | 初期爆弾 | 初期火力 | アイテム出現率 |
|--------|--------|----------|----------|----------------|
| イージー | 5 | 2 | 2 | 高 |
| ノーマル | 3 | 1 | 1 | 中 |
| ハード | 2 | 1 | 1 | 低 |
| エキスパート | 1 | 1 | 1 | 最低 |

## 🛠 開発環境セットアップ

### 必要なツール
- macOS 14.0以上
- Xcode 15.0以上
- Ruby 3.0以上（fastlane用）
- Bundler

### セットアップ手順

```bash
# リポジトリをクローン
git clone https://github.com/your-username/Bomberman-style-game.git
cd Bomberman-style-game

# fastlane依存関係をインストール
cd BombermanGame
bundle install

# Xcodeでプロジェクトを開く
open BombermanGame.xcodeproj
```

## 🔄 CI/CDパイプライン

### GitHub Actionsワークフロー

#### 1. ビルドワークフロー (`build.yml`)
- **トリガー**: push, pull_request（main, developブランチ）
- **処理内容**:
  - Swift Lintによるコード品質チェック
  - iOSアプリビルド
  - ビルド結果の通知

#### 2. テストワークフロー (`test.yml`)
- **トリガー**: push, pull_request
- **処理内容**:
  - iPhone/iPadシミュレーターでのテスト実行
  - コードカバレッジ計測（目標: 70%以上）
  - テスト結果レポート生成

#### 3. リリースワークフロー (`release.yml`)
- **トリガー**: タグプッシュ（v*）
- **処理内容**:
  - 本番ビルド作成
  - TestFlightへの自動アップロード
  - GitHub Releaseの作成

### GitHub Secrets設定

以下のSecretsをGitHubリポジトリに設定してください：

| Secret名 | 説明 |
|----------|------|
| `CERTIFICATES_P12` | 配布証明書（Base64エンコード） |
| `CERTIFICATES_P12_PASSWORD` | 証明書のパスワード |
| `PROVISIONING_PROFILE` | プロビジョニングプロファイル（Base64エンコード） |
| `APP_STORE_CONNECT_API_KEY` | App Store Connect APIキー（Base64エンコード） |
| `APP_STORE_CONNECT_KEY_ID` | APIキーID |
| `APP_STORE_CONNECT_ISSUER_ID` | 発行者ID |
| `KEYCHAIN_PASSWORD` | Keychain用パスワード |

## 🚀 デプロイ

### TestFlightへのアップロード

```bash
# fastlaneでベータ版をアップロード
bundle exec fastlane beta
```

### App Storeへの提出

```bash
# fastlaneでApp Storeへ提出
bundle exec fastlane release
```

### AdHocビルドの作成

```bash
# AdHoc IPAを作成
bundle exec fastlane adhoc
```

## 📊 テスト実行

### ユニットテストの実行

```bash
# すべてのテストを実行
bundle exec fastlane test

# カバレッジ付きでテストを実行
bundle exec fastlane coverage
```

### テストカバレッジ

テストは以下のコンポーネントをカバーしています：

- ✅ GameManager（ゲーム状態管理）
- ✅ GridSystem（グリッドシステム）
- ✅ Player（プレイヤー操作）
- ✅ Bomb（爆弾ロジック）
- ✅ Item（アイテムシステム）
- ✅ Enemy（敵AI）
- ✅ CollisionSystem（衝突判定）
- ✅ GameConfig（設定管理）
- ✅ Constants（定数定義）

## 📁 プロジェクト構成

```
BombermanGame/
├── BombermanGame/
│   ├── Sources/
│   │   ├── App/                  # アプリケーション
│   │   │   ├── AppDelegate.swift
│   │   │   └── SceneDelegate.swift
│   │   ├── Game/                 # ゲームシーン
│   │   │   ├── GameScene.swift
│   │   │   └── GameViewController.swift
│   │   ├── Models/               # データモデル
│   │   │   ├── Player.swift
│   │   │   ├── Bomb.swift
│   │   │   ├── Explosion.swift
│   │   │   ├── Block.swift
│   │   │   ├── Item.swift
│   │   │   └── Enemy.swift
│   │   ├── Systems/              # ゲームシステム
│   │   │   ├── GridSystem.swift
│   │   │   ├── GameManager.swift
│   │   │   ├── GameState.swift
│   │   │   ├── InputController.swift
│   │   │   ├── CollisionSystem.swift
│   │   │   └── AudioManager.swift
│   │   └── Utils/                # ユーティリティ
│   │       ├── Constants.swift
│   │       ├── GameConfig.swift
│   │       └── Extensions.swift
│   ├── Resources/
│   │   ├── Assets.xcassets/
│   │   ├── Base.lproj/
│   │   │   ├── Main.storyboard
│   │   │   └── LaunchScreen.storyboard
│   │   └── Info.plist
│   └── BombermanGameTests/       # ユニットテスト
│       ├── GameManagerTests.swift
│       ├── GridSystemTests.swift
│       ├── PlayerTests.swift
│       ├── BombTests.swift
│       ├── ItemTests.swift
│       ├── EnemyTests.swift
│       ├── CollisionSystemTests.swift
│       ├── GameConfigTests.swift
│       └── ConstantsTests.swift
├── fastlane/
│   ├── Fastfile
│   ├── Appfile
│   └── ExportOptions.plist
├── .github/
│   └── workflows/
│       ├── build.yml
│       ├── test.yml
│       └── release.yml
├── Gemfile
└── README.md
```

## ⚙️ ゲームバランス調整

`GameConfig.swift`でゲームパラメータを調整できます：

```swift
// プレイヤー設定
playerSpeed: 100          // 移動速度
playerMaxSpeed: 200       // 最大移動速度
initialLives: 3           // 初期ライフ

// 爆弾設定
bombFuseTime: 3.0         // 導火線時間（秒）
explosionDuration: 0.5    // 爆発持続時間

// アイテム設定
itemDropRate: 0.3         // ドロップ率

// 敵設定
enemyBaseSpeed: 50        // 敵の基本速度
```

## 🔧 カスタマイズ

### 新しい敵タイプの追加

```swift
// Enemy.swift に新しいタイプを追加
enum EnemyType: String, CaseIterable {
    case balloon, onil, dahl, minvo, ovape
    case newEnemy  // 新しい敵
    
    var speedMultiplier: CGFloat {
        switch self {
        case .newEnemy: return 1.5
        // ...
        }
    }
}
```

### 新しいアイテムの追加

```swift
// Item.swift に新しいタイプを追加
enum ItemType: String, CaseIterable {
    case fireUp, bombUp, speedUp
    case newItem  // 新しいアイテム
    
    var displayName: String {
        switch self {
        case .newItem: return "新アイテム"
        // ...
        }
    }
}
```

## 📝 ライセンス

MIT License

## 🤝 コントリビューション

プルリクエストやイシューの報告を歓迎します！

1. このリポジトリをフォーク
2. フィーチャーブランチを作成 (`git checkout -b feature/amazing-feature`)
3. 変更をコミット (`git commit -m 'Add amazing feature'`)
4. ブランチにプッシュ (`git push origin feature/amazing-feature`)
5. プルリクエストを作成

## 📞 お問い合わせ

ご質問やフィードバックがありましたら、Issueを作成してください。
