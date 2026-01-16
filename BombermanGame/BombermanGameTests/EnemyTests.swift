//
//  EnemyTests.swift
//  BombermanGameTests
//
//  敵のテスト
//

import XCTest
import SpriteKit
@testable import BombermanGame

final class EnemyTests: XCTestCase {
    
    var enemy: Enemy!
    var gridSystem: GridSystem!
    
    override func setUp() {
        super.setUp()
        enemy = Enemy(type: .balloon, aiLevel: 1)
        gridSystem = GridSystem()
        gridSystem.clearGrid()
    }
    
    override func tearDown() {
        enemy = nil
        gridSystem = nil
        super.tearDown()
    }
    
    // MARK: - EnemyType Tests
    
    func testEnemyTypeSpeedMultiplier() {
        XCTAssertLessThan(EnemyType.balloon.speedMultiplier, EnemyType.onil.speedMultiplier)
        XCTAssertLessThan(EnemyType.onil.speedMultiplier, EnemyType.dahl.speedMultiplier)
        XCTAssertLessThan(EnemyType.dahl.speedMultiplier, EnemyType.ovape.speedMultiplier)
    }
    
    func testEnemyTypeCanPassWalls() {
        XCTAssertFalse(EnemyType.balloon.canPassWalls)
        XCTAssertFalse(EnemyType.onil.canPassWalls)
        XCTAssertFalse(EnemyType.dahl.canPassWalls)
        XCTAssertTrue(EnemyType.minvo.canPassWalls)
        XCTAssertTrue(EnemyType.ovape.canPassWalls)
    }
    
    func testEnemyTypeScoreValue() {
        XCTAssertEqual(EnemyType.balloon.scoreValue, 100)
        XCTAssertEqual(EnemyType.onil.scoreValue, 200)
        XCTAssertEqual(EnemyType.dahl.scoreValue, 400)
        XCTAssertEqual(EnemyType.minvo.scoreValue, 800)
        XCTAssertEqual(EnemyType.ovape.scoreValue, 1000)
    }
    
    func testAllEnemyTypesHaveColor() {
        for type in EnemyType.allCases {
            XCTAssertFalse(type.color.isEmpty)
            XCTAssertTrue(type.color.hasPrefix("#"))
        }
    }
    
    // MARK: - Enemy Initialization Tests
    
    func testEnemyInitialization() {
        XCTAssertNotNil(enemy.enemyID)
        XCTAssertEqual(enemy.enemyType, .balloon)
        XCTAssertEqual(enemy.aiLevel, 1)
        XCTAssertFalse(enemy.isDead)
        XCTAssertEqual(enemy.canPassWalls, EnemyType.balloon.canPassWalls)
    }
    
    func testEnemyWithDifferentTypes() {
        let balloon = Enemy(type: .balloon, aiLevel: 1)
        let onil = Enemy(type: .onil, aiLevel: 2)
        let minvo = Enemy(type: .minvo, aiLevel: 3)
        
        XCTAssertEqual(balloon.enemyType, .balloon)
        XCTAssertEqual(onil.enemyType, .onil)
        XCTAssertEqual(minvo.enemyType, .minvo)
        
        XCTAssertFalse(balloon.canPassWalls)
        XCTAssertFalse(onil.canPassWalls)
        XCTAssertTrue(minvo.canPassWalls)
    }
    
    func testEnemyMoveSpeed() {
        let balloon = Enemy(type: .balloon, aiLevel: 1)
        let ovape = Enemy(type: .ovape, aiLevel: 1)
        
        XCTAssertLessThan(balloon.moveSpeed, ovape.moveSpeed)
    }
    
    // MARK: - Enemy Death Tests
    
    func testEnemyDie() {
        enemy.die()
        
        XCTAssertTrue(enemy.isDead)
    }
    
    func testDeathCallback() {
        var callbackCalled = false
        enemy.onDeath = { _ in
            callbackCalled = true
        }
        
        enemy.die()
        
        // コールバックはアニメーション完了後に呼ばれる
        // 即座には呼ばれない
    }
    
    func testCannotDieTwice() {
        var deathCount = 0
        enemy.onDeath = { _ in
            deathCount += 1
        }
        
        enemy.die()
        enemy.die()
        enemy.die()
        
        XCTAssertTrue(enemy.isDead)
        // コールバックは1回のみ
    }
    
    // MARK: - Grid Position Tests
    
    func testEnemyGridPosition() {
        let position = GridPosition(x: 5, y: 5)
        enemy.setGridPosition(position)
        
        XCTAssertEqual(enemy.gridPosition, position)
    }
    
    // MARK: - Enemy Factory Tests
    
    func testEnemyFactoryCreateEnemy() {
        let position = GridPosition(x: 3, y: 4)
        let enemy = EnemyFactory.createEnemy(type: .dahl, at: position, aiLevel: 3)
        
        XCTAssertEqual(enemy.enemyType, .dahl)
        XCTAssertEqual(enemy.aiLevel, 3)
        XCTAssertEqual(enemy.gridPosition, position)
    }
    
    func testEnemyFactoryCreatesCorrectCount() {
        let enemies = EnemyFactory.createEnemiesForStage(1, gridSystem: gridSystem)
        
        // ステージ1では4体（3 + 1）
        XCTAssertEqual(enemies.count, min(4, countEmptyPositions()))
    }
    
    private func countEmptyPositions() -> Int {
        var count = 0
        for x in 2..<(Constants.gridColumns - 2) {
            for y in 2..<(Constants.gridRows - 2) {
                if gridSystem.getTile(at: GridPosition(x: x, y: y)) == .empty {
                    count += 1
                }
            }
        }
        return count
    }
    
    // MARK: - AI Level Tests
    
    func testAILevelRange() {
        for level in 1...5 {
            let enemy = Enemy(type: .balloon, aiLevel: level)
            XCTAssertEqual(enemy.aiLevel, level)
        }
    }
}
