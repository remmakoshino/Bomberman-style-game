//
//  InputController.swift
//  BombermanGame
//
//  入力制御システム
//

import Foundation
import SpriteKit

/// 入力コントローラー - タッチ入力とバーチャルパッドの管理
final class InputController {
    
    // MARK: - Properties
    
    /// 親シーン
    weak var scene: SKScene?
    
    /// 方向変更コールバック
    var onDirectionChanged: ((Direction?) -> Void)?
    
    /// 爆弾ボタンコールバック
    var onBombButtonPressed: (() -> Void)?
    
    /// スペシャルボタンコールバック（リモコン起爆など）
    var onSpecialButtonPressed: (() -> Void)?
    
    /// 現在の入力方向
    private(set) var currentDirection: Direction?
    
    /// 仮想パッドの中心位置
    private var padCenter: CGPoint = .zero
    
    /// パッドのタッチID
    private var padTouchID: UITouch?
    
    /// ボタンのタッチID
    private var bombTouchID: UITouch?
    
    // MARK: - UI Elements
    
    /// パッドコンテナ
    private var padContainer: SKNode?
    
    /// パッドベース
    private var padBase: SKShapeNode?
    
    /// パッドスティック
    private var padStick: SKShapeNode?
    
    /// 爆弾ボタン
    private var bombButton: SKNode?
    
    /// スペシャルボタン
    private var specialButton: SKNode?
    
    // MARK: - Configuration
    
    /// パッドの半径
    private let padRadius: CGFloat = 60
    
    /// スティックの半径
    private let stickRadius: CGFloat = 25
    
    /// デッドゾーン（この範囲内は入力なしとみなす）
    private let deadZone: CGFloat = 0.2
    
    /// ボタンのサイズ
    private let buttonSize: CGFloat = 60
    
    // MARK: - Initialization
    
    init(scene: SKScene) {
        self.scene = scene
        setupVirtualPad()
        setupButtons()
    }
    
    // MARK: - Setup
    
    private func setupVirtualPad() {
        guard let scene = scene else { return }
        
        let margin: CGFloat = 30
        padCenter = CGPoint(x: margin + padRadius, y: margin + padRadius)
        
        // パッドコンテナ
        let container = SKNode()
        container.position = padCenter
        container.zPosition = Constants.zPositionUI + 10
        container.name = "padContainer"
        scene.addChild(container)
        padContainer = container
        
        // パッドベース（外側の円）
        let base = SKShapeNode(circleOfRadius: padRadius)
        base.fillColor = SKColor.black.withAlphaComponent(0.3)
        base.strokeColor = SKColor.white.withAlphaComponent(0.5)
        base.lineWidth = 3
        base.name = "padBase"
        container.addChild(base)
        padBase = base
        
        // 方向インジケータ
        for direction in Direction.allCases {
            let indicator = createDirectionIndicator(direction)
            base.addChild(indicator)
        }
        
        // スティック
        let stick = SKShapeNode(circleOfRadius: stickRadius)
        stick.fillColor = SKColor.white.withAlphaComponent(0.7)
        stick.strokeColor = SKColor.white
        stick.lineWidth = 2
        stick.name = "padStick"
        container.addChild(stick)
        padStick = stick
    }
    
    private func createDirectionIndicator(_ direction: Direction) -> SKNode {
        let indicator = SKShapeNode(path: createArrowPath())
        indicator.fillColor = SKColor.white.withAlphaComponent(0.3)
        indicator.strokeColor = .clear
        
        let offset = padRadius * 0.7
        switch direction {
        case .up:
            indicator.position = CGPoint(x: 0, y: offset)
            indicator.zRotation = 0
        case .down:
            indicator.position = CGPoint(x: 0, y: -offset)
            indicator.zRotation = .pi
        case .left:
            indicator.position = CGPoint(x: -offset, y: 0)
            indicator.zRotation = .pi / 2
        case .right:
            indicator.position = CGPoint(x: offset, y: 0)
            indicator.zRotation = -.pi / 2
        }
        
        return indicator
    }
    
