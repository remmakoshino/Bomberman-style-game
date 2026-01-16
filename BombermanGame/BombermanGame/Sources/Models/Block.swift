//
//  Block.swift
//  BombermanGame
//
//  ブロック（壁）の管理
//

import Foundation
import SpriteKit

/// ブロックの種類
enum BlockType {
    case hard   // ハードブロック（破壊不可）
    case soft   // ソフトブロック（破壊可能）
}

/// ブロッククラス - マップ上のブロックを管理
final class Block: SKSpriteNode {
    
    // MARK: - Properties
    
    /// ブロックの種類
    let blockType: BlockType
    
    /// グリッド位置
    let gridPos: GridPosition
    
    /// 内包するアイテム（ソフトブロックのみ）
    var containedItem: ItemType?
    
    /// 破壊されたかどうか
    private(set) var isDestroyed: Bool = false
    
    /// 破壊時のコールバック
    var onDestroyed: ((Block) -> Void)?
    
    // MARK: - Initialization
    
    init(type: BlockType, gridPosition: GridPosition) {
        self.blockType = type
        self.gridPos = gridPosition
        
        let size = CGSize(width: Constants.tileSize, height: Constants.tileSize)
        let color: SKColor
        
        switch type {
        case .hard:
            color = SKColor(hex: Constants.hardBlockColor)
        case .soft:
            color = SKColor(hex: Constants.softBlockColor)
        }
        
        super.init(texture: nil, color: color, size: size)
        
        self.name = "block_\(gridPosition.x)_\(gridPosition.y)"
        self.position = gridPosition.toPoint()
        self.zPosition = Constants.zPositionBlock
        
        setupAppearance()
        setupPhysics()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupAppearance() {
        switch blockType {
        case .hard:
            setupHardBlockAppearance()
        case .soft:
            setupSoftBlockAppearance()
        }
    }
    
    private func setupHardBlockAppearance() {
        // ハードブロックのデザイン（レンガ風）
        let borderWidth: CGFloat = 2
        
        // 枠線
        let border = SKShapeNode(rectOf: CGSize(width: size.width - borderWidth,
                                                  height: size.height - borderWidth))
        border.strokeColor = SKColor(hex: "#5D6D7E")
        border.lineWidth = borderWidth
        border.fillColor = .clear
        border.zPosition = 1
        addChild(border)
        
        // 模様（十字線）
        let horizontalLine = SKShapeNode(rectOf: CGSize(width: size.width * 0.8, height: 2))
        horizontalLine.fillColor = SKColor(hex: "#5D6D7E")
        horizontalLine.strokeColor = .clear
        horizontalLine.zPosition = 1
        addChild(horizontalLine)
        
        let verticalLine = SKShapeNode(rectOf: CGSize(width: 2, height: size.height * 0.8))
        verticalLine.fillColor = SKColor(hex: "#5D6D7E")
        verticalLine.strokeColor = .clear
        verticalLine.zPosition = 1
        addChild(verticalLine)
    }
    
    private func setupSoftBlockAppearance() {
        // ソフトブロックのデザイン
        let borderWidth: CGFloat = 2
        
        // 枠線
        let border = SKShapeNode(rectOf: CGSize(width: size.width - borderWidth,
                                                  height: size.height - borderWidth),
                                  cornerRadius: 4)
        border.strokeColor = SKColor(hex: "#D35400")
        border.lineWidth = borderWidth
        border.fillColor = .clear
        border.zPosition = 1
        addChild(border)
        
        // 内側の模様
        let innerPattern = SKShapeNode(rectOf: CGSize(width: size.width * 0.6,
                                                        height: size.height * 0.6),
                                         cornerRadius: 2)
        innerPattern.fillColor = SKColor(hex: "#D35400")
        innerPattern.strokeColor = .clear
        innerPattern.alpha = 0.5
        innerPattern.zPosition = 1
        addChild(innerPattern)
    }
    
    private func setupPhysics() {
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.isDynamic = false
        
        switch blockType {
        case .hard:
            physicsBody?.categoryBitMask = Constants.categoryHardBlock
        case .soft:
            physicsBody?.categoryBitMask = Constants.categorySoftBlock
        }
        
        physicsBody?.collisionBitMask = Constants.categoryPlayer | Constants.categoryEnemy
    }
    
    // MARK: - Destruction
    
    /// ブロックを破壊（ソフトブロックのみ）
    func destroy() {
        guard blockType == .soft && !isDestroyed else { return }
        
        isDestroyed = true
        
        // 破壊アニメーション
        let particles = createDestructionParticles()
        parent?.addChild(particles)
        
        let shrink = SKAction.scale(to: 0, duration: 0.2)
        let rotate = SKAction.rotate(byAngle: .pi / 4, duration: 0.2)
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        let animation = SKAction.group([shrink, rotate, fadeOut])
        
        run(animation) { [weak self] in
            guard let self = self else { return }
            self.onDestroyed?(self)
            self.removeFromParent()
        }
    }
    
    private func createDestructionParticles() -> SKNode {
        let particleContainer = SKNode()
        particleContainer.position = position
        particleContainer.zPosition = Constants.zPositionExplosion
        
        let particleCount = 8
        for _ in 0..<particleCount {
            let particle = SKShapeNode(rectOf: CGSize(width: 6, height: 6))
            particle.fillColor = self.color
            particle.strokeColor = .clear
            
            let angle = CGFloat.random(in: 0...(2 * .pi))
            let distance = CGFloat.random(in: 30...60)
            let dx = cos(angle) * distance
            let dy = sin(angle) * distance
            
            let move = SKAction.moveBy(x: dx, y: dy, duration: 0.3)
            let fade = SKAction.fadeOut(withDuration: 0.3)
            let rotate = SKAction.rotate(byAngle: CGFloat.random(in: -.pi...(.pi)), duration: 0.3)
            let group = SKAction.group([move, fade, rotate])
            
            particle.run(group) {
                particle.removeFromParent()
            }
            
            particleContainer.addChild(particle)
        }
        
        // コンテナを一定時間後に削除
        let wait = SKAction.wait(forDuration: 0.5)
        let remove = SKAction.removeFromParent()
        particleContainer.run(SKAction.sequence([wait, remove]))
        
        return particleContainer
    }
    
    // MARK: - Item
    
    /// ランダムなアイテムを内包させる
    func assignRandomItem() {
        guard blockType == .soft else { return }
        
        if Double.random(in: 0...1) < GameConfig.shared.itemDropRate {
            containedItem = selectRandomItem()
        }
    }
    
    private func selectRandomItem() -> ItemType {
        let weights = GameConfig.shared.itemDropWeights
        let totalWeight = weights.values.reduce(0, +)
        var randomValue = Double.random(in: 0..<totalWeight)
        
        for (itemType, weight) in weights {
            randomValue -= weight
            if randomValue <= 0 {
                return itemType
            }
        }
        
        return .fireUp // デフォルト
    }
}

// MARK: - Block Factory

/// ブロック生成用のファクトリー
enum BlockFactory {
    
    /// ハードブロックを生成
    static func createHardBlock(at position: GridPosition) -> Block {
        return Block(type: .hard, gridPosition: position)
    }
    
    /// ソフトブロック（アイテム付き）を生成
    static func createSoftBlock(at position: GridPosition, withRandomItem: Bool = true) -> Block {
        let block = Block(type: .soft, gridPosition: position)
        if withRandomItem {
            block.assignRandomItem()
        }
        return block
    }
}
