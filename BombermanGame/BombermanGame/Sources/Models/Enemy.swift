//
//  Enemy.swift
//  BombermanGame
//
//  敵キャラクターの管理
//

import Foundation
import SpriteKit

/// 敵の種類
enum EnemyType: String, CaseIterable {
    case balloon = "Balloon"    // 基本的な敵（遅い、壁抜け不可）
    case onil = "Onil"          // やや速い敵
    case dahl = "Dahl"          // 速い敵
    case minvo = "Minvo"        // 壁抜け可能
    case ovape = "Ovape"        // 高速、壁抜け可能
    
    /// 移動速度の倍率
    var speedMultiplier: CGFloat {
        switch self {
        case .balloon: return 0.8
        case .onil: return 1.0
        case .dahl: return 1.3
        case .minvo: return 1.0
        case .ovape: return 1.5
        }
    }
    
    /// 壁すり抜け能力
    var canPassWalls: Bool {
        switch self {
        case .minvo, .ovape: return true
        default: return false
        }
    }
    
    /// スコア
    var scoreValue: Int {
        switch self {
        case .balloon: return 100
        case .onil: return 200
        case .dahl: return 400
        case .minvo: return 800
        case .ovape: return 1000
        }
    }
    
    /// 色
    var color: String {
        switch self {
        case .balloon: return "#E74C3C"
        case .onil: return "#9B59B6"
        case .dahl: return "#3498DB"
        case .minvo: return "#2ECC71"
        case .ovape: return "#F39C12"
        }
    }
}

/// 敵クラス - 敵キャラクターの状態と動作を管理
final class Enemy: SKSpriteNode {
    
    // MARK: - Properties
    
    /// 敵のID
    let enemyID: UUID = UUID()
    
    /// 敵の種類
    let enemyType: EnemyType
    
    /// 現在のグリッド位置
    var gridPosition: GridPosition {
        return GridPosition.fromPoint(position)
    }
    
    /// 移動速度
    var moveSpeed: CGFloat
    
    /// 壁すり抜け能力
    var canPassWalls: Bool
    
    /// 現在の移動方向
    private var currentDirection: Direction?
    
    /// 方向転換タイマー
    private var directionChangeTimer: TimeInterval = 0
    
    /// 死亡状態
    private(set) var isDead: Bool = false
    
    /// グリッドシステムへの参照
    weak var gridSystem: GridSystem?
    
    /// 死亡時のコールバック
    var onDeath: ((Enemy) -> Void)?
    
    // MARK: - AI Properties
    
    /// AIレベル（1-5）
    var aiLevel: Int
    
    /// プレイヤー追跡モード
    var isChasing: Bool = false
    
    /// ターゲットプレイヤー
    weak var targetPlayer: Player?
    
    // MARK: - Initialization
    
