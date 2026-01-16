//
//  Explosion.swift
//  BombermanGame
//
//  爆発エフェクトの管理
//

import Foundation
import SpriteKit

/// 爆発エフェクトクラス
final class Explosion: SKNode {
    
    // MARK: - Properties
    
    /// 爆発の一意識別子
    let explosionID: UUID = UUID()
    
    /// 爆発の中心位置
    let centerPosition: GridPosition
    
    /// 火力（爆風の範囲）
    let firePower: Int
    
    /// 影響を受けるグリッド位置
    private(set) var affectedPositions: [GridPosition] = []
    
    /// 爆発の持続時間
    let duration: TimeInterval
    
    /// 爆発終了コールバック
    var onComplete: ((Explosion) -> Void)?
    
    // MARK: - Initialization
    
    init(centerPosition: GridPosition, firePower: Int, affectedPositions: [GridPosition]) {
        self.centerPosition = centerPosition
        self.firePower = firePower
        self.affectedPositions = affectedPositions
        self.duration = Constants.explosionDuration
        
        super.init()
        
        self.name = "explosion_\(explosionID.uuidString)"
        self.zPosition = Constants.zPositionExplosion
        
        createExplosionEffect()
        startExplosionAnimation()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func createExplosionEffect() {
        for pos in affectedPositions {
            let explosionTile = createExplosionTile(at: pos)
            addChild(explosionTile)
        }
    }
    
    private func createExplosionTile(at gridPos: GridPosition) -> SKNode {
        let tileNode = SKNode()
        let scenePos = gridPos.toPoint()
        tileNode.position = scenePos
        
        // 爆風の形状を決定
        let shape = determineExplosionShape(at: gridPos)
        
        // メインの炎
        let mainFlame = SKShapeNode(rectOf: shape.size, cornerRadius: 4)
        mainFlame.fillColor = SKColor(hex: Constants.explosionColor)
        mainFlame.strokeColor = .clear
        mainFlame.alpha = 0.9
        mainFlame.zPosition = 0
        tileNode.addChild(mainFlame)
        
        // 中心の明るい部分
        let innerFlame = SKShapeNode(rectOf: CGSize(width: shape.size.width * 0.6,
                                                     height: shape.size.height * 0.6),
                                      cornerRadius: 2)
        innerFlame.fillColor = .yellow
        innerFlame.strokeColor = .clear
        innerFlame.alpha = 0.8
        innerFlame.zPosition = 1
        tileNode.addChild(innerFlame)
        
        // パーティクル効果
        addParticleEffect(to: tileNode)
        
        // 物理ボディ
        let physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: Constants.tileSize * 0.8,
                                                             height: Constants.tileSize * 0.8))
        physicsBody.isDynamic = false
        physicsBody.categoryBitMask = Constants.categoryExplosion
        physicsBody.contactTestBitMask = Constants.categoryPlayer | Constants.categoryEnemy | Constants.categoryBomb
        physicsBody.collisionBitMask = Constants.categoryNone
        tileNode.physicsBody = physicsBody
        tileNode.name = "explosionTile_\(gridPos.x)_\(gridPos.y)"
        
        return tileNode
    }
    
    private func determineExplosionShape(at gridPos: GridPosition) -> (size: CGSize, isCenter: Bool) {
        let tileSize = Constants.tileSize * 0.9
        
        if gridPos == centerPosition {
            // 中心
            return (CGSize(width: tileSize, height: tileSize), true)
        } else {
            // 放射状の爆風
            return (CGSize(width: tileSize, height: tileSize), false)
        }
    }
    
    private func addParticleEffect(to node: SKNode) {
        // シンプルなパーティクル効果
        for _ in 0..<3 {
            let particle = SKShapeNode(circleOfRadius: CGFloat.random(in: 2...5))
            particle.fillColor = [.orange, .yellow, .red].randomElement()!
            particle.strokeColor = .clear
            particle.alpha = 0.8
            particle.position = CGPoint(
                x: CGFloat.random(in: -10...10),
                y: CGFloat.random(in: -10...10)
            )
            particle.zPosition = 2
            
            let moveUp = SKAction.moveBy(x: CGFloat.random(in: -15...15),
                                          y: CGFloat.random(in: 10...25),
                                          duration: 0.3)
            let fadeOut = SKAction.fadeOut(withDuration: 0.3)
            let group = SKAction.group([moveUp, fadeOut])
            
            node.addChild(particle)
            particle.run(group) {
                particle.removeFromParent()
            }
        }
    }
    
    // MARK: - Animation
    
    private func startExplosionAnimation() {
        // 拡大して消えるアニメーション
        let scaleUp = SKAction.scale(to: 1.2, duration: duration * 0.2)
        let wait = SKAction.wait(forDuration: duration * 0.5)
        let fadeOut = SKAction.fadeOut(withDuration: duration * 0.3)
        let scaleDown = SKAction.scale(to: 0.8, duration: duration * 0.3)
        
        let fadeAndScale = SKAction.group([fadeOut, scaleDown])
        
        let sequence = SKAction.sequence([
            scaleUp,
            wait,
            fadeAndScale,
            SKAction.run { [weak self] in
                self?.complete()
            }
        ])
        
        run(sequence)
        
        // 揺れ効果
        children.forEach { child in
            let wobble = SKAction.sequence([
                SKAction.rotate(byAngle: 0.05, duration: 0.05),
                SKAction.rotate(byAngle: -0.1, duration: 0.05),
                SKAction.rotate(byAngle: 0.05, duration: 0.05)
            ])
            child.run(SKAction.repeatForever(wobble))
        }
    }
    
    /// 爆発終了
    private func complete() {
        onComplete?(self)
        removeFromParent()
    }
    
    // MARK: - Collision Check
    
    /// 指定位置が爆発に巻き込まれているかチェック
    func isAffecting(position: GridPosition) -> Bool {
        return affectedPositions.contains(position)
    }
    
    /// 指定位置が爆発に巻き込まれているかチェック（CGPoint版）
    func isAffecting(point: CGPoint) -> Bool {
        let gridPos = GridPosition.fromPoint(point)
        return isAffecting(position: gridPos)
    }
}

// MARK: - Explosion Factory

/// 爆発生成用のファクトリー
enum ExplosionFactory {
    
    /// グリッドシステムを使用して爆発を生成
    static func createExplosion(at position: GridPosition,
                                 firePower: Int,
                                 gridSystem: GridSystem) -> Explosion {
        let affectedPositions = gridSystem.calculateExplosionRange(from: position, power: firePower)
        return Explosion(centerPosition: position, firePower: firePower, affectedPositions: affectedPositions)
    }
}
