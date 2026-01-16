//
//  GameState.swift
//  BombermanGame
//
//  ゲーム状態の定義
//

import Foundation

/// ゲームの状態
enum GameState: String {
    case menu = "Menu"
    case playing = "Playing"
    case paused = "Paused"
    case stageCleared = "Stage Cleared"
    case gameOver = "Game Over"
    case victory = "Victory"
    
    /// ゲームがアクティブかどうか
    var isActive: Bool {
        return self == .playing
    }
    
    /// ユーザー入力を受け付けるかどうか
    var acceptsInput: Bool {
        switch self {
        case .playing:
            return true
        case .menu, .paused:
            return true // メニュー操作は可能
        default:
            return false
        }
    }
    
    /// ゲームが終了したかどうか
    var isGameEnded: Bool {
        return self == .gameOver || self == .victory
    }
}

// MARK: - Game Mode

/// ゲームモード
enum GameMode: String, CaseIterable {
    case singlePlayer = "Single Player"
    case localMultiplayer = "Local Multiplayer"
    case stageMode = "Stage Mode"
    case survival = "Survival"
    
    /// モードの説明
    var description: String {
        switch self {
        case .singlePlayer:
            return "AIと対戦"
        case .localMultiplayer:
            return "2-4人でローカル対戦"
        case .stageMode:
            return "ステージをクリアして進む"
        case .survival:
            return "できるだけ長く生き残れ"
        }
    }
    
    /// プレイヤー数
    var playerCount: ClosedRange<Int> {
        switch self {
        case .singlePlayer, .stageMode, .survival:
            return 1...1
        case .localMultiplayer:
            return 2...4
        }
    }
}

// MARK: - Round Result

/// ラウンド結果
struct RoundResult {
    let winner: Int? // プレイヤーID（nilの場合は引き分け）
    let scores: [Int: Int] // プレイヤーID: スコア
    let duration: TimeInterval
    let enemiesDefeated: Int
    let blocksDestroyed: Int
    let itemsCollected: Int
}

// MARK: - Stage Info

/// ステージ情報
struct StageInfo {
    let stageNumber: Int
    let enemyCount: Int
    let enemyTypes: [EnemyType]
    let aiLevel: Int
    let softBlockDensity: Double
    let timeLimit: TimeInterval?
    
    /// ステージ名
    var displayName: String {
        return "Stage \(stageNumber)"
    }
    
    /// 難易度表示
    var difficultyStars: String {
        let stars = min(stageNumber, 5)
        return String(repeating: "★", count: stars) + String(repeating: "☆", count: 5 - stars)
    }
}

// MARK: - Stage Factory

/// ステージ情報のファクトリー
enum StageFactory {
    
    /// ステージ番号からステージ情報を生成
    static func createStage(_ number: Int) -> StageInfo {
        return StageInfo(
            stageNumber: number,
            enemyCount: calculateEnemyCount(for: number),
            enemyTypes: calculateEnemyTypes(for: number),
            aiLevel: calculateAILevel(for: number),
            softBlockDensity: calculateSoftBlockDensity(for: number),
            timeLimit: calculateTimeLimit(for: number)
        )
    }
    
    private static func calculateEnemyCount(for stage: Int) -> Int {
        return min(3 + stage, 10)
    }
    
    private static func calculateEnemyTypes(for stage: Int) -> [EnemyType] {
        switch stage {
        case 1...2:
            return [.balloon]
        case 3...4:
            return [.balloon, .onil]
        case 5...6:
            return [.balloon, .onil, .dahl]
        case 7...8:
            return [.onil, .dahl, .minvo]
        default:
            return EnemyType.allCases
        }
    }
    
    private static func calculateAILevel(for stage: Int) -> Int {
        return min(1 + stage / 3, 5)
    }
    
    private static func calculateSoftBlockDensity(for stage: Int) -> Double {
        return max(0.4, 0.7 - Double(stage) * 0.02)
    }
    
    private static func calculateTimeLimit(for stage: Int) -> TimeInterval? {
        // ステージ5以降は制限時間あり
        if stage >= 5 {
            return TimeInterval(180 - (stage - 5) * 10).clamped(to: 60...180)
        }
        return nil
    }
}
