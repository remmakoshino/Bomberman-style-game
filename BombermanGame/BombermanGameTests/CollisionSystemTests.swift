//
//  CollisionSystemTests.swift
//  BombermanGameTests
//
//  衝突システムのテスト
//

import XCTest
import SpriteKit
@testable import BombermanGame

final class CollisionSystemTests: XCTestCase {
    
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
    
    // MARK: - Grid Distance Tests
    
    func testGridDistanceCalculation() {
        let pos1 = GridPosition(x: 0, y: 0)
        let pos2 = GridPosition(x: 3, y: 4)
        
        let distance = CollisionSystem.gridDistance(from: pos1, to: pos2)
        
        // マンハッタン距離 = |3-0| + |4-0| = 7
        XCTAssertEqual(distance, 7)
    }
    
    func testGridDistanceSamePosition() {
        let pos = GridPosition(x: 5, y: 5)
        
        let distance = CollisionSystem.gridDistance(from: pos, to: pos)
        
        XCTAssertEqual(distance, 0)
    }
    
    // MARK: - Area Check Tests
    
    func testIsInExplosionArea() {
        gridSystem.clearGrid()
        let bombPos = GridPosition(x: 5, y: 5)
        let firePower = 2
        
        // 爆弾の中心は範囲内
        XCTAssertTrue(CollisionSystem.isInExplosionArea(
            position: bombPos,
            bombPosition: bombPos,
            firePower: firePower,
            gridSystem: gridSystem
        ))
        
        // 火力範囲内
        XCTAssertTrue(CollisionSystem.isInExplosionArea(
            position: GridPosition(x: 5, y: 7),
            bombPosition: bombPos,
            firePower: firePower,
            gridSystem: gridSystem
        ))
        
        // 火力範囲外
        XCTAssertFalse(CollisionSystem.isInExplosionArea(
            position: GridPosition(x: 5, y: 8),
            bombPosition: bombPos,
            firePower: firePower,
            gridSystem: gridSystem
        ))
        
        // 斜めは範囲外
        XCTAssertFalse(CollisionSystem.isInExplosionArea(
            position: GridPosition(x: 6, y: 6),
            bombPosition: bombPos,
            firePower: firePower,
            gridSystem: gridSystem
        ))
    }
    
    // MARK: - Safe Zone Tests
    
    func testFindSafeZone() {
        gridSystem.clearGrid()
        
        let bombs: [(position: GridPosition, firePower: Int)] = [
            (GridPosition(x: 5, y: 5), 2)
        ]
        
        let startPos = GridPosition(x: 3, y: 3)
        let safeZone = CollisionSystem.findSafeZone(from: startPos, bombs: bombs, gridSystem: gridSystem)
        
        // 安全な場所が見つかるはず
        XCTAssertNotNil(safeZone)
        
        if let safe = safeZone {
            // 安全な場所は爆発範囲外
            XCTAssertFalse(CollisionSystem.isInExplosionArea(
                position: safe,
                bombPosition: GridPosition(x: 5, y: 5),
                firePower: 2,
                gridSystem: gridSystem
            ))
        }
    }
    
    // MARK: - Rectangle Collision Tests
    
    func testRectanglesIntersect() {
        let rect1 = CGRect(x: 0, y: 0, width: 50, height: 50)
        let rect2 = CGRect(x: 25, y: 25, width: 50, height: 50)
        let rect3 = CGRect(x: 100, y: 100, width: 50, height: 50)
        
        XCTAssertTrue(CollisionSystem.rectanglesIntersect(rect1, rect2))
        XCTAssertFalse(CollisionSystem.rectanglesIntersect(rect1, rect3))
    }
    
    // MARK: - Point Distance Tests
    
    func testPointDistance() {
        let point1 = CGPoint(x: 0, y: 0)
        let point2 = CGPoint(x: 3, y: 4)
        
        let distance = CollisionSystem.pointDistance(from: point1, to: point2)
        
        XCTAssertEqual(distance, 5.0, accuracy: 0.001) // 3-4-5の直角三角形
    }
    
    // MARK: - Closest Grid Position Tests
    
    func testClosestGridPosition() {
        let point = CGPoint(x: 100, y: 150)
        let gridPos = CollisionSystem.closestGridPosition(to: point)
        
        XCTAssertEqual(gridPos, GridPosition.fromPoint(point))
    }
}
