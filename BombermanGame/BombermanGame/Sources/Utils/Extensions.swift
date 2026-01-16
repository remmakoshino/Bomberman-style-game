//
//  Extensions.swift
//  BombermanGame
//
//  便利な拡張機能
//

import Foundation
import SpriteKit
import UIKit

// MARK: - CGPoint Extensions

extension CGPoint {
    
    /// 2点間の距離を計算
    func distance(to point: CGPoint) -> CGFloat {
        return hypot(x - point.x, y - point.y)
    }
    
    /// ベクトルの加算
    static func + (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x + right.x, y: left.y + right.y)
    }
    
    /// ベクトルの減算
    static func - (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x - right.x, y: left.y - right.y)
    }
    
    /// スカラー倍
    static func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
        return CGPoint(x: point.x * scalar, y: point.y * scalar)
    }
    
    /// スカラー除算
    static func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
        return CGPoint(x: point.x / scalar, y: point.y / scalar)
    }
    
    /// グリッド位置への変換
    var gridPosition: GridPosition {
        return GridPosition.fromPoint(self)
    }
    
    /// グリッドの中心座標に補正
    var snappedToGrid: CGPoint {
        let gridPos = self.gridPosition
        return gridPos.toPoint()
    }
}

// MARK: - CGVector Extensions

extension CGVector {
    
    /// ベクトルの長さ
    var length: CGFloat {
        return hypot(dx, dy)
    }
    
    /// 正規化されたベクトル
    var normalized: CGVector {
        let len = length
        guard len > 0 else { return .zero }
        return CGVector(dx: dx / len, dy: dy / len)
    }
    
    /// スカラー倍
    static func * (vector: CGVector, scalar: CGFloat) -> CGVector {
        return CGVector(dx: vector.dx * scalar, dy: vector.dy * scalar)
    }
    
    /// CGPointへの変換
    var point: CGPoint {
        return CGPoint(x: dx, y: dy)
    }
}

// MARK: - SKNode Extensions

extension SKNode {
    
    /// グリッド位置の取得
    var gridPosition: GridPosition {
        return GridPosition.fromPoint(position)
    }
    
    /// グリッド位置の設定
    func setGridPosition(_ gridPos: GridPosition) {
        position = gridPos.toPoint()
    }
    
    /// フェードイン
    func fadeIn(duration: TimeInterval = 0.3, completion: (() -> Void)? = nil) {
        alpha = 0
        let fadeAction = SKAction.fadeIn(withDuration: duration)
        if let completion = completion {
            run(SKAction.sequence([fadeAction, SKAction.run(completion)]))
        } else {
            run(fadeAction)
        }
    }
    
    /// フェードアウト
    func fadeOut(duration: TimeInterval = 0.3, completion: (() -> Void)? = nil) {
        let fadeAction = SKAction.fadeOut(withDuration: duration)
        if let completion = completion {
            run(SKAction.sequence([fadeAction, SKAction.run(completion)]))
        } else {
            run(fadeAction)
        }
    }
    
    /// スケールアニメーション（パルス効果）
    func pulse(scale: CGFloat = 1.1, duration: TimeInterval = 0.2) {
        let scaleUp = SKAction.scale(to: scale, duration: duration / 2)
        let scaleDown = SKAction.scale(to: 1.0, duration: duration / 2)
        scaleUp.timingMode = .easeInEaseOut
        scaleDown.timingMode = .easeInEaseOut
        run(SKAction.sequence([scaleUp, scaleDown]))
    }
    
    /// シェイクアニメーション
    func shake(intensity: CGFloat = 5, duration: TimeInterval = 0.3) {
        let originalPosition = position
        let numberOfShakes = Int(duration / 0.04)
        var actions: [SKAction] = []
        
        for _ in 0..<numberOfShakes {
            let dx = CGFloat.random(in: -intensity...intensity)
            let dy = CGFloat.random(in: -intensity...intensity)
            let move = SKAction.moveBy(x: dx, y: dy, duration: 0.02)
            let moveBack = SKAction.move(to: originalPosition, duration: 0.02)
            actions.append(contentsOf: [move, moveBack])
        }
        
        run(SKAction.sequence(actions))
    }
}

// MARK: - SKColor Extensions

extension SKColor {
    
    /// 16進数文字列からカラーを生成
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    /// 透明度を設定した新しいカラーを返す
    func withAlpha(_ alpha: CGFloat) -> SKColor {
        return self.withAlphaComponent(alpha)
    }
}

// MARK: - Array Extensions

extension Array {
    
    /// 安全なインデックスアクセス
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
    
    /// ランダムな要素を取得
    var randomElement: Element? {
        guard !isEmpty else { return nil }
        return self[Int.random(in: 0..<count)]
    }
}

// MARK: - Collection Extensions

extension Collection {
    
    /// コレクションが空でないかチェック
    var isNotEmpty: Bool {
        return !isEmpty
    }
}

// MARK: - Int Extensions

extension Int {
    
    /// クランプ（範囲制限）
    func clamped(to range: ClosedRange<Int>) -> Int {
        return min(max(self, range.lowerBound), range.upperBound)
    }
}

// MARK: - CGFloat Extensions

extension CGFloat {
    
    /// クランプ（範囲制限）
    func clamped(to range: ClosedRange<CGFloat>) -> CGFloat {
        return min(max(self, range.lowerBound), range.upperBound)
    }
    
    /// 度数からラジアンへの変換
    var degreesToRadians: CGFloat {
        return self * .pi / 180
    }
    
    /// ラジアンから度数への変換
    var radiansToDegrees: CGFloat {
        return self * 180 / .pi
    }
}

// MARK: - TimeInterval Extensions

extension TimeInterval {
    
    /// ミリ秒として取得
    var milliseconds: Int {
        return Int(self * 1000)
    }
    
    /// フォーマットされた時間文字列（MM:SS）
    var formattedTime: String {
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - SKAction Extensions

extension SKAction {
    
    /// 点滅アニメーション
    static func blink(duration: TimeInterval, count: Int) -> SKAction {
        let fadeOut = SKAction.fadeAlpha(to: 0.3, duration: duration / 2)
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: duration / 2)
        let blink = SKAction.sequence([fadeOut, fadeIn])
        return SKAction.repeat(blink, count: count)
    }
    
    /// 揺れるアニメーション
    static func wobble(intensity: CGFloat = 0.05, duration: TimeInterval = 0.1) -> SKAction {
        let rotateLeft = SKAction.rotate(byAngle: intensity, duration: duration / 4)
        let rotateRight = SKAction.rotate(byAngle: -intensity * 2, duration: duration / 2)
        let rotateBack = SKAction.rotate(byAngle: intensity, duration: duration / 4)
        return SKAction.sequence([rotateLeft, rotateRight, rotateBack])
    }
}
