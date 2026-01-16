//
//  GameManager.swift
//  BombermanGame
//
//  ゲーム全体の管理
//

import Foundation
import SpriteKit

/// ゲームマネージャー - ゲーム全体の状態管理
final class GameManager {
    
    // MARK: - Properties
    
    /// シングルトンインスタンス（オプション）
    private(set) static var shared: GameManager?
    
    /// 現在のゲームシーン
    weak var scene: GameScene?
    
    /// グリッドシステム
    let gridSystem: GridSystem
    
    /// 現在のステージ
    private(set) var currentStage: Int = 1
    
    /// ゲーム状態
    private(set) var state: GameState = .menu
    
    /// ハイスコア
    private(set) var highScore: Int = 0
    
    /// ゲーム開始時間
    private var gameStartTime: Date?
    
    /// プレイ時間
    var playTime: TimeInterval {
        guard let startTime = gameStartTime else { return 0 }
        return Date().timeIntervalSince(startTime)
    }
    
    // MARK: - Callbacks
    
    /// 状態変更コールバック
    var onStateChanged: ((GameState) -> Void)?
    
    /// ステージクリアコールバック
    var onStageClear: ((Int) -> Void)?
    
    /// ゲームオーバーコールバック
    var onGameOver: ((Int) -> Void)?
    
    // MARK: - Initialization
    
    init(scene: GameScene, gridSystem: GridSystem) {
        self.scene = scene
        self.gridSystem = gridSystem
        
        loadHighScore()
        
        GameManager.shared = self
    }
    
    // MARK: - Game Flow
    
    /// ゲームを開始
    func startGame() {
        currentStage = 1
        gameStartTime = Date()
        state = .playing
        
        onStateChanged?(.playing)
    }
    
    /// ゲームを一時停止
    func pauseGame() {
        guard state == .playing else { return }
        state = .paused
        
        onStateChanged?(.paused)
    }
    
    /// ゲームを再開
    func resumeGame() {
        guard state == .paused else { return }
        state = .playing
        
        onStateChanged?(.playing)
    }
    
    /// 次のステージに進む
    func advanceToNextStage() {
        currentStage += 1
        
        onStageClear?(currentStage - 1)
    }
    
    /// ゲームオーバー
    func endGame(score: Int) {
        state = .gameOver
        
        // ハイスコア更新
        if score > highScore {
            highScore = score
            saveHighScore()
        }
        
        onGameOver?(score)
        onStateChanged?(.gameOver)
    }
    
    /// ゲームをリセット
    func resetGame() {
        currentStage = 1
        gameStartTime = nil
        state = .menu
        
        onStateChanged?(.menu)
    }
    
    // MARK: - Stage Management
    
    /// ステージの敵数を取得
    func getEnemyCount(for stage: Int) -> Int {
        return min(3 + stage, 10)
    }
    
    /// ステージのAIレベルを取得
    func getAILevel(for stage: Int) -> Int {
        return min(1 + stage / 3, 5)
    }
    
    /// ステージのソフトブロック密度を取得
    func getSoftBlockDensity(for stage: Int) -> Double {
        // 後半ステージほど密度を下げる
        return max(0.4, 0.7 - Double(stage) * 0.02)
    }
    
    // MARK: - Score Management
    
    /// ハイスコアを保存
    private func saveHighScore() {
        UserDefaults.standard.set(highScore, forKey: "highScore")
    }
    
    /// ハイスコアを読み込み
    private func loadHighScore() {
        highScore = UserDefaults.standard.integer(forKey: "highScore")
    }
    
    // MARK: - Statistics
    
    /// ゲーム統計を取得
    func getStatistics() -> GameStatistics {
        return GameStatistics(
            currentStage: currentStage,
            highScore: highScore,
            playTime: playTime
        )
    }
}

// MARK: - Game Statistics

/// ゲーム統計
struct GameStatistics {
    let currentStage: Int
    let highScore: Int
    let playTime: TimeInterval
    
    var formattedPlayTime: String {
        return playTime.formattedTime
    }
}
