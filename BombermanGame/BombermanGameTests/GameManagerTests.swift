//
//  GameManagerTests.swift
//  BombermanGameTests
//
//  ゲームマネージャーのテスト
//

import XCTest
@testable import BombermanGame

final class GameManagerTests: XCTestCase {
    
    var gridSystem: GridSystem!
    
    override func setUp() {
        super.setUp()
        gridSystem = GridSystem()
    }
    
    override func tearDown() {
        gridSystem = nil
        super.tearDown()
    }
    
    // MARK: - Stage Tests
    
    func testGetEnemyCountForStage() {
        // Stage 1: 4 enemies (3 + 1)
        XCTAssertEqual(getEnemyCount(for: 1), 4)
        
        // Stage 5: 8 enemies (3 + 5)
        XCTAssertEqual(getEnemyCount(for: 5), 8)
        
        // Stage 10: Max 10 enemies
        XCTAssertEqual(getEnemyCount(for: 10), 10)
        
        // Stage 20: Still max 10
        XCTAssertEqual(getEnemyCount(for: 20), 10)
    }
    
    func testGetAILevelForStage() {
        // Stage 1-2: AI Level 1
        XCTAssertEqual(getAILevel(for: 1), 1)
        XCTAssertEqual(getAILevel(for: 2), 1)
        
        // Stage 3-5: AI Level 2
        XCTAssertEqual(getAILevel(for: 3), 2)
        XCTAssertEqual(getAILevel(for: 5), 2)
        
        // Stage 15+: Max AI Level 5
        XCTAssertEqual(getAILevel(for: 15), 5)
    }
    
    // MARK: - Helper Methods
    
    private func getEnemyCount(for stage: Int) -> Int {
        return min(3 + stage, 10)
    }
    
    private func getAILevel(for stage: Int) -> Int {
        return min(1 + stage / 3, 5)
    }
    
    // MARK: - Game State Tests
    
    func testGameStateTransitions() {
        XCTAssertTrue(GameState.playing.isActive)
        XCTAssertFalse(GameState.paused.isActive)
        XCTAssertFalse(GameState.menu.isActive)
        XCTAssertFalse(GameState.gameOver.isActive)
    }
    
    func testGameStateAcceptsInput() {
        XCTAssertTrue(GameState.playing.acceptsInput)
        XCTAssertTrue(GameState.menu.acceptsInput)
        XCTAssertTrue(GameState.paused.acceptsInput)
        XCTAssertFalse(GameState.gameOver.acceptsInput)
    }
    
    func testGameStateIsEnded() {
        XCTAssertTrue(GameState.gameOver.isGameEnded)
        XCTAssertTrue(GameState.victory.isGameEnded)
        XCTAssertFalse(GameState.playing.isGameEnded)
        XCTAssertFalse(GameState.paused.isGameEnded)
    }
    
    // MARK: - Stage Info Tests
    
    func testStageFactoryCreatesValidStage() {
        let stage1 = StageFactory.createStage(1)
        
        XCTAssertEqual(stage1.stageNumber, 1)
        XCTAssertGreaterThan(stage1.enemyCount, 0)
        XCTAssertGreaterThan(stage1.enemyTypes.count, 0)
        XCTAssertGreaterThanOrEqual(stage1.aiLevel, 1)
        XCTAssertLessThanOrEqual(stage1.aiLevel, 5)
        XCTAssertGreaterThan(stage1.softBlockDensity, 0)
        XCTAssertLessThanOrEqual(stage1.softBlockDensity, 1)
    }
    
    func testStageDisplayName() {
        let stage5 = StageFactory.createStage(5)
        XCTAssertEqual(stage5.displayName, "Stage 5")
    }
    
    func testStageDifficultyStars() {
        let stage1 = StageFactory.createStage(1)
        XCTAssertEqual(stage1.difficultyStars, "★☆☆☆☆")
        
        let stage3 = StageFactory.createStage(3)
        XCTAssertEqual(stage3.difficultyStars, "★★★☆☆")
        
        let stage5 = StageFactory.createStage(5)
        XCTAssertEqual(stage5.difficultyStars, "★★★★★")
        
        let stage10 = StageFactory.createStage(10)
        XCTAssertEqual(stage10.difficultyStars, "★★★★★")
    }
    
    // MARK: - GameConfig Tests
    
    func testGameConfigDifficultySettings() {
        let config = GameConfig.shared
        
        // Test Normal difficulty
        config.currentDifficulty = .normal
        XCTAssertEqual(config.initialLives, 3)
        XCTAssertEqual(config.initialBombCount, 1)
        XCTAssertEqual(config.initialFirePower, 1)
        
        // Test Easy difficulty
        config.currentDifficulty = .easy
        XCTAssertEqual(config.initialLives, 5)
        XCTAssertEqual(config.initialBombCount, 2)
        XCTAssertEqual(config.initialFirePower, 2)
        
        // Test Hard difficulty
        config.currentDifficulty = .hard
        XCTAssertEqual(config.initialLives, 2)
        
        // Reset to normal
        config.resetToDefaults()
        XCTAssertEqual(config.currentDifficulty, .normal)
    }
}
