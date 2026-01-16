//
//  PlayerTests.swift
//  BombermanGameTests
//
//  プレイヤーのテスト
//

import XCTest
import SpriteKit
@testable import BombermanGame

final class PlayerTests: XCTestCase {
    
    var player: Player!
    var gridSystem: GridSystem!
    
    override func setUp() {
        super.setUp()
        player = Player(playerID: 1)
        gridSystem = GridSystem()
        gridSystem.clearGrid()
    }
    
    override func tearDown() {
        player = nil
        gridSystem = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testPlayerInitialization() {
        XCTAssertEqual(player.playerID, 1)
        XCTAssertEqual(player.lives, GameConfig.shared.initialLives)
        XCTAssertEqual(player.maxBombs, GameConfig.shared.initialBombCount)
        XCTAssertEqual(player.firePower, GameConfig.shared.initialFirePower)
        XCTAssertEqual(player.currentBombs, 0)
        XCTAssertFalse(player.hasRemoteControl)
        XCTAssertFalse(player.canPassWalls)
        XCTAssertFalse(player.canPassBombs)
        XCTAssertFalse(player.isInvincible)
        XCTAssertFalse(player.isDead)
        XCTAssertEqual(player.score, 0)
    }
    
    func testMultiplePlayerIDs() {
        let player1 = Player(playerID: 1)
        let player2 = Player(playerID: 2)
        let player3 = Player(playerID: 3)
        let player4 = Player(playerID: 4)
        
        XCTAssertEqual(player1.playerID, 1)
        XCTAssertEqual(player2.playerID, 2)
        XCTAssertEqual(player3.playerID, 3)
        XCTAssertEqual(player4.playerID, 4)
        
        // 各プレイヤーは異なる色を持つ
        XCTAssertNotEqual(Player.colorForPlayerID(1), Player.colorForPlayerID(2))
        XCTAssertNotEqual(Player.colorForPlayerID(2), Player.colorForPlayerID(3))
    }
    
    // MARK: - Bomb Tests
    
    func testCanPlaceBomb() {
        XCTAssertTrue(player.canPlaceBomb())
    }
    
    func testCannotPlaceBombWhenMaxReached() {
        // 最大数の爆弾を設置
        for _ in 0..<player.maxBombs {
            _ = player.placeBomb()
        }
        
        XCTAssertFalse(player.canPlaceBomb())
    }
    
    func testPlaceBomb() {
        let bomb = player.placeBomb()
        
        XCTAssertNotNil(bomb)
        XCTAssertEqual(player.currentBombs, 1)
        XCTAssertEqual(player.placedBombs.count, 1)
    }
    
    func testBombFirePowerMatchesPlayer() {
        player.firePower = 3
        
        let bomb = player.placeBomb()
        
        XCTAssertEqual(bomb?.firePower, 3)
    }
    
    func testOnBombExploded() {
        let bomb = player.placeBomb()!
        
        player.onBombExploded(bomb)
        
        XCTAssertEqual(player.currentBombs, 0)
        XCTAssertEqual(player.placedBombs.count, 0)
    }
    
    func testCannotPlaceBombWhenDead() {
        player.die()
        
        XCTAssertFalse(player.canPlaceBomb())
        XCTAssertNil(player.placeBomb())
    }
    
    // MARK: - Item Collection Tests
    
    func testCollectFireUpItem() {
        let initialFirePower = player.firePower
        
        player.collectItem(.fireUp)
        
        XCTAssertEqual(player.firePower, initialFirePower + 1)
    }
    
    func testCollectBombUpItem() {
        let initialMaxBombs = player.maxBombs
        
        player.collectItem(.bombUp)
        
        XCTAssertEqual(player.maxBombs, initialMaxBombs + 1)
    }
    
    func testCollectSpeedUpItem() {
        let initialSpeed = player.moveSpeed
        
        player.collectItem(.speedUp)
        
        XCTAssertGreaterThan(player.moveSpeed, initialSpeed)
    }
    
    func testCollectRemoteControlItem() {
        XCTAssertFalse(player.hasRemoteControl)
        
        player.collectItem(.remoteControl)
        
        XCTAssertTrue(player.hasRemoteControl)
    }
    
    func testCollectWallPassItem() {
        XCTAssertFalse(player.canPassWalls)
        
        player.collectItem(.wallPass)
        
        XCTAssertTrue(player.canPassWalls)
    }
    
    func testCollectBombPassItem() {
        XCTAssertFalse(player.canPassBombs)
        
        player.collectItem(.bombPass)
        
        XCTAssertTrue(player.canPassBombs)
    }
    
    func testCollectInvincibleItem() {
        XCTAssertFalse(player.isInvincible)
        
        player.collectItem(.invincible)
        
        XCTAssertTrue(player.isInvincible)
    }
    
    func testFirePowerMaxLimit() {
        let config = GameConfig.shared
        
        // 最大値以上にはならない
        for _ in 0..<10 {
            player.collectItem(.fireUp)
        }
        
        XCTAssertLessThanOrEqual(player.firePower, config.maxFirePower)
    }
    
    func testBombCountMaxLimit() {
        let config = GameConfig.shared
        
        // 最大値以上にはならない
        for _ in 0..<15 {
            player.collectItem(.bombUp)
        }
        
        XCTAssertLessThanOrEqual(player.maxBombs, config.maxBombCount)
    }
    
    func testSpeedMaxLimit() {
        let config = GameConfig.shared
        
        // 最大値以上にはならない
        for _ in 0..<20 {
            player.collectItem(.speedUp)
        }
        
        XCTAssertLessThanOrEqual(player.moveSpeed, config.playerMaxSpeed)
    }
    
    // MARK: - Damage Tests
    
    func testTakeDamageReducesLives() {
        let initialLives = player.lives
        
        player.takeDamage()
        
        XCTAssertEqual(player.lives, initialLives - 1)
    }
    
    func testTakeDamageWhileInvincible() {
        player.isInvincible = true
        let initialLives = player.lives
        
        player.takeDamage()
        
        XCTAssertEqual(player.lives, initialLives) // ダメージを受けない
    }
    
    func testDieWhenLivesReachZero() {
        player.lives = 1
        
        player.takeDamage()
        
        XCTAssertTrue(player.isDead)
        XCTAssertEqual(player.lives, 0)
    }
    
    func testDie() {
        player.die()
        
        XCTAssertTrue(player.isDead)
    }
    
    func testRespawn() {
        player.die()
        let respawnPosition = GridPosition(x: 1, y: 1)
        
        player.respawn(at: respawnPosition)
        
        XCTAssertFalse(player.isDead)
        XCTAssertEqual(player.gridPosition, respawnPosition)
    }
    
    // MARK: - Reset Tests
    
    func testReset() {
        // プレイヤーの状態を変更
        player.firePower = 5
        player.maxBombs = 8
        player.hasRemoteControl = true
        player.canPassWalls = true
        player.score = 1000
        
        player.reset()
        
        XCTAssertEqual(player.firePower, GameConfig.shared.initialFirePower)
        XCTAssertEqual(player.maxBombs, GameConfig.shared.initialBombCount)
        XCTAssertFalse(player.hasRemoteControl)
        XCTAssertFalse(player.canPassWalls)
        XCTAssertEqual(player.score, 0)
    }
    
    // MARK: - Movement Tests
    
    func testStartMoving() {
        player.startMoving(in: .up)
        
        XCTAssertEqual(player.moveDirection, .up)
    }
    
    func testStopMoving() {
        player.startMoving(in: .up)
        player.stopMoving()
        
        XCTAssertNil(player.moveDirection)
    }
}
