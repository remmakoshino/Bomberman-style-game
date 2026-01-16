//
//  Item.swift
//  BombermanGame
//
//  アイテムの管理
//

import Foundation
import SpriteKit

/// アイテムクラス - フィールド上のアイテムを管理
final class Item: SKSpriteNode {
    
    // MARK: - Properties
    
    /// アイテムの種類
    let itemType: ItemType
    
    /// グリッド位置
    var gridPos: GridPosition {
        return GridPosition.fromPoint(position)
    }
    
    /// 取得済みかどうか
    private(set) var isCollected: Bool = false
    
    /// 取得時のコールバック
    var onCollected: ((Item) -> Void)?
    
    // MARK: - Initialization
    
    init(type: ItemType, gridPosition: GridPosition) {
        self.itemType = type
        
        let size = CGSize(width: Constants.tileSize * 0.6, height: Constants.tileSize * 0.6)
        let color = SKColor(hex: type.colorHex)
        
        super.init(texture: nil, color: color, size: size)
        
        self.name = "item_\(type.rawValue)_\(gridPosition.x)_\(gridPosition.y)"
        self.position = gridPosition.toPoint()
        self.zPosition = Constants.zPositionItem
        
        setupAppearance()
        setupPhysics()
        startIdleAnimation()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupAppearance() {
        // アイテムの外観を設定
        let background = SKShapeNode(rectOf: size, cornerRadius: 6)
        background.fillColor = color
        background.strokeColor = .white
        background.lineWidth = 2
        background.zPosition = 0
        addChild(background)
        
        // アイテムアイコン
        let icon = createItemIcon()
        icon.zPosition = 1
        addChild(icon)
        
        // 本体を透明に
        self.color = .clear
    }
    
    private func createItemIcon() -> SKNode {
        let iconNode = SKNode()
        
        switch itemType {
        case .fireUp:
            // 炎のアイコン
            let flame = SKShapeNode(path: createFlamePath())
            flame.fillColor = .orange
            flame.strokeColor = .red
            flame.lineWidth = 1
            iconNode.addChild(flame)
            
        case .bombUp:
            // 爆弾のアイコン
            let bomb = SKShapeNode(circleOfRadius: 8)
            bomb.fillColor = .black
            bomb.strokeColor = .gray
            iconNode.addChild(bomb)
            
            let fuse = SKShapeNode(rectOf: CGSize(width: 2, height: 5))
            fuse.fillColor = .brown
            fuse.position = CGPoint(x: 0, y: 10)
            iconNode.addChild(fuse)
            
        case .speedUp:
            // 矢印のアイコン
            let arrow = SKShapeNode(path: createArrowPath())
            arrow.fillColor = .cyan
            arrow.strokeColor = .white
            iconNode.addChild(arrow)
            
        case .remoteControl:
            // リモコンのアイコン
            let remote = SKShapeNode(rectOf: CGSize(width: 10, height: 16), cornerRadius: 2)
            remote.fillColor = .gray
            remote.strokeColor = .darkGray
            iconNode.addChild(remote)
            
            let button = SKShapeNode(circleOfRadius: 3)
            button.fillColor = .red
            button.position = CGPoint(x: 0, y: 3)
            iconNode.addChild(button)
            
        case .wallPass:
            // 幽霊のアイコン
            let ghost = SKShapeNode(path: createGhostPath())
            ghost.fillColor = .white
            ghost.strokeColor = .lightGray
            ghost.alpha = 0.8
            iconNode.addChild(ghost)
            
        case .bombPass:
            // すり抜けアイコン
            let circle = SKShapeNode(circleOfRadius: 8)
            circle.fillColor = .clear
            circle.strokeColor = .gray
            circle.lineWidth = 2
            iconNode.addChild(circle)
            
            let dash = SKShapeNode(rectOf: CGSize(width: 12, height: 2))
            dash.fillColor = .gray
            iconNode.addChild(dash)
            
        case .invincible:
            // 星のアイコン
            let star = SKShapeNode(path: createStarPath())
            star.fillColor = .yellow
            star.strokeColor = .orange
            star.lineWidth = 1
            iconNode.addChild(star)
        }
        
        return iconNode
    }
    
    private func createFlamePath() -> CGPath {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: 10))
        path.addQuadCurve(to: CGPoint(x: -6, y: -5), control: CGPoint(x: -8, y: 5))
        path.addQuadCurve(to: CGPoint(x: 0, y: -10), control: CGPoint(x: -3, y: -8))
        path.addQuadCurve(to: CGPoint(x: 6, y: -5), control: CGPoint(x: 3, y: -8))
        path.addQuadCurve(to: CGPoint(x: 0, y: 10), control: CGPoint(x: 8, y: 5))
        return path
    }
    
    private func createArrowPath() -> CGPath {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: 10))
        path.addLine(to: CGPoint(x: 8, y: 0))
        path.addLine(to: CGPoint(x: 3, y: 0))
        path.addLine(to: CGPoint(x: 3, y: -10))
        path.addLine(to: CGPoint(x: -3, y: -10))
        path.addLine(to: CGPoint(x: -3, y: 0))
        path.addLine(to: CGPoint(x: -8, y: 0))
        path.closeSubpath()
        return path
    }
    
    private func createGhostPath() -> CGPath {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -8, y: -8))
        path.addQuadCurve(to: CGPoint(x: 0, y: 10), control: CGPoint(x: -10, y: 5))
        path.addQuadCurve(to: CGPoint(x: 8, y: -8), control: CGPoint(x: 10, y: 5))
        path.addLine(to: CGPoint(x: 5, y: -5))
        path.addLine(to: CGPoint(x: 2, y: -8))
        path.addLine(to: CGPoint(x: -2, y: -5))
        path.addLine(to: CGPoint(x: -5, y: -8))
        path.closeSubpath()
        return path
    }
    
    private func createStarPath() -> CGPath {
        let path = CGMutablePath()
        let points = 5
        let outerRadius: CGFloat = 10
        let innerRadius: CGFloat = 4
        
        for i in 0..<(points * 2) {
            let radius = i % 2 == 0 ? outerRadius : innerRadius
            let angle = CGFloat(i) * .pi / CGFloat(points) - .pi / 2
            let point = CGPoint(x: cos(angle) * radius, y: sin(angle) * radius)
            
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }
    
    private func setupPhysics() {
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = Constants.categoryItem
        physicsBody?.contactTestBitMask = Constants.categoryPlayer
        physicsBody?.collisionBitMask = Constants.categoryNone
    }
    
    // MARK: - Animation
    
    private func startIdleAnimation() {
        // ゆらゆら揺れるアニメーション
        let moveUp = SKAction.moveBy(x: 0, y: 3, duration: 0.5)
        let moveDown = SKAction.moveBy(x: 0, y: -3, duration: 0.5)
        moveUp.timingMode = .easeInEaseOut
        moveDown.timingMode = .easeInEaseOut
        
        let bounce = SKAction.sequence([moveUp, moveDown])
        run(SKAction.repeatForever(bounce), withKey: "idleAnimation")
        
        // キラキラエフェクト
        let sparkle = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.7, duration: 0.3),
            SKAction.fadeAlpha(to: 1.0, duration: 0.3)
        ])
        run(SKAction.repeatForever(sparkle), withKey: "sparkleAnimation")
    }
    
    // MARK: - Collection
    
    /// アイテムを取得
    func collect(by player: Player) {
        guard !isCollected else { return }
        
        isCollected = true
        removeAction(forKey: "idleAnimation")
        removeAction(forKey: "sparkleAnimation")
        
        // プレイヤーにアイテム効果を適用
        player.collectItem(itemType)
        
        // 取得エフェクト
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.1)
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        let moveUp = SKAction.moveBy(x: 0, y: 20, duration: 0.2)
        let group = SKAction.group([fadeOut, moveUp])
        let sequence = SKAction.sequence([scaleUp, group])
        
        run(sequence) { [weak self] in
            guard let self = self else { return }
            self.onCollected?(self)
            self.removeFromParent()
        }
    }
    
    /// 爆発で破壊
    func destroyByExplosion() {
        guard !isCollected else { return }
        
        isCollected = true
        
        // 破壊エフェクト
        let shrink = SKAction.scale(to: 0, duration: 0.2)
        let rotate = SKAction.rotate(byAngle: .pi, duration: 0.2)
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        let group = SKAction.group([shrink, rotate, fadeOut])
        
        run(group) { [weak self] in
            self?.removeFromParent()
        }
    }
}

// MARK: - Item Factory

/// アイテム生成用のファクトリー
enum ItemFactory {
    
    /// 指定したタイプのアイテムを生成
    static func createItem(type: ItemType, at position: GridPosition) -> Item {
        return Item(type: type, gridPosition: position)
    }
    
    /// ランダムなアイテムを生成
    static func createRandomItem(at position: GridPosition) -> Item {
        let weights = GameConfig.shared.itemDropWeights
        let totalWeight = weights.values.reduce(0, +)
        var randomValue = Double.random(in: 0..<totalWeight)
        
        for (itemType, weight) in weights {
            randomValue -= weight
            if randomValue <= 0 {
                return createItem(type: itemType, at: position)
            }
        }
        
        return createItem(type: .fireUp, at: position)
    }
}
