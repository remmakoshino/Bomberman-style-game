//
//  Bomb.swift
//  BombermanGame
//
//  爆弾の管理
//

import Foundation
import SpriteKit

/// 爆弾クラス - 爆弾の状態と爆発処理を管理
final class Bomb: SKSpriteNode {
    
    // MARK: - Properties
    
    /// 爆弾の一意識別子
    let bombID: UUID = UUID()
    
    /// 爆弾の所有者
    weak var owner: Player?
    
    /// 火力（爆風の範囲）
    let firePower: Int
    
    /// リモコン爆弾かどうか
    let isRemote: Bool
    
    /// 爆発までの残り時間
    var fuseTime: TimeInterval
    
    /// 爆発済みかどうか
    private(set) var hasExploded: Bool = false
    
    /// 爆発コールバック
    var onExplode: ((Bomb) -> Void)?
    
    /// 現在のグリッド位置
    var gridPosition: GridPosition {
        return GridPosition.fromPoint(position)
    }
    
    // MARK: - Initialization
    
    init(owner: Player?, firePower: Int, isRemote: Bool = false) {
        self.owner = owner
        self.firePower = firePower
        self.isRemote = isRemote
        self.fuseTime = GameConfig.shared.bombFuseTime
        
        let size = CGSize(width: Constants.tileSize * 0.7, height: Constants.tileSize * 0.7)
        let color = SKColor(hex: Constants.bombColor)
        
        super.init(texture: nil, color: color, size: size)
        
        self.name = "bomb_\(bombID.uuidString)"
        self.zPosition = Constants.zPositionBomb
        
        setupAppearance()
        setupPhysics()
        
        if !isRemote {
            startFuseTimer()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupAppearance() {
        // 爆弾本体を丸く
        let bombBody = SKShapeNode(circleOfRadius: size.width / 2)
        bombBody.fillColor = color
        bombBody.strokeColor = .black
        bombBody.lineWidth = 2
        bombBody.zPosition = 0
        addChild(bombBody)
        
        // 導火線
        let fuseHeight: CGFloat = 10
        let fuse = SKShapeNode(rectOf: CGSize(width: 3, height: fuseHeight))
        fuse.fillColor = SKColor(hex: "#8B4513")
        fuse.strokeColor = .clear
        fuse.position = CGPoint(x: 0, y: size.height / 2 + fuseHeight / 2 - 5)
        fuse.zPosition = 1
        addChild(fuse)
        
        // 導火線の火花
        let spark = SKShapeNode(circleOfRadius: 4)
        spark.fillColor = .orange
        spark.strokeColor = .yellow
        spark.glowWidth = 3
        spark.position = CGPoint(x: 0, y: fuseHeight / 2)
        spark.zPosition = 2
        spark.name = "spark"
        fuse.addChild(spark)
        
        // 火花のアニメーション
        let sparkAnimation = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.5, duration: 0.1),
            SKAction.fadeAlpha(to: 1.0, duration: 0.1)
        ])
        spark.run(SKAction.repeatForever(sparkAnimation))
        
        // リモコン爆弾の場合は色を変える
        if isRemote {
            bombBody.fillColor = SKColor(hex: "#1ABC9C")
        }
        
        // 本体を透明にする（ShapeNodeで描画するため）
        self.color = .clear
    }
    
    private func setupPhysics() {
        physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2 * 0.9)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = Constants.categoryBomb
        physicsBody?.contactTestBitMask = Constants.categoryExplosion
        physicsBody?.collisionBitMask = Constants.categoryPlayer | Constants.categoryEnemy
    }
    
    // MARK: - Timer
    
    private func startFuseTimer() {
        // 点滅アニメーション（爆発が近づくと速くなる）
        startBlinkAnimation()
        
        // 爆発タイマー
        let wait = SKAction.wait(forDuration: fuseTime)
        let explodeAction = SKAction.run { [weak self] in
            self?.explode()
        }
        run(SKAction.sequence([wait, explodeAction]), withKey: "fuseTimer")
    }
    
    private func startBlinkAnimation() {
        // 段階的に速くなる点滅
        let phases: [(interval: TimeInterval, duration: TimeInterval)] = [
            (0.5, fuseTime * 0.5),    // 前半: ゆっくり
            (0.3, fuseTime * 0.3),    // 中盤: やや速く
            (0.15, fuseTime * 0.2)    // 終盤: 速く
        ]
        
        var actions: [SKAction] = []
        
        for phase in phases {
            let blink = SKAction.sequence([
                SKAction.scale(to: 1.1, duration: phase.interval / 2),
                SKAction.scale(to: 1.0, duration: phase.interval / 2)
            ])
            let phaseAction = SKAction.repeat(blink, count: Int(phase.duration / phase.interval))
            actions.append(phaseAction)
        }
        
        run(SKAction.sequence(actions), withKey: "blinkAnimation")
    }
    
    // MARK: - Explosion
    
    /// 爆発を実行
    func explode() {
        guard !hasExploded else { return }
        hasExploded = true
        
        // タイマーをキャンセル
        removeAction(forKey: "fuseTimer")
        removeAction(forKey: "blinkAnimation")
        
        // 所有者に通知
        owner?.onBombExploded(self)
        
        // 爆発コールバックを実行
        onExplode?(self)
        
        // 爆弾を削除
        removeFromParent()
    }
    
    /// 連鎖爆発（他の爆発に巻き込まれた場合）
    func chainExplode(delay: TimeInterval = 0) {
        guard !hasExploded else { return }
        
        // タイマーをキャンセル
        removeAction(forKey: "fuseTimer")
        
        // 遅延後に爆発
        let wait = SKAction.wait(forDuration: delay)
        let explodeAction = SKAction.run { [weak self] in
            self?.explode()
        }
        run(SKAction.sequence([wait, explodeAction]))
    }
    
    // MARK: - Update
    
    /// 毎フレームの更新
    func update(deltaTime: TimeInterval) {
        guard !isRemote else { return }
        
        fuseTime -= deltaTime
        
        if fuseTime <= 0 && !hasExploded {
            explode()
        }
    }
}
