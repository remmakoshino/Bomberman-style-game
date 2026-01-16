//
//  Player.swift
//  BombermanGame
//
//  プレイヤーキャラクターの管理
//

import Foundation
import SpriteKit

/// プレイヤークラス - プレイヤーキャラクターの状態と動作を管理
final class Player: SKSpriteNode {
    
    // MARK: - Properties
    
    /// プレイヤーID（マルチプレイ用）
    let playerID: Int
    
    /// 現在のグリッド位置
    var gridPosition: GridPosition {
        return GridPosition.fromPoint(position)
    }
    
    /// 移動速度（マス/秒）
    var moveSpeed: CGFloat
    
    /// 最大爆弾数
    var maxBombs: Int
    
    /// 現在設置中の爆弾数
    var currentBombs: Int = 0
    
    /// 火力（爆風範囲）
    var firePower: Int
    
    /// 残機
    var lives: Int
    
    /// 移動方向
    var moveDirection: Direction?
    
    /// リモコン爆弾能力
    var hasRemoteControl: Bool = false
    
    /// 壁すり抜け能力
    var canPassWalls: Bool = false
    
    /// 爆弾すり抜け能力
    var canPassBombs: Bool = false
    
    /// 無敵状態
    var isInvincible: Bool = false
    
    /// 死亡状態
    var isDead: Bool = false
    
    /// 設置した爆弾のリスト
    var placedBombs: [Bomb] = []
    
    /// スコア
    var score: Int = 0
    
    // MARK: - Private Properties
    
    private var isMoving: Bool = false
    private var targetPosition: CGPoint?
    private let config = GameConfig.shared
    
    // MARK: - Initialization
    