    init(type: EnemyType, aiLevel: Int = 1) {
        self.enemyType = type
        self.aiLevel = aiLevel
        self.moveSpeed = Constants.enemyBaseSpeed * type.speedMultiplier
        self.canPassWalls = type.canPassWalls
        
        let size = CGSize(width: Constants.tileSize * 0.75, height: Constants.tileSize * 0.75)
        let color = SKColor(hex: type.color)
        
        super.init(texture: nil, color: color, size: size)
        
        self.name = "enemy_\(enemyID.uuidString)"
        self.zPosition = Constants.zPositionCharacter
        
        setupAppearance()
        setupPhysics()
        
        // 初期方向をランダムに設定
        currentDirection = Direction.allCases.randomElement()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupAppearance() {
        // 敵の外観設定（丸みを帯びた形）
        let body = SKShapeNode(circleOfRadius: size.width / 2)
        body.fillColor = color
        body.strokeColor = SKColor(hex: enemyType.color).withAlpha(0.7)
        body.lineWidth = 2
        body.zPosition = 0
        addChild(body)
        
        // 目
        let eyeSize: CGFloat = 6
        let eyeY: CGFloat = size.height * 0.1
        
        let leftEye = SKShapeNode(circleOfRadius: eyeSize / 2)
        leftEye.fillColor = .white
        leftEye.strokeColor = .clear
        leftEye.position = CGPoint(x: -size.width * 0.2, y: eyeY)
        leftEye.zPosition = 1
        addChild(leftEye)
        
        let rightEye = SKShapeNode(circleOfRadius: eyeSize / 2)
        rightEye.fillColor = .white
        rightEye.strokeColor = .clear
        rightEye.position = CGPoint(x: size.width * 0.2, y: eyeY)
        rightEye.zPosition = 1
        addChild(rightEye)
        
        // 瞳
        let pupilSize: CGFloat = 3
        
        let leftPupil = SKShapeNode(circleOfRadius: pupilSize / 2)
        leftPupil.fillColor = .black
        leftPupil.name = "leftPupil"
        leftEye.addChild(leftPupil)
        
        let rightPupil = SKShapeNode(circleOfRadius: pupilSize / 2)
        rightPupil.fillColor = .black
        rightPupil.name = "rightPupil"
        rightEye.addChild(rightPupil)
        
        // 本体を透明に
        self.color = .clear
        
        // アイドルアニメーション
        startIdleAnimation()
    }
    
    private func setupPhysics() {
        let physicsSize = CGSize(width: size.width * 0.7, height: size.height * 0.7)
        physicsBody = SKPhysicsBody(circleOfRadius: physicsSize.width / 2)
        physicsBody?.isDynamic = true
        physicsBody?.allowsRotation = false
        physicsBody?.friction = 0
        physicsBody?.restitution = 0
        physicsBody?.linearDamping = 0
        physicsBody?.categoryBitMask = Constants.categoryEnemy
        physicsBody?.contactTestBitMask = Constants.categoryPlayer | Constants.categoryExplosion
        physicsBody?.collisionBitMask = Constants.categoryHardBlock | Constants.categorySoftBlock | Constants.categoryBomb
    }
    
    private func startIdleAnimation() {
        // ぴょんぴょん跳ねるアニメーション
        let squash = SKAction.scaleY(to: 0.9, duration: 0.2)
        let stretch = SKAction.scaleY(to: 1.1, duration: 0.2)
        let normalize = SKAction.scaleY(to: 1.0, duration: 0.1)
        
        squash.timingMode = .easeInEaseOut
        stretch.timingMode = .easeInEaseOut
        
        let bounce = SKAction.sequence([squash, stretch, normalize])
        run(SKAction.repeatForever(bounce), withKey: "idleAnimation")
    }
    
    // MARK: - Update
    
    /// 毎フレームの更新
    func update(deltaTime: TimeInterval, gridSystem: GridSystem, players: [Player]) {
        guard !isDead else { return }
        
        self.gridSystem = gridSystem
        
        // 方向転換タイマー更新
        directionChangeTimer -= deltaTime
        
        // AI行動の決定
        decideAction(players: players)
        
        // 移動
        if let direction = currentDirection {
            moveInDirection(direction, deltaTime: deltaTime)
            updatePupilDirection(direction)
        }
    }
    
    // MARK: - AI
    
    private func decideAction(players: [Player]) {
        // 最も近いプレイヤーを探す
        let alivePlayers = players.filter { !$0.isDead }
        guard let nearestPlayer = findNearestPlayer(from: alivePlayers) else {
            randomWalk()
            return
        }
        
        targetPlayer = nearestPlayer
        
        // AIレベルに応じた行動
        switch aiLevel {
        case 1:
            // レベル1: ランダム移動
            randomWalk()
            
        case 2:
            // レベル2: 30%の確率でプレイヤーを追跡
            if Double.random(in: 0...1) < 0.3 {
                chasePlayer(nearestPlayer)
            } else {
                randomWalk()
            }
            
        case 3:
            // レベル3: 50%の確率でプレイヤーを追跡
            if Double.random(in: 0...1) < 0.5 {
                chasePlayer(nearestPlayer)
            } else {
                randomWalk()
            }
            
        case 4, 5:
            // レベル4-5: 70%の確率でプレイヤーを追跡、爆弾回避あり
            if Double.random(in: 0...1) < 0.7 {
                chasePlayer(nearestPlayer)
            } else {
                randomWalk()
            }
            
        default:
            randomWalk()
        }
    }
    
    private func findNearestPlayer(from players: [Player]) -> Player? {
        var nearestPlayer: Player?
        var nearestDistance: CGFloat = .infinity
        
        for player in players {
            let distance = position.distance(to: player.position)
            if distance < nearestDistance {
                nearestDistance = distance
                nearestPlayer = player
            }
        }
        
        return nearestPlayer
    }
    
    private func randomWalk() {
        guard directionChangeTimer <= 0 else { return }
        
        // ランダムに方向を変更
        guard let gridSystem = gridSystem else { return }
        
        let walkableDirections = Direction.allCases.filter { direction in
            let nextPos = gridPosition.adjacent(in: direction)
            return gridSystem.isWalkable(at: nextPos, canPassWalls: canPassWalls)
        }
        
        if let newDirection = walkableDirections.randomElement() {
            currentDirection = newDirection
        }
        
        directionChangeTimer = Constants.enemyDirectionChangeInterval * Double.random(in: 0.5...1.5)
    }
    
    private func chasePlayer(_ player: Player) {
        guard let gridSystem = gridSystem else {
            randomWalk()
            return
        }
        
        let playerPos = player.gridPosition
        let myPos = gridPosition
        
        // プレイヤーへの方向を計算
        var preferredDirections: [Direction] = []
        
        if playerPos.x > myPos.x {
            preferredDirections.append(.right)
        } else if playerPos.x < myPos.x {
            preferredDirections.append(.left)
        }
        
        if playerPos.y > myPos.y {
            preferredDirections.append(.up)
        } else if playerPos.y < myPos.y {
            preferredDirections.append(.down)
        }
        
        // 優先方向から通行可能なものを選択
        for direction in preferredDirections {
            let nextPos = gridPosition.adjacent(in: direction)
            if gridSystem.isWalkable(at: nextPos, canPassWalls: canPassWalls) {
                currentDirection = direction
                return
            }
        }
        
        // 優先方向が通れない場合はランダム
        randomWalk()
    }
    
    // MARK: - Movement
    
    private func moveInDirection(_ direction: Direction, deltaTime: TimeInterval) {
        guard let gridSystem = gridSystem else { return }
        
        let velocity = moveSpeed * Constants.tileSize
        let movement = direction.vector * velocity
        
        // 次の位置を計算
        let predictedPosition = CGPoint(
            x: position.x + movement.dx * CGFloat(deltaTime),
            y: position.y + movement.dy * CGFloat(deltaTime)
        )
        
        let predictedGridPos = GridPosition.fromPoint(predictedPosition)
        
        if gridSystem.isWalkable(at: predictedGridPos, canPassWalls: canPassWalls) {
            physicsBody?.velocity = CGVector(dx: movement.dx, dy: movement.dy)
        } else {
            // 壁にぶつかった場合
            physicsBody?.velocity = .zero
            directionChangeTimer = 0 // すぐに方向転換
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
    
    // MARK: - Damage
    
    /// ダメージを受けて死亡
    func die() {
        guard !isDead else { return }
        
        isDead = true
        physicsBody?.velocity = .zero
        removeAction(forKey: "idleAnimation")
        
        // 死亡アニメーション
        let flash = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.3, duration: 0.05),
            SKAction.fadeAlpha(to: 1.0, duration: 0.05)
        ])
        let flashSequence = SKAction.repeat(flash, count: 5)
        
        let shrink = SKAction.scale(to: 0, duration: 0.3)
        let rotate = SKAction.rotate(byAngle: .pi * 2, duration: 0.3)
        let death = SKAction.group([shrink, rotate])
        
        let sequence = SKAction.sequence([flashSequence, death])
        
        run(sequence) { [weak self] in
            guard let self = self else { return }
            self.onDeath?(self)
            self.removeFromParent()
        }
    }
}

