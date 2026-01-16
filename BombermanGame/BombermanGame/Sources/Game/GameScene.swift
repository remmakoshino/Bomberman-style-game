//
//  GameScene.swift
//  BombermanGame
//
//  メインゲームシーン
//

import SpriteKit
import GameplayKit

/// メインゲームシーン - ゲームプレイの中心
final class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - Properties
    
    /// ゲームマネージャー
    private var gameManager: GameManager!
    
    /// グリッドシステム
    private var gridSystem: GridSystem!
    
    /// プレイヤー
    private var player: Player!
    
    /// 敵のリスト
    private var enemies: [Enemy] = []
    
    /// 爆弾のリスト
    private var bombs: [Bomb] = []
    
    /// アイテムのリスト
    private var items: [Item] = []
    
    /// ブロックのリスト
    private var blocks: [Block] = []
    
    /// 入力コントローラー
    private var inputController: InputController!
    
    /// 前回のフレーム時間
    private var lastUpdateTime: TimeInterval = 0
    
    /// ゲームレイヤー
    private var gameLayer: SKNode!
    private var uiLayer: SKNode!
    
    /// UI要素
    private var scoreLabel: SKLabelNode!
    private var livesLabel: SKLabelNode!
    private var stageLabel: SKLabelNode!
    
    /// ゲーム状態
    private var isGamePaused: Bool = false
    
    // MARK: - Lifecycle
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        setupScene()
        setupGame()
        setupUI()
        setupInputController()
        setupNotifications()
    }
    
    override func willMove(from view: SKView) {
        super.willMove(from: view)
        removeNotifications()
    }
    
    // MARK: - Setup
    
    private func setupScene() {
        backgroundColor = SKColor(hex: Constants.backgroundColor)
        
        // 物理ワールドの設定
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        // ゲームレイヤーの作成
        gameLayer = SKNode()
        gameLayer.name = "gameLayer"
        addChild(gameLayer)
        
        // UIレイヤーの作成
        uiLayer = SKNode()
        uiLayer.name = "uiLayer"
        uiLayer.zPosition = Constants.zPositionUI
        addChild(uiLayer)
    }
    
    private func setupGame() {
        // グリッドシステムの初期化
        gridSystem = GridSystem()
        
        // ゲームマネージャーの初期化
        gameManager = GameManager(scene: self, gridSystem: gridSystem)
        
        // マップの生成
        generateMap()
        
        // プレイヤーの配置
        spawnPlayer()
        
        // 敵の配置
        spawnEnemies()
    }
    
    private func setupUI() {
        let margin: CGFloat = 20
        
        // スコアラベル
        scoreLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        scoreLabel.fontSize = 20
        scoreLabel.fontColor = .white
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: margin, y: size.height - margin - 20)
        scoreLabel.text = "Score: 0"
        uiLayer.addChild(scoreLabel)
        
        // 残機ラベル
        livesLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        livesLabel.fontSize = 20
        livesLabel.fontColor = .white
        livesLabel.horizontalAlignmentMode = .center
        livesLabel.position = CGPoint(x: size.width / 2, y: size.height - margin - 20)
        livesLabel.text = "Lives: 3"
        uiLayer.addChild(livesLabel)
        
        // ステージラベル
        stageLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        stageLabel.fontSize = 20
        stageLabel.fontColor = .white
        stageLabel.horizontalAlignmentMode = .right
        stageLabel.position = CGPoint(x: size.width - margin, y: size.height - margin - 20)
        stageLabel.text = "Stage: 1"
        uiLayer.addChild(stageLabel)
    }
    
    private func setupInputController() {
        inputController = InputController(scene: self)
        inputController.onDirectionChanged = { [weak self] direction in
            if let direction = direction {
                self?.player?.startMoving(in: direction)
            } else {
                self?.player?.stopMoving()
            }
        }
        inputController.onBombButtonPressed = { [weak self] in
            self?.placeBomb()
        }
        inputController.onSpecialButtonPressed = { [weak self] in
            self?.player?.detonateRemoteBombs()
        }
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(pauseGame),
            name: .gameShouldPause,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePlayerDeath(_:)),
            name: .playerDied,
            object: nil
        )
    }
    
    private func removeNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Map Generation
    
    private func generateMap() {
        // グリッドマップの生成
        gridSystem.generateStandardMap(softBlockDensity: GameConfig.shared.softBlockDensity)
        
        // ブロックの描画
        for x in 0..<gridSystem.columns {
            for y in 0..<gridSystem.rows {
                let pos = GridPosition(x: x, y: y)
                guard let tile = gridSystem.getTile(at: pos) else { continue }
                
                switch tile {
                case .hardBlock:
                    let block = BlockFactory.createHardBlock(at: pos)
                    blocks.append(block)
                    gameLayer.addChild(block)
                    
                case .softBlock:
                    let block = BlockFactory.createSoftBlock(at: pos, withRandomItem: true)
                    block.onDestroyed = { [weak self] destroyedBlock in
                        self?.onBlockDestroyed(destroyedBlock)
                    }
                    blocks.append(block)
                    gameLayer.addChild(block)
                    
                case .empty, .item:
                    // 背景タイルを描画
                    let bgTile = createBackgroundTile(at: pos)
                    gameLayer.addChild(bgTile)
                }
            }
        }
    }
    
    private func createBackgroundTile(at position: GridPosition) -> SKNode {
        let tile = SKShapeNode(rectOf: CGSize(width: Constants.tileSize, height: Constants.tileSize))
        tile.fillColor = SKColor(hex: "#34495E")
        tile.strokeColor = SKColor(hex: "#2C3E50")
        tile.lineWidth = 1
        tile.position = position.toPoint()
        tile.zPosition = Constants.zPositionBackground
        return tile
    }
    
    // MARK: - Spawn Entities
    
    private func spawnPlayer() {
        player = Player(playerID: 1)
        player.setGridPosition(GridPosition(x: 1, y: 1))
        gameLayer.addChild(player)
        
        // グリッドに登録
        let entity = GridEntity(type: .player, node: player)
        gridSystem.registerEntity(entity, at: player.gridPosition)
    }
    
    private func spawnEnemies() {
        enemies = EnemyFactory.createEnemiesForStage(
            gameManager.currentStage,
            gridSystem: gridSystem
        )
        
        for enemy in enemies {
            enemy.onDeath = { [weak self] deadEnemy in
                self?.onEnemyDeath(deadEnemy)
            }
            gameLayer.addChild(enemy)
            
            let entity = GridEntity(type: .enemy, node: enemy)
            gridSystem.registerEntity(entity, at: enemy.gridPosition)
        }
    }
    
    // MARK: - Game Actions
    
    private func placeBomb() {
        guard let bomb = player?.placeBomb() else { return }
        
        // 爆発コールバック設定
        bomb.onExplode = { [weak self] explodedBomb in
            self?.handleBombExplosion(explodedBomb)
        }
        
        bombs.append(bomb)
        gameLayer.addChild(bomb)
        
        // グリッドに登録
        let entity = GridEntity(type: .bomb, node: bomb)
        gridSystem.registerEntity(entity, at: bomb.gridPosition)
    }
    
    private func handleBombExplosion(_ bomb: Bomb) {
        // 爆弾をリストから削除
        bombs.removeAll { $0.bombID == bomb.bombID }
        
        // グリッドから解除
        let entity = GridEntity(id: bomb.bombID, type: .bomb, node: bomb)
        gridSystem.unregisterEntity(entity, at: bomb.gridPosition)
        
        // 爆発エフェクトを作成
        let explosion = ExplosionFactory.createExplosion(
            at: bomb.gridPosition,
            firePower: bomb.firePower,
            gridSystem: gridSystem
        )
        
        explosion.onComplete = { [weak self] completedExplosion in
            self?.handleExplosionComplete(completedExplosion)
        }
        
        gameLayer.addChild(explosion)
        
        // 爆発の影響を処理
        processExplosionDamage(explosion)
    }
    
    private func processExplosionDamage(_ explosion: Explosion) {
        for pos in explosion.affectedPositions {
            // ブロックの破壊
            if let block = blocks.first(where: { $0.gridPos == pos && !$0.isDestroyed }) {
                if block.blockType == .soft {
                    block.destroy()
                    gridSystem.setTile(.empty, at: pos)
                }
            }
            
            // 連鎖爆発
            if let chainBomb = bombs.first(where: { $0.gridPosition == pos && !$0.hasExploded }) {
                chainBomb.chainExplode(delay: Constants.chainExplosionDelay)
            }
            
            // プレイヤーダメージ
            if player.gridPosition == pos && !player.isDead {
                player.takeDamage()
            }
            
            // 敵ダメージ
            for enemy in enemies where enemy.gridPosition == pos && !enemy.isDead {
                enemy.die()
            }
            
            // アイテム破壊
            if let item = items.first(where: { $0.gridPos == pos && !$0.isCollected }) {
                item.destroyByExplosion()
                items.removeAll { $0 === item }
            }
        }
    }
    
    private func handleExplosionComplete(_ explosion: Explosion) {
        // 爆発終了後の処理（必要に応じて）
    }
    
    // MARK: - Event Handlers
    
    private func onBlockDestroyed(_ block: Block) {
        blocks.removeAll { $0 === block }
        
        // アイテムをドロップ
        if let itemType = block.containedItem {
            let item = ItemFactory.createItem(type: itemType, at: block.gridPos)
            item.onCollected = { [weak self] collectedItem in
                self?.items.removeAll { $0 === collectedItem }
            }
            items.append(item)
            gameLayer.addChild(item)
            gridSystem.setTile(.item, at: block.gridPos)
        }
    }
    
    private func onEnemyDeath(_ enemy: Enemy) {
        enemies.removeAll { $0.enemyID == enemy.enemyID }
        
        // スコア加算
        player.score += enemy.enemyType.scoreValue
        updateUI()
        
        // 全敵撃破チェック
        if enemies.isEmpty {
            stageCleared()
        }
    }
    
    @objc private func handlePlayerDeath(_ notification: Notification) {
        updateUI()
        
        if player.lives <= 0 {
            gameOver()
        } else {
            // リスポーン
            run(SKAction.wait(forDuration: 1.0)) { [weak self] in
                self?.player.respawn(at: GridPosition(x: 1, y: 1))
            }
        }
    }
    
    // MARK: - Game State
    
    private func stageCleared() {
        player.score += GameConfig.shared.stageClearBonus
        gameManager.advanceToNextStage()
        
        showMessage("STAGE CLEAR!") { [weak self] in
            self?.resetStage()
        }
    }
    
    private func resetStage() {
        // クリーンアップ
        bombs.forEach { $0.removeFromParent() }
        bombs.removeAll()
        
        items.forEach { $0.removeFromParent() }
        items.removeAll()
        
        blocks.forEach { $0.removeFromParent() }
        blocks.removeAll()
        
        enemies.forEach { $0.removeFromParent() }
        enemies.removeAll()
        
        // 再生成
        gridSystem.clearGrid()
        generateMap()
        spawnEnemies()
        
        // プレイヤーを初期位置に
        player.setGridPosition(GridPosition(x: 1, y: 1))
        player.currentBombs = 0
        
        updateUI()
    }
    
    private func gameOver() {
        showMessage("GAME OVER") { [weak self] in
            self?.returnToMenu()
        }
    }
    
    private func returnToMenu() {
        // メニューに戻る処理
        // 実際の実装ではシーン遷移を行う
    }
    
    private func showMessage(_ text: String, completion: (() -> Void)? = nil) {
        let label = SKLabelNode(fontNamed: "Helvetica-Bold")
        label.text = text
        label.fontSize = 48
        label.fontColor = .white
        label.position = CGPoint(x: size.width / 2, y: size.height / 2)
        label.zPosition = 1000
        label.alpha = 0
        label.setScale(0.5)
        addChild(label)
        
        let appear = SKAction.group([
            SKAction.fadeIn(withDuration: 0.3),
            SKAction.scale(to: 1.0, duration: 0.3)
        ])
        let wait = SKAction.wait(forDuration: 2.0)
        let disappear = SKAction.fadeOut(withDuration: 0.3)
        let sequence = SKAction.sequence([appear, wait, disappear, SKAction.removeFromParent()])
        
        label.run(sequence) {
            completion?()
        }
    }
    
    @objc private func pauseGame() {
        isGamePaused = true
        isPaused = true
    }
    
    func resumeGame() {
        isGamePaused = false
        isPaused = false
    }
    
    private func updateUI() {
        scoreLabel.text = "Score: \(player.score)"
        livesLabel.text = "Lives: \(player.lives)"
        stageLabel.text = "Stage: \(gameManager.currentStage)"
    }
    
    // MARK: - Update Loop
    
    override func update(_ currentTime: TimeInterval) {
        guard !isGamePaused else { return }
        
        // デルタタイム計算
        let deltaTime = lastUpdateTime == 0 ? 0 : currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        guard deltaTime > 0 else { return }
        
        // プレイヤー更新
        player?.update(deltaTime: deltaTime, gridSystem: gridSystem)
        
        // 敵更新
        for enemy in enemies where !enemy.isDead {
            enemy.update(deltaTime: deltaTime, gridSystem: gridSystem, players: [player])
        }
        
        // アイテム収集チェック
        checkItemCollection()
        
        // 衝突チェック（物理ベースではないもの）
        checkCollisions()
    }
    
    private func checkItemCollection() {
        let playerPos = player.gridPosition
        for item in items where !item.isCollected && item.gridPos == playerPos {
            item.collect(by: player)
            gridSystem.setTile(.empty, at: item.gridPos)
        }
    }
    
    private func checkCollisions() {
        // 敵との衝突チェック
        let playerPos = player.gridPosition
        for enemy in enemies where !enemy.isDead && enemy.gridPosition == playerPos {
            if !player.isInvincible {
                player.takeDamage()
            }
        }
    }
    
    // MARK: - Physics Contact
    
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        // プレイヤーとアイテムの衝突
        if collision == (Constants.categoryPlayer | Constants.categoryItem) {
            // アイテム収集は update で処理
        }
        
        // プレイヤーと爆風の衝突
        if collision == (Constants.categoryPlayer | Constants.categoryExplosion) {
            if !player.isInvincible && !player.isDead {
                player.takeDamage()
            }
        }
        
        // 敵と爆風の衝突
        if collision == (Constants.categoryEnemy | Constants.categoryExplosion) {
            let enemyNode = contact.bodyA.categoryBitMask == Constants.categoryEnemy ?
                contact.bodyA.node : contact.bodyB.node
            if let enemy = enemyNode?.parent?.parent as? Enemy {
                enemy.die()
            }
        }
    }
    
    // MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        inputController?.handleTouchesBegan(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        inputController?.handleTouchesMoved(touches)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        inputController?.handleTouchesEnded(touches)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        inputController?.handleTouchesEnded(touches)
    }
}
