//
//  GameViewController.swift
//  BombermanGame
//
//  ゲームのビューコントローラー
//

import UIKit
import SpriteKit

/// ゲームビューコントローラー - SpriteKitビューの管理
class GameViewController: UIViewController {
    
    // MARK: - Properties
    
    /// SpriteKitビュー
    var skView: SKView {
        return view as! SKView
    }
    
    /// 現在のゲームシーン
    private var gameScene: GameScene?
    
    // MARK: - Lifecycle
    
    override func loadView() {
        view = SKView(frame: UIScreen.main.bounds)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        showMainMenu()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // ステータスバーを非表示
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeLeft
    }
    
    // MARK: - Setup
    
    private func configureView() {
        skView.ignoresSiblingOrder = true
        
        #if DEBUG
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.showsPhysics = false
        #endif
    }
    
    // MARK: - Scene Management
    
    /// メインメニューを表示
    func showMainMenu() {
        let menuScene = MainMenuScene(size: calculateSceneSize())
        menuScene.scaleMode = .aspectFill
        menuScene.menuDelegate = self
        
        skView.presentScene(menuScene, transition: .fade(withDuration: 0.5))
    }
    
    /// ゲームを開始
    func startGame(difficulty: GameConfig.Difficulty = .normal) {
        GameConfig.shared.currentDifficulty = difficulty
        
        let scene = GameScene(size: calculateSceneSize())
        scene.scaleMode = .aspectFill
        gameScene = scene
        
        skView.presentScene(scene, transition: .fade(withDuration: 0.5))
    }
    
    /// ゲームシーンのサイズを計算
    private func calculateSceneSize() -> CGSize {
        // ゲームグリッドに基づいたサイズ
        let gridWidth = CGFloat(Constants.gridColumns) * Constants.tileSize
        let gridHeight = CGFloat(Constants.gridRows) * Constants.tileSize
        
        // UI用の余白を追加
        let uiMargin: CGFloat = 60
        
        return CGSize(
            width: max(gridWidth + 100, 800),
            height: gridHeight + uiMargin
        )
    }
    
    // MARK: - Memory Warning
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // キャッシュをクリア
        SKTextureAtlas.preloadTextureAtlasesNamed([]) { error, atlases in
            // 必要に応じてテクスチャを再ロード
        }
    }
}

// MARK: - MainMenuDelegate

extension GameViewController: MainMenuDelegate {
    func mainMenuDidSelectStart(difficulty: GameConfig.Difficulty) {
        startGame(difficulty: difficulty)
    }
    
    func mainMenuDidSelectSettings() {
        // 設定画面を表示（将来の実装）
    }
}

// MARK: - Main Menu Scene

/// メインメニューデリゲート
protocol MainMenuDelegate: AnyObject {
    func mainMenuDidSelectStart(difficulty: GameConfig.Difficulty)
    func mainMenuDidSelectSettings()
}

/// メインメニューシーン
class MainMenuScene: SKScene {
    
    weak var menuDelegate: MainMenuDelegate?
    
    private var selectedDifficulty: GameConfig.Difficulty = .normal
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor(hex: "#1a1a2e")
        