// MARK: - Enemy Factory

/// 敵生成用のファクトリー
enum EnemyFactory {
    
    /// 指定タイプの敵を生成
    static func createEnemy(type: EnemyType, at position: GridPosition, aiLevel: Int = 1) -> Enemy {
        let enemy = Enemy(type: type, aiLevel: aiLevel)
        enemy.setGridPosition(position)
        return enemy
    }
    
    /// ステージに応じた敵を生成
    static func createEnemiesForStage(_ stage: Int, gridSystem: GridSystem) -> [Enemy] {
        var enemies: [Enemy] = []
        
        // ステージに応じて敵の数と種類を決定
        let enemyCount = min(3 + stage, 10)
        let aiLevel = min(1 + stage / 3, 5)
        
        // 空きマスを取得
        var emptyPositions: [GridPosition] = []
        for x in 2..<(Constants.gridColumns - 2) {
            for y in 2..<(Constants.gridRows - 2) {
                let pos = GridPosition(x: x, y: y)
                if gridSystem.getTile(at: pos) == .empty {
                    emptyPositions.append(pos)
                }
            }
        }
        
        // ランダムに位置を選択して敵を配置
        emptyPositions.shuffle()
        
        for i in 0..<min(enemyCount, emptyPositions.count) {
            let type = selectEnemyType(for: stage)
            let enemy = createEnemy(type: type, at: emptyPositions[i], aiLevel: aiLevel)
            enemies.append(enemy)
        }
        
        return enemies
    }
    
    private static func selectEnemyType(for stage: Int) -> EnemyType {
        switch stage {
        case 1...2:
            return .balloon
        case 3...4:
            return [.balloon, .onil].randomElement()!
        case 5...6:
            return [.balloon, .onil, .dahl].randomElement()!
        case 7...8:
            return [.onil, .dahl, .minvo].randomElement()!
        default:
            return EnemyType.allCases.randomElement()!
        }
    }
}
