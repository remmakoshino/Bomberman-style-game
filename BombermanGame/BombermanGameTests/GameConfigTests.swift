//
//  GameConfigTests.swift
//  BombermanGameTests
//
//  ゲーム設定のテスト
//

import XCTest
@testable import BombermanGame

final class GameConfigTests: XCTestCase {
    
    var config: GameConfig!
    
    override func setUp() {
        super.setUp()
        config = GameConfig.shared
        config.resetToDefaults()
    }
    
    override func tearDown() {
        config.resetToDefaults()
        super.tearDown()
    }
    
    // MARK: - Singleton Tests
    
    func testSingletonInstance() {
        let instance1 = GameConfig.shared
        let instance2 = GameConfig.shared
        
        XCTAssertTrue(instance1 === instance2)
    }
    
    // MARK: - Default Values Tests
    
    func testDefaultDifficulty() {
        XCTAssertEqual(config.currentDifficulty, .normal)
    }
    
    func testDefaultPlayerSettings() {
        XCTAssertEqual(config.initialLives, 3)
        XCTAssertEqual(config.initialBombCount, 1)
        XCTAssertEqual(config.initialFirePower, 1)
    }
    
    func testMaxLimits() {
        XCTAssertEqual(config.maxBombCount, 8)
        XCTAssertEqual(config.maxFirePower, 8)
        XCTAssertGreaterThan(config.playerMaxSpeed, config.playerSpeed)
    }
    
    func testBombSettings() {
        XCTAssertEqual(config.bombFuseTime, 3.0, accuracy: 0.001)
        XCTAssertGreaterThan(config.explosionDuration, 0)
    }
    
    // MARK: - Difficulty Tests
    
    func testEasyDifficulty() {
        config.currentDifficulty = .easy
        
        XCTAssertEqual(config.initialLives, 5)
        XCTAssertEqual(config.initialBombCount, 2)
        XCTAssertEqual(config.initialFirePower, 2)
        XCTAssertGreaterThan(config.itemDropRate, 0.5)
    }
    
    func testNormalDifficulty() {
        config.currentDifficulty = .normal
        
        XCTAssertEqual(config.initialLives, 3)
        XCTAssertEqual(config.initialBombCount, 1)
        XCTAssertEqual(config.initialFirePower, 1)
    }
    
    func testHardDifficulty() {
        config.currentDifficulty = .hard
        
        XCTAssertEqual(config.initialLives, 2)
        XCTAssertEqual(config.initialBombCount, 1)
        XCTAssertEqual(config.initialFirePower, 1)
        XCTAssertLessThan(config.itemDropRate, 0.3)
    }
    
    func testExpertDifficulty() {
        config.currentDifficulty = .expert
        
        XCTAssertEqual(config.initialLives, 1)
        XCTAssertLessThan(config.itemDropRate, 0.2)
    }
    
    // MARK: - Item Drop Weight Tests
    
    func testItemDropWeightsArePositive() {
        for (_, weight) in config.itemDropWeights {
            XCTAssertGreaterThan(weight, 0)
        }
    }
    
    func testAllItemTypesHaveWeights() {
        for itemType in ItemType.allCases {
            XCTAssertNotNil(config.itemDropWeights[itemType])
        }
    }
    
    // MARK: - Reset Tests
    
    func testResetToDefaults() {
        // 設定を変更
        config.currentDifficulty = .expert
        
        // リセット
        config.resetToDefaults()
        
        XCTAssertEqual(config.currentDifficulty, .normal)
    }
    
    // MARK: - Difficulty Enum Tests
    
    func testDifficultyDisplayName() {
        XCTAssertEqual(Difficulty.easy.displayName, "イージー")
        XCTAssertEqual(Difficulty.normal.displayName, "ノーマル")
        XCTAssertEqual(Difficulty.hard.displayName, "ハード")
        XCTAssertEqual(Difficulty.expert.displayName, "エキスパート")
    }
    
    func testAllDifficultiesExist() {
        XCTAssertEqual(Difficulty.allCases.count, 4)
    }
}