        setupTitle()
        setupMenu()
    }
    
    private func setupTitle() {
        // タイトルロゴ
        let title = SKLabelNode(fontNamed: "Helvetica-Bold")
        title.text = "BOMBERMAN"
        title.fontSize = 64
        title.fontColor = SKColor(hex: "#F39C12")
        title.position = CGPoint(x: size.width / 2, y: size.height * 0.75)
        addChild(title)
        
        // サブタイトル
        let subtitle = SKLabelNode(fontNamed: "Helvetica")
        subtitle.text = "iOS Edition"
        subtitle.fontSize = 24
        subtitle.fontColor = .white
        subtitle.position = CGPoint(x: size.width / 2, y: size.height * 0.75 - 40)
        addChild(subtitle)
        
        // アニメーション
        let scale = SKAction.sequence([
            SKAction.scale(to: 1.05, duration: 1.0),
            SKAction.scale(to: 1.0, duration: 1.0)
        ])
        title.run(SKAction.repeatForever(scale))
    }
    
    private func setupMenu() {
        let buttonY = size.height * 0.45
        let buttonSpacing: CGFloat = 60
        
        // スタートボタン
        let startButton = createButton(text: "START GAME", name: "startButton")
        startButton.position = CGPoint(x: size.width / 2, y: buttonY)
        addChild(startButton)
        
        // 難易度選択
        let difficultyLabel = SKLabelNode(fontNamed: "Helvetica")
        difficultyLabel.text = "Difficulty: \(selectedDifficulty.rawValue)"
        difficultyLabel.fontSize = 20
        difficultyLabel.fontColor = .white
        difficultyLabel.name = "difficultyLabel"
        difficultyLabel.position = CGPoint(x: size.width / 2, y: buttonY - buttonSpacing)
        addChild(difficultyLabel)
        
        // 難易度変更ボタン
        let leftArrow = createArrowButton(direction: "left", name: "difficultyLeft")
        leftArrow.position = CGPoint(x: size.width / 2 - 120, y: buttonY - buttonSpacing)
        addChild(leftArrow)
        
        let rightArrow = createArrowButton(direction: "right", name: "difficultyRight")
        rightArrow.position = CGPoint(x: size.width / 2 + 120, y: buttonY - buttonSpacing)
        addChild(rightArrow)
        
        // 設定ボタン（将来用）
        let settingsButton = createButton(text: "SETTINGS", name: "settingsButton")
        settingsButton.position = CGPoint(x: size.width / 2, y: buttonY - buttonSpacing * 2)
        settingsButton.alpha = 0.5 // 未実装のため薄く表示
        addChild(settingsButton)
        
        // クレジット
        let credits = SKLabelNode(fontNamed: "Helvetica")
        credits.text = "© 2025 Bomberman iOS"
        credits.fontSize = 14
        credits.fontColor = SKColor.gray
        credits.position = CGPoint(x: size.width / 2, y: 30)
        addChild(credits)
    }
    
    private func createButton(text: String, name: String) -> SKNode {
        let container = SKNode()
        container.name = name
        
        let background = SKShapeNode(rectOf: CGSize(width: 200, height: 50), cornerRadius: 10)
        background.fillColor = SKColor(hex: "#3498DB")
        background.strokeColor = .white
        background.lineWidth = 2
        container.addChild(background)
        
        let label = SKLabelNode(fontNamed: "Helvetica-Bold")
        label.text = text
        label.fontSize = 20
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        container.addChild(label)
        
        return container
    }
    
    private func createArrowButton(direction: String, name: String) -> SKNode {
        let container = SKNode()
        container.name = name
        
        let background = SKShapeNode(circleOfRadius: 20)
        background.fillColor = SKColor(hex: "#2C3E50")
        background.strokeColor = .white
        container.addChild(background)
        
        let arrow = SKLabelNode(fontNamed: "Helvetica-Bold")
        arrow.text = direction == "left" ? "◀" : "▶"
        arrow.fontSize = 16
        arrow.fontColor = .white
        arrow.verticalAlignmentMode = .center
        container.addChild(arrow)
        
        return container
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = nodes(at: location)
        
        for node in nodes {
            switch node.name {
            case "startButton":
                animateButton(node) { [weak self] in
                    guard let self = self else { return }
                    self.menuDelegate?.mainMenuDidSelectStart(difficulty: self.selectedDifficulty)
                }
                
            case "difficultyLeft":
                changeDifficulty(delta: -1)
                
            case "difficultyRight":
                changeDifficulty(delta: 1)
                
            case "settingsButton":
                // 未実装
                break
                
            default:
                break
            }
        }
    }
    
    private func animateButton(_ node: SKNode, completion: @escaping () -> Void) {
        let scaleDown = SKAction.scale(to: 0.9, duration: 0.1)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
        node.run(SKAction.sequence([scaleDown, scaleUp])) {
            completion()
        }
    }
    
    private func changeDifficulty(delta: Int) {
        let difficulties = GameConfig.Difficulty.allCases
        guard let currentIndex = difficulties.firstIndex(of: selectedDifficulty) else { return }
        
        var newIndex = currentIndex + delta
        if newIndex < 0 { newIndex = difficulties.count - 1 }
        if newIndex >= difficulties.count { newIndex = 0 }
        
        selectedDifficulty = difficulties[newIndex]
        
        if let label = childNode(withName: "difficultyLabel") as? SKLabelNode {
            label.text = "Difficulty: \(selectedDifficulty.rawValue)"
        }
    }
}
