//
//  ConstantsTests.swift
//  BombermanGameTests
//
//  定数のテスト
//

import XCTest
@testable import BombermanGame

final class ConstantsTests: XCTestCase {
    
    // MARK: - Grid Constants Tests
    
    func testGridDimensions() {
        XCTAssertEqual(Constants.gridColumns, 13)
        XCTAssertEqual(Constants.gridRows, 11)
    }
    
    func testTileSize() {
        XCTAssertEqual(Constants.tileSize, 48)
        XCTAssertGreaterThan(Constants.tileSize, 0)
    }
    
    // MARK: - ZPosition Constants Tests
    
    func testZPositionOrdering() {
        // 背景が一番後ろ
        XCTAssertLessThan(Constants.ZPosition.background, Constants.ZPosition.blocks)
        
        // ブロックより爆発が前
        XCTAssertLessThan(Constants.ZPosition.blocks, Constants.ZPosition.explosion)
        
        // アイテムが適切な位置
        XCTAssertLessThan(Constants.ZPosition.item, Constants.ZPosition.player)
        
        // プレイヤーと敵が前面近く
        XCTAssertLessThan(Constants.ZPosition.enemy, Constants.ZPosition.player)
        
        // UIが一番前
        XCTAssertLessThan(Constants.ZPosition.player, Constants.ZPosition.ui)
    }
    
    // MARK: - Physics Category Tests
    
    func testPhysicsCategoriesAreUnique() {
        let categories = [
            Constants.PhysicsCategory.none,
            Constants.PhysicsCategory.player,
            Constants.PhysicsCategory.enemy,
            Constants.PhysicsCategory.bomb,
            Constants.PhysicsCategory.explosion,
            Constants.PhysicsCategory.block,
            Constants.PhysicsCategory.item
        ]
        
        // 各カテゴリがユニーク
        let uniqueCategories = Set(categories)
        XCTAssertEqual(categories.count, uniqueCategories.count)
    }
    
    func testPhysicsCategoriesArePowerOfTwo() {
        // 各カテゴリが2の累乗（ビットマスクとして適切）
        let categories: [UInt32] = [
            Constants.PhysicsCategory.player,
            Constants.PhysicsCategory.enemy,
            Constants.PhysicsCategory.bomb,
            Constants.PhysicsCategory.explosion,
            Constants.PhysicsCategory.block,
            Constants.PhysicsCategory.item
        ]
        
        for category in categories {
            // 2の累乗かチェック: category & (category - 1) == 0
            XCTAssertEqual(category & (category - 1), 0, "Category \(category) should be power of 2")
        }
    }
    
    // MARK: - Notification Name Tests
    
    func testNotificationNamesExist() {
        XCTAssertFalse(Constants.NotificationName.gameOver.isEmpty)
        XCTAssertFalse(Constants.NotificationName.gamePause.isEmpty)
        XCTAssertFalse(Constants.NotificationName.gameResume.isEmpty)
        XCTAssertFalse(Constants.NotificationName.stageCleared.isEmpty)
        XCTAssertFalse(Constants.NotificationName.playerDied.isEmpty)
    }
    
    func testNotificationNamesAreUnique() {
        let names = [
            Constants.NotificationName.gameOver,
            Constants.NotificationName.gamePause,
            Constants.NotificationName.gameResume,
            Constants.NotificationName.stageCleared,
            Constants.NotificationName.playerDied
        ]
        
        let uniqueNames = Set(names)
        XCTAssertEqual(names.count, uniqueNames.count)
    }
}
