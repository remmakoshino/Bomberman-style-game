//
//  GameConfig.swift
//  BombermanGame
//
//  ゲームバランス調整用の設定パラメータ
//

import Foundation
import CoreGraphics

/// ゲームバランス調整用の設定
/// 各パラメータは実行時に変更可能で、ゲームバランスの調整が容易
final class GameConfig {
    
    // MARK: - Singleton
    
    static let shared = GameConfig()
    
    private init() {
        loadDefaultSettings()
    }
    
    // MARK: - Player Settings
    
    /// プレイヤーの基本移動速度（マス/秒）
    var playerBaseSpeed: CGFloat = Constants.playerBaseSpeed
    
    /// プレイヤーの最大移動速度
    var playerMaxSpeed: CGFloat = Constants.playerMaxSpeed
    
    /// スピードアップ1回あたりの増加量
    var speedUpIncrement: CGFloat = Constants.speedUpIncrement
    
    /// 初期爆弾所持数
    var initialBombCount: Int = Constants.playerInitialBombCount
    
    /// 最大爆弾所持数
    var maxBombCount: Int = Constants.playerMaxBombCount
    
    /// 初期火力（爆風範囲）
    var initialFirePower: Int = Constants.playerInitialFirePower
    
    /// 最大火力
    var maxFirePower: Int = Constants.playerMaxFirePower
    
    /// 初期残機
    var initialLives: Int = Constants.playerInitialLives
    
    // MARK: - Bomb Settings
    
    /// 爆弾の爆発までの時間（秒）
    var bombFuseTime: TimeInterval = Constants.bombFuseTime
    
    /// 爆風の持続時間（秒）
    var explosionDuration: TimeInterval = Constants.explosionDuration
    
    /// 連鎖爆発の遅延時間（秒）
    var chainExplosionDelay: TimeInterval = Constants.chainExplosionDelay
    
    // MARK: - Item Settings
    
    /// アイテムドロップ確率（0.0 - 1.0）
    var itemDropRate: Double = Constants.itemDropRate
    
    /// 各アイテムのドロップ重み
    var itemDropWeights: [ItemType: Double] = [
        .fireUp: 1.0,
        .bombUp: 1.0,
        .speedUp: 0.8,
        .remoteControl: 0.3,
        .wallPass: 0.2,
        .bombPass: 0.3,
        .invincible: 0.1
    ]
    
    /// 無敵時間（秒）
    var invincibilityDuration: TimeInterval = Constants.invincibilityDuration
    
    // MARK: - Enemy Settings
    
    /// 敵の基本移動速度
    var enemyBaseSpeed: CGFloat = Constants.enemyBaseSpeed
    
    /// 敵の方向転換間隔（秒）
    var enemyDirectionChangeInterval: TimeInterval = Constants.enemyDirectionChangeInterval
    
    /// 敵のAIレベル（1-5、高いほど賢い）
    var enemyAILevel: Int = 1
    
    // MARK: - Stage Settings
    
    /// ソフトブロックの密度（0.0 - 1.0）
    var softBlockDensity: Double = 0.6
    
    /// ステージクリアボーナス
    var stageClearBonus: Int = 1000
    
    /// 敵撃破ボーナス
    var enemyDefeatBonus: Int = 100
    
    // MARK: - Difficulty Presets
    
    /// 難易度設定
    enum Difficulty: String, CaseIterable {
        case easy = "Easy"
        case normal = "Normal"
        case hard = "Hard"
        case expert = "Expert"
    }
    
    /// 現在の難易度
    var currentDifficulty: Difficulty = .normal {
        didSet {
            applyDifficultySettings()
        }
    }
    
    // MARK: - Methods
    
    /// デフォルト設定の読み込み
    private func loadDefaultSettings() {
        applyDifficultySettings()
    }
    
    /// 難易度に応じた設定の適用
    private func applyDifficultySettings() {
        switch currentDifficulty {
        case .easy:
            playerBaseSpeed = 3.5
            initialBombCount = 2
            initialFirePower = 2
            initialLives = 5
            bombFuseTime = 3.5
            itemDropRate = 0.4
            enemyBaseSpeed = 1.0
            enemyAILevel = 1
            
        case .normal:
            playerBaseSpeed = 3.0
            initialBombCount = 1
            initialFirePower = 1
            initialLives = 3
            bombFuseTime = 3.0
            itemDropRate = 0.3
            enemyBaseSpeed = 1.5
            enemyAILevel = 2
            
        case .hard:
            playerBaseSpeed = 2.8
            initialBombCount = 1
            initialFirePower = 1
            initialLives = 2
            bombFuseTime = 2.5
            itemDropRate = 0.25
            enemyBaseSpeed = 2.0
            enemyAILevel = 3
            
        case .expert:
            playerBaseSpeed = 2.5
            initialBombCount = 1
            initialFirePower = 1
            initialLives = 1
            bombFuseTime = 2.0
            itemDropRate = 0.2
            enemyBaseSpeed = 2.5
            enemyAILevel = 4
        }
    }
    
    /// 設定をリセット
    func resetToDefaults() {
        currentDifficulty = .normal
    }
    
    /// 設定を保存
    func saveSettings() {
        let defaults = UserDefaults.standard
        defaults.set(currentDifficulty.rawValue, forKey: "difficulty")
        // 必要に応じて他の設定も保存
    }
    
    /// 設定を読み込み
    func loadSettings() {
        let defaults = UserDefaults.standard
        if let difficultyRaw = defaults.string(forKey: "difficulty"),
           let difficulty = Difficulty(rawValue: difficultyRaw) {
            currentDifficulty = difficulty
        }
    }
}

// MARK: - Item Type

/// アイテムの種類
enum ItemType: String, CaseIterable {
    case fireUp = "FireUp"           // 火力アップ
    case bombUp = "BombUp"           // 爆弾数アップ
    case speedUp = "SpeedUp"         // スピードアップ
    case remoteControl = "Remote"    // リモコン爆弾
    case wallPass = "WallPass"       // 壁すり抜け
    case bombPass = "BombPass"       // 爆弾すり抜け
    case invincible = "Invincible"   // 無敵
    
    /// アイテムの表示名
    var displayName: String {
        switch self {
        case .fireUp: return "火力UP"
        case .bombUp: return "爆弾UP"
        case .speedUp: return "スピードUP"
        case .remoteControl: return "リモコン"
        case .wallPass: return "壁抜け"
        case .bombPass: return "爆弾抜け"
        case .invincible: return "無敵"
        }
    }
    
    /// アイテムの色（16進数）
    var colorHex: String {
        switch self {
        case .fireUp: return "#E74C3C"
        case .bombUp: return "#9B59B6"
        case .speedUp: return "#3498DB"
        case .remoteControl: return "#1ABC9C"
        case .wallPass: return "#F39C12"
        case .bombPass: return "#95A5A6"
        case .invincible: return "#F1C40F"
        }
    }
}
