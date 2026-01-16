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
        XCTAssertLessThan(Constants.zPositionBackground, Constants.zPositionBlock)
        
        // ブロックよりアイテムが前
        XCTAssertLessThan(Constants.zPositionBlock, Constants.zPositionItem)
        
        // アイテムより爆弾が前
        XCTAssertLessThan(Constants.zPositionItem, Constants.zPositionBomb)
        
        // 爆弾よりキャラクターが前
        XCTAssertLessThan(Constants.zPositionBomb, Constants.zPositionCharacter)
        
        // キャラクターより爆発が前
        XCTAssertLessThan(Constants.zPositionCharacter, Constants.zPositionExplosion)
        
        // UIが一番前
        XCTAssertLessThan(Constants.zPositionExplosion, Constants.zPositionUI)
    }
    
    // MARK: - Physics Category Tests
    
    func testPhysicsCategoriesAreUnique() {
        let categories = [
            Constants.categoryNone,
            Constants.categoryPlayer,
            Constants.categoryEnemy,
            Constants.categoryBomb,
            Constants.categoryExplosion,
            Constants.categoryHardBlock,
            Constants.categorySoftBlock,
            Constants.categoryItem
        ]
        
        // 各カテゴリがユニーク
        let uniqueCategories = Set(categories)
        XCTAssertEqual(categories.count, uniqueCategories.count)
    }
    
    func testPhysicsCategoriesArePowerOfTwo() {
        // 各カテゴリが2の累乗（ビットマスクとして適切）
        let categories: [UInt32] = [
            Constants.categoryPlayer,
            Constants.categoryEnemy,
            Constants.categoryBomb,
            Constants.categoryExplosion,
            Constants.categoryHardBlock,
            Constants.categorySoftBlock,
            Constants.categoryItem
        ]
        
        for category in categories {
            // 2の累乗かチェック: category & (category - 1) == 0
            XCTAssertEqual(category & (category - 1), 0, "Category \(category) should be power of 2")
        }
    }
    
    // MARK: - Player Settings Tests
    
    func testPlayerSettings() {
        XCTAssertGreaterThan(Constants.playerBaseSpeed, 0)
        XCTAssertGreaterThan(Constants.playerMaxSpeed, Constants.playerBaseSpeed)
        XCTAssertGreaterThan(Constants.playerInitialBombCount, 0)
        XCTAssertGreaterThanOrEqual(Constants.playerMaxBombCount, Constants.playerInitialBombCount)
        XCTAssertGreaterThan(Constants.playerInitialFirePower, 0)
        XCTAssertGreaterThanOrEqual(Constants.playerMaxFirePower, Constants.playerInitialFirePower)
        XCTAssertGreaterThan(Constants.playerInitialLives, 0)
    }
    
    // MARK: - Bomb Settings Tests
    
    func testBombSettings() {
        XCTAssertEqual(Constants.bombFuseTime, 3.0, accuracy: 0.001)
        XCTAssertGreaterThan(Constants.explosionDuration, 0)
        XCTAssertGreaterThan(Constants.chainExplosionDelay, 0)
    }
    
    // MARK: - Item Settings Tests
    
    func testItemSettings() {
        XCTAssertGreaterThan(Constants.itemDropRate, 0)
        XCTAssertLessThanOrEqual(Constants.itemDropRate, 1)
        XCTAssertGreaterThan(Constants.invincibilityDuration, 0)
    }
    
    // MARK: - Color Constants Tests
    
    func testColorConstants() {
        XCTAssertTrue(Constants.backgroundColor.hasPrefix("#"))
        XCTAssertTrue(Constants.hardBlockColor.hasPrefix("#"))
        XCTAssertTrue(Constants.softBlockColor.hasPrefix("#"))
        XCTAssertTrue(Constants.playerColor.hasPrefix("#"))
        XCTAssertTrue(Constants.enemyColor.hasPrefix("#"))
        XCTAssertTrue(Constants.bombColor.hasPrefix("#"))
        XCTAssertTrue(Constants.explosionColor.hasPrefix("#"))
    }
}
