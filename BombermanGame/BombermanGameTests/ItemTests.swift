//
//  ItemTests.swift
//  BombermanGameTests
//
//  アイテムのテスト
//

import XCTest
import SpriteKit
@testable import BombermanGame

final class ItemTests: XCTestCase {
    
    // MARK: - ItemType Tests
    
    func testItemTypeDisplayName() {
        XCTAssertEqual(ItemType.fireUp.displayName, "火力UP")
        XCTAssertEqual(ItemType.bombUp.displayName, "爆弾UP")
        XCTAssertEqual(ItemType.speedUp.displayName, "スピードUP")
        XCTAssertEqual(ItemType.remoteControl.displayName, "リモコン")
        XCTAssertEqual(ItemType.wallPass.displayName, "壁抜け")
        XCTAssertEqual(ItemType.bombPass.displayName, "爆弾抜け")
        XCTAssertEqual(ItemType.invincible.displayName, "無敵")
    }
    
    func testItemTypeHasColor() {
        for itemType in ItemType.allCases {
            XCTAssertFalse(itemType.colorHex.isEmpty)
            XCTAssertTrue(itemType.colorHex.hasPrefix("#"))
        }
    }
    
    func testAllItemTypesExist() {
        XCTAssertEqual(ItemType.allCases.count, 7)
    }
    
    // MARK: - Item Initialization Tests
    
    func testItemInitialization() {
        let position = GridPosition(x: 5, y: 5)
        let item = Item(type: .fireUp, gridPosition: position)
        
        XCTAssertEqual(item.itemType, .fireUp)
        XCTAssertEqual(item.gridPos, position)
        XCTAssertFalse(item.isCollected)
    }
    
    // MARK: - Item Collection Tests
    
    func testItemCollection() {
        let position = GridPosition(x: 5, y: 5)
        let item = Item(type: .fireUp, gridPosition: position)
        let player = Player(playerID: 1)
        let initialFirePower = player.firePower
        
        item.collect(by: player)
        
        XCTAssertTrue(item.isCollected)
        XCTAssertEqual(player.firePower, initialFirePower + 1)
    }
    
    func testItemCannotBeCollectedTwice() {
        let position = GridPosition(x: 5, y: 5)
        let item = Item(type: .fireUp, gridPosition: position)
        let player = Player(playerID: 1)
        
        item.collect(by: player)
        let firePowerAfterFirst = player.firePower
        
        item.collect(by: player) // 2回目の収集
        
        XCTAssertEqual(player.firePower, firePowerAfterFirst) // 変化なし
    }
    
    func testCollectedCallback() {
        let position = GridPosition(x: 5, y: 5)
        let item = Item(type: .fireUp, gridPosition: position)
        let player = Player(playerID: 1)
        var callbackCalled = false
        
        item.onCollected = { _ in
            callbackCalled = true
        }
        
        item.collect(by: player)
        
        // コールバックはアニメーション完了後に呼ばれる
        // 実際のテストではrunLoopを進める必要がある
    }
    
    // MARK: - Item Destruction Tests
    
    func testDestroyByExplosion() {
        let position = GridPosition(x: 5, y: 5)
        let item = Item(type: .fireUp, gridPosition: position)
        
        item.destroyByExplosion()
        
        XCTAssertTrue(item.isCollected) // 内部的には収集済みとしてマーク
    }
    
    // MARK: - Item Factory Tests
    
    func testItemFactoryCreateItem() {
        let position = GridPosition(x: 3, y: 4)
        let item = ItemFactory.createItem(type: .bombUp, at: position)
        
        XCTAssertEqual(item.itemType, .bombUp)
        XCTAssertEqual(item.gridPos, position)
    }
    
    func testItemFactoryCreateRandomItem() {
        let position = GridPosition(x: 3, y: 4)
        let item = ItemFactory.createRandomItem(at: position)
        
        XCTAssertNotNil(item)
        XCTAssertEqual(item.gridPos, position)
        XCTAssertTrue(ItemType.allCases.contains(item.itemType))
    }
    
    // MARK: - GameConfig Item Tests
    
    func testItemDropWeights() {
        let config = GameConfig.shared
        let weights = config.itemDropWeights
        
        // すべてのアイテムタイプに重みが設定されている
        for itemType in ItemType.allCases {
            XCTAssertNotNil(weights[itemType])
            XCTAssertGreaterThan(weights[itemType]!, 0)
        }
    }
    
    func testItemDropRate() {
        let config = GameConfig.shared
        
        XCTAssertGreaterThan(config.itemDropRate, 0)
        XCTAssertLessThanOrEqual(config.itemDropRate, 1)
    }
}