    private func createArrowPath() -> CGPath {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: 10))
        path.addLine(to: CGPoint(x: -8, y: -5))
        path.addLine(to: CGPoint(x: 8, y: -5))
        path.closeSubpath()
        return path
    }
    
    private func setupButtons() {
        guard let scene = scene else { return }
        
        let margin: CGFloat = 30
        let buttonX = scene.size.width - margin - buttonSize / 2
        let buttonY = margin + buttonSize / 2
        
        // 爆弾ボタン
        bombButton = createButton(
            text: "💣",
            color: SKColor(hex: "#E74C3C"),
            position: CGPoint(x: buttonX, y: buttonY),
            name: "bombButton"
        )
        scene.addChild(bombButton!)
        
        // スペシャルボタン（リモコン起爆用）
        specialButton = createButton(
            text: "⚡",
            color: SKColor(hex: "#F39C12"),
            position: CGPoint(x: buttonX - buttonSize - 20, y: buttonY),
            name: "specialButton"
        )
        specialButton?.alpha = 0.5 // 初期状態では半透明
        scene.addChild(specialButton!)
    }
    
    private func createButton(text: String, color: SKColor, position: CGPoint, name: String) -> SKNode {
        let container = SKNode()
        container.position = position
        container.zPosition = Constants.zPositionUI + 10
        container.name = name
        
        let background = SKShapeNode(circleOfRadius: buttonSize / 2)
        background.fillColor = color.withAlphaComponent(0.8)
        background.strokeColor = .white
        background.lineWidth = 3
        container.addChild(background)
        
        let label = SKLabelNode(text: text)
        label.fontSize = 28
        label.verticalAlignmentMode = .center
        container.addChild(label)
        
        return container
    }
    
    // MARK: - Touch Handling
    
    func handleTouchesBegan(_ touches: Set<UITouch>) {
        guard let scene = scene else { return }
        
        for touch in touches {
            let location = touch.location(in: scene)
            
            // パッドエリアのチェック
            if isInPadArea(location) && padTouchID == nil {
                padTouchID = touch
                updatePadInput(touch)
            }
            
            // ボタンのチェック
            let nodes = scene.nodes(at: location)
            for node in nodes {
                if node.name == "bombButton" || node.parent?.name == "bombButton" {
                    bombTouchID = touch
                    animateButtonPress(bombButton)
                    onBombButtonPressed?()
                } else if node.name == "specialButton" || node.parent?.name == "specialButton" {
                    animateButtonPress(specialButton)
                    onSpecialButtonPressed?()
                }
            }
        }
    }
    
    func handleTouchesMoved(_ touches: Set<UITouch>) {
        for touch in touches {
            if touch == padTouchID {
                updatePadInput(touch)
            }
        }
    }
    
    func handleTouchesEnded(_ touches: Set<UITouch>) {
        for touch in touches {
            if touch == padTouchID {
                padTouchID = nil
                resetPad()
            }
            if touch == bombTouchID {
                bombTouchID = nil
                animateButtonRelease(bombButton)
            }
        }
    }
    
    // MARK: - Input Processing
    
    private func isInPadArea(_ location: CGPoint) -> Bool {
        let distance = location.distance(to: padCenter)
        return distance <= padRadius * 1.5
    }
    
    private func updatePadInput(_ touch: UITouch) {
        guard let scene = scene else { return }
        
        let location = touch.location(in: scene)
        let offset = CGPoint(x: location.x - padCenter.x, y: location.y - padCenter.y)
        let distance = hypot(offset.x, offset.y)
        
        // スティックの位置を更新
        let maxDistance = padRadius - stickRadius
        let clampedDistance = min(distance, maxDistance)
        let normalizedOffset: CGPoint
        
        if distance > 0 {
            normalizedOffset = CGPoint(
                x: offset.x / distance * clampedDistance,
                y: offset.y / distance * clampedDistance
            )
        } else {
            normalizedOffset = .zero
        }
        
        padStick?.position = normalizedOffset
        
        // 方向の判定
        let normalizedDistance = distance / padRadius
        
        if normalizedDistance < deadZone {
            setDirection(nil)
        } else {
            let angle = atan2(offset.y, offset.x)
            let direction = angleToDirection(angle)
            setDirection(direction)
        }
    }
    
    private func angleToDirection(_ angle: CGFloat) -> Direction {
        // -π から π の角度を4方向に変換
        let degrees = angle * 180 / .pi
        
        if degrees >= -45 && degrees < 45 {
            return .right
        } else if degrees >= 45 && degrees < 135 {
            return .up
        } else if degrees >= -135 && degrees < -45 {
            return .down
        } else {
            return .left
        }
    }
    
    private func setDirection(_ direction: Direction?) {
        guard direction != currentDirection else { return }
        currentDirection = direction
        onDirectionChanged?(direction)
    }
    
    private func resetPad() {
        padStick?.run(SKAction.move(to: .zero, duration: 0.1))
        setDirection(nil)
    }
    
    // MARK: - Button Animation
    
    private func animateButtonPress(_ button: SKNode?) {
        button?.run(SKAction.scale(to: 0.9, duration: 0.1))
    }
    
    private func animateButtonRelease(_ button: SKNode?) {
        button?.run(SKAction.scale(to: 1.0, duration: 0.1))
    }
    
    // MARK: - Special Button State
    
    /// スペシャルボタンの有効/無効を設定
    func setSpecialButtonEnabled(_ enabled: Bool) {
        specialButton?.alpha = enabled ? 1.0 : 0.5
    }
}