    init(playerID: Int = 1) {
        self.playerID = playerID
        self.moveSpeed = GameConfig.shared.playerBaseSpeed
        self.maxBombs = GameConfig.shared.initialBombCount
        self.firePower = GameConfig.shared.initialFirePower
        self.lives = GameConfig.shared.initialLives
        
        // スプライトの初期化
        let size = CGSize(width: Constants.tileSize * 0.8, height: Constants.tileSize * 0.8)
        let color = Player.colorForPlayerID(playerID)
        
        super.init(texture: nil, color: color, size: size)
        
        self.name = "player_\(playerID)"
        self.zPosition = Constants.zPositionCharacter
        
        setupPhysics()
        setupAppearance()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupPhysics() {
        let physicsSize = CGSize(width: size.width * 0.7, height: size.height * 0.7)
        physicsBody = SKPhysicsBody(rectangleOf: physicsSize)
        physicsBody?.isDynamic = true
        physicsBody?.allowsRotation = false
        physicsBody?.friction = 0
        physicsBody?.restitution = 0
        physicsBody?.linearDamping = 0
        physicsBody?.categoryBitMask = Constants.categoryPlayer
        physicsBody?.contactTestBitMask = Constants.categoryEnemy | Constants.categoryExplosion | Constants.categoryItem
        physicsBody?.collisionBitMask = Constants.categoryHardBlock | Constants.categorySoftBlock | Constants.categoryBomb
    }
    
    private func setupAppearance() {
        // プレイヤーの外観設定
        let eyeSize: CGFloat = 6
        let eyeY: CGFloat = size.height * 0.15
        
        // 左目
        let leftEye = SKShapeNode(circleOfRadius: eyeSize / 2)
        leftEye.fillColor = .white
        leftEye.strokeColor = .clear
        leftEye.position = CGPoint(x: -size.width * 0.15, y: eyeY)
        leftEye.zPosition = 1
        addChild(leftEye)
        
        // 右目
        let rightEye = SKShapeNode(circleOfRadius: eyeSize / 2)
        rightEye.fillColor = .white
        rightEye.strokeColor = .clear
        rightEye.position = CGPoint(x: size.width * 0.15, y: eyeY)
        rightEye.zPosition = 1
        addChild(rightEye)
        
        // 瞳
        let pupilSize: CGFloat = 3
        let leftPupil = SKShapeNode(circleOfRadius: pupilSize / 2)
        leftPupil.fillColor = .black
        leftPupil.strokeColor = .clear
        leftPupil.position = CGPoint(x: 1, y: 0)
        leftPupil.zPosition = 2
        leftPupil.name = "leftPupil"
        leftEye.addChild(leftPupil)
        
        let rightPupil = SKShapeNode(circleOfRadius: pupilSize / 2)
        rightPupil.fillColor = .black
        rightPupil.strokeColor = .clear
        rightPupil.position = CGPoint(x: 1, y: 0)
        rightPupil.zPosition = 2
        rightPupil.name = "rightPupil"
        rightEye.addChild(rightPupil)
    }
    
    // MARK: - Movement
    
    /// 移動を開始
    func startMoving(in direction: Direction) {
        self.moveDirection = direction
        updatePupilDirection(direction)
    }
    
    /// 移動を停止
    func stopMoving() {
        self.moveDirection = nil
        physicsBody?.velocity = .zero
    }
    
    /// 毎フレームの更新
    func update(deltaTime: TimeInterval, gridSystem: GridSystem) {
        guard !isDead else { return }
        
        if let direction = moveDirection {
            moveInDirection(direction, gridSystem: gridSystem, deltaTime: deltaTime)
        }
    }
    
    private func moveInDirection(_ direction: Direction, gridSystem: GridSystem, deltaTime: TimeInterval) {
        let velocity = CGFloat(moveSpeed) * Constants.tileSize
        let movement = direction.vector * velocity
        
        // 次のフレームでの予測位置
        let predictedPosition = CGPoint(
            x: position.x + movement.dx * CGFloat(deltaTime),
            y: position.y + movement.dy * CGFloat(deltaTime)
        )
        
        // 衝突チェック
        let predictedGridPos = GridPosition.fromPoint(predictedPosition)
        
        if gridSystem.isWalkable(at: predictedGridPos, canPassWalls: canPassWalls, canPassBombs: canPassBombs) {
            physicsBody?.velocity = CGVector(dx: movement.dx, dy: movement.dy)
        } else {
            // 壁にぶつかった場合は停止
            physicsBody?.velocity = .zero
            
            // グリッドの中心に補正
            let currentGridPos = gridPosition
            let centerPosition = gridSystem.gridToScene(currentGridPos)
            position = centerPosition
        }
    }
    
    private func updatePupilDirection(_ direction: Direction) {
        let offset: CGFloat = 1.5
        var pupilOffset = CGPoint.zero
        
        switch direction {
        case .up:
            pupilOffset = CGPoint(x: 0, y: offset)
        case .down:
            pupilOffset = CGPoint(x: 0, y: -offset)
        case .left:
            pupilOffset = CGPoint(x: -offset, y: 0)
        case .right:
            pupilOffset = CGPoint(x: offset, y: 0)
        }
        
        enumerateChildNodes(withName: "//*leftPupil") { node, _ in
            node.position = pupilOffset
        }
        enumerateChildNodes(withName: "//*rightPupil") { node, _ in
            node.position = pupilOffset
        }
    }
    
    // MARK: - Bomb
    
    /// 爆弾を設置可能かチェック
    func canPlaceBomb() -> Bool {
        return currentBombs < maxBombs && !isDead
    }
    
    /// 爆弾を設置
    func placeBomb() -> Bomb? {
        guard canPlaceBomb() else { return nil }
        
        let bomb = Bomb(owner: self, firePower: firePower, isRemote: hasRemoteControl)
        bomb.setGridPosition(gridPosition)
        
        currentBombs += 1
        placedBombs.append(bomb)
        
        return bomb
    }
    
    /// 爆弾爆発時のコールバック
    func onBombExploded(_ bomb: Bomb) {
        currentBombs = max(0, currentBombs - 1)
        placedBombs.removeAll { $0 === bomb }
    }
    
    /// リモコン爆弾を起爆
    func detonateRemoteBombs() {
        guard hasRemoteControl else { return }
        
        let remoteBombs = placedBombs.filter { $0.isRemote }
        for bomb in remoteBombs {
            bomb.explode()
        }
    }
    
    // MARK: - Items
    
    /// アイテムを取得
    func collectItem(_ itemType: ItemType) {
        switch itemType {
        case .fireUp:
            firePower = min(firePower + 1, config.maxFirePower)
        case .bombUp:
            maxBombs = min(maxBombs + 1, config.maxBombCount)
        case .speedUp:
            moveSpeed = min(moveSpeed + config.speedUpIncrement, config.playerMaxSpeed)
        case .remoteControl:
            hasRemoteControl = true
        case .wallPass:
            canPassWalls = true
        case .bombPass:
            canPassBombs = true
        case .invincible:
            activateInvincibility()
        }
        
        // アイテム取得エフェクト
        pulse()
    }
    
    /// 無敵状態を発動
    private func activateInvincibility() {
        isInvincible = true
        
        // 点滅エフェクト
        let blink = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.5, duration: 0.2),
            SKAction.fadeAlpha(to: 1.0, duration: 0.2)
        ])
        let blinkForever = SKAction.repeatForever(blink)
        run(blinkForever, withKey: "invincibleBlink")
        
        // 一定時間後に無敵解除
        run(SKAction.sequence([
            SKAction.wait(forDuration: config.invincibilityDuration),
            SKAction.run { [weak self] in
                self?.deactivateInvincibility()
            }
        ]), withKey: "invincibleTimer")
    }
    
    /// 無敵状態を解除
    private func deactivateInvincibility() {
        isInvincible = false
        removeAction(forKey: "invincibleBlink")
        alpha = 1.0
    }
    
    // MARK: - Damage
    
    /// ダメージを受ける
    func takeDamage() {
        guard !isInvincible && !isDead else { return }
        
        lives -= 1
        
        if lives <= 0 {
            die()
        } else {
            // 一時的な無敵状態
            activateTemporaryInvincibility()
        }
    }
    
    /// 一時的な無敵状態（ダメージ後）
    private func activateTemporaryInvincibility() {
        isInvincible = true
        
        let blink = SKAction.blink(duration: 0.2, count: 10)
        run(blink) { [weak self] in
            self?.isInvincible = false
        }
    }
    
    /// 死亡処理
    func die() {
        isDead = true
        physicsBody?.velocity = .zero
        
        // 死亡アニメーション
        let shrink = SKAction.scale(to: 0, duration: 0.5)
        let rotate = SKAction.rotate(byAngle: .pi * 2, duration: 0.5)
        let deathAnimation = SKAction.group([shrink, rotate])
        
        run(deathAnimation) { [weak self] in
            self?.removeFromParent()
        }
        
        // ゲームオーバー通知
        NotificationCenter.default.post(name: .playerDied, object: self)
    }
    
    /// リスポーン
    func respawn(at position: GridPosition) {
        isDead = false
        setGridPosition(position)
        setScale(1.0)
        alpha = 1.0
        activateTemporaryInvincibility()
    }
    
    // MARK: - Helper
    
    /// プレイヤーIDに対応する色を取得
    static func colorForPlayerID(_ id: Int) -> SKColor {
        switch id {
        case 1: return SKColor(hex: "#3498DB")  // 青
        case 2: return SKColor(hex: "#E74C3C")  // 赤
        case 3: return SKColor(hex: "#2ECC71")  // 緑
        case 4: return SKColor(hex: "#F1C40F")  // 黄
        default: return SKColor(hex: "#9B59B6") // 紫
        }
    }
    
    /// 状態のリセット
    func reset() {
        moveSpeed = config.playerBaseSpeed
        maxBombs = config.initialBombCount
        firePower = config.initialFirePower
        currentBombs = 0
        hasRemoteControl = false
        canPassWalls = false
        canPassBombs = false
        isInvincible = false
        isDead = false
        placedBombs.removeAll()
        score = 0
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let playerDied = Notification.Name("playerDied")
}
