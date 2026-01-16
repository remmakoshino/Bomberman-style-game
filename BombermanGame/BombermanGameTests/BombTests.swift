//
//  BombTests.swift
//  BombermanGameTests
//
//  爆弾のテスト
//

import XCTest
import SpriteKit
@testable import BombermanGame

final class BombTests: XCTestCase {
    
    var player: Player!
    var bomb: Bomb!
    
    override func setUp() {
        super.setUp()
        player = Player(playerID: 1)
        bomb = Bomb(owner: player, firePower: 2, isRemote: false)
    }
    
    override func tearDown() {
        player = nil
        bomb = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testBombInitialization() {
        XCTAssertNotNil(bomb.bombID)
        XCTAssertEqual(bomb.firePower, 2)
        XCTAssertFalse(bomb.isRemote)
        XCTAssertFalse(bomb.hasExploded)
        XCTAssertEqual(bomb.fuseTime, GameConfig.shared.bombFuseTime, accuracy: 0.001)
    }
    
    func testRemoteBombInitialization() {
        let remoteBomb = Bomb(owner: player, firePower: 3, isRemote: true)
        
        XCTAssertTrue(remoteBomb.isRemote)
        XCTAssertEqual(remoteBomb.firePower, 3)
    }
    
    func testBombOwner() {
        XCTAssertTrue(bomb.owner === player)
    }
    
    // MARK: - Explosion Tests
    
    func testExplode() {
        var exploded = false
        bomb.onExplode = { _ in
            exploded = true
        }
        
        bomb.explode()
        
        XCTAssertTrue(bomb.hasExploded)
        XCTAssertTrue(exploded)
    }
    
    func testExplodeOnlyOnce() {
        var explodeCount = 0
        bomb.onExplode = { _ in
            explodeCount += 1
        }
        
        bomb.explode()
        bomb.explode()
        bomb.explode()
        
        XCTAssertEqual(explodeCount, 1)
    }
    
    func testChainExplode() {
        var exploded = false
        bomb.onExplode = { _ in
            exploded = true
        }
        
        // 遅延なしで連鎖爆発
        bomb.chainExplode(delay: 0)
        
        // 即座には爆発しない（SKActionによる遅延があるため）
        // 実際のテストではrunLoopを進める必要がある
        XCTAssertFalse(bomb.hasExploded)
    }
    
    // MARK: - Grid Position Tests
    
    func testBombGridPosition() {
        bomb.position = CGPoint(x: 120, y: 200)
        
        let expectedGridPos = GridPosition.fromPoint(bomb.position)
        
        XCTAssertEqual(bomb.gridPosition, expectedGridPos)
    }
    
    // MARK: - Update Tests
    
    func testFuseTimeDecreases() {
        let initialFuseTime = bomb.fuseTime
        
        bomb.update(deltaTime: 1.0)
        
        XCTAssertEqual(bomb.fuseTime, initialFuseTime - 1.0, accuracy: 0.001)
    }
    
    func testRemoteBombFuseTimeDoesNotDecrease() {
        let remoteBomb = Bomb(owner: player, firePower: 2, isRemote: true)
        let initialFuseTime = remoteBomb.fuseTime
        
        remoteBomb.update(deltaTime: 1.0)
        
        // リモート爆弾はタイマーで減らない
        XCTAssertEqual(remoteBomb.fuseTime, initialFuseTime, accuracy: 0.001)
    }
}
