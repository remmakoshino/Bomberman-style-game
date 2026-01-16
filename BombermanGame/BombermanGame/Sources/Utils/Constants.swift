//
//  Constants.swift
//  BombermanGame
//
//  ゲーム全体で使用する定数を定義
//

import Foundation
import CoreGraphics

/// ゲーム全体で使用する定数
enum Constants {
    
    // MARK: - Grid Settings
    
    /// グリッドの列数（横方向）
    static let gridColumns: Int = 13
    
    /// グリッドの行数（縦方向）
    static let gridRows: Int = 11
    
    /// 1マスのサイズ（ポイント）
    static let tileSize: CGFloat = 48.0
    
    // MARK: - Player Settings
    
    /// プレイヤーの初期移動速度（マス/秒）
    static let playerBaseSpeed: CGFloat = 3.0
    
    /// プレイヤーの最大移動速度
    static let playerMaxSpeed: CGFloat = 6.0
    
    /// スピードアップ1回あたりの増加量
    static let speedUpIncrement: CGFloat = 0.5
    
    /// プレイヤーの初期爆弾数
    static let playerInitialBombCount: Int = 1
    
    /// プレイヤーの最大爆弾数
    static let playerMaxBombCount: Int = 10
    
    /// プレイヤーの初期火力（爆風範囲）
    static let playerInitialFirePower: Int = 1
    
    /// プレイヤーの最大火力
    static let playerMaxFirePower: Int = 5
    
    /// プレイヤーの初期残機
    static let playerInitialLives: Int = 3
    
    // MARK: - Bomb Settings
    
    /// 爆弾の爆発までの時間（秒）
    static let bombFuseTime: TimeInterval = 3.0
    
    /// 爆風の表示時間（秒）
    static let explosionDuration: TimeInterval = 0.5
    
    /// 連鎖爆発の遅延時間（秒）
    static let chainExplosionDelay: TimeInterval = 0.1
    
    // MARK: - Item Settings
    
    /// アイテムのドロップ確率（0.0-1.0）
    static let itemDropRate: Double = 0.3
    
    /// 無敵時間（秒）
    static let invincibilityDuration: TimeInterval = 10.0
    
    // MARK: - Enemy Settings
    
    /// 敵の基本移動速度
    static let enemyBaseSpeed: CGFloat = 1.5
    
    /// 敵の方向転換間隔（秒）
    static let enemyDirectionChangeInterval: TimeInterval = 2.0
    
    // MARK: - Animation Settings
    
    /// プレイヤーアニメーションのフレームレート
    static let playerAnimationFPS: TimeInterval = 0.1
    
    /// 爆弾の点滅間隔
    static let bombBlinkInterval: TimeInterval = 0.2
    
    // MARK: - Z Positions (レイヤー順序)
    
    /// 背景のZ位置
    static let zPositionBackground: CGFloat = 0
    
    /// ブロックのZ位置
    static let zPositionBlock: CGFloat = 10
    
    /// アイテムのZ位置
    static let zPositionItem: CGFloat = 20
    
    /// 爆弾のZ位置
    static let zPositionBomb: CGFloat = 30
    
    /// プレイヤー・敵のZ位置
    static let zPositionCharacter: CGFloat = 40
    
    /// 爆風のZ位置
    static let zPositionExplosion: CGFloat = 50
    
    /// UIのZ位置
    static let zPositionUI: CGFloat = 100
    
    // MARK: - Physics Categories (衝突判定用ビットマスク)
    
    /// なし
    static let categoryNone: UInt32 = 0
    
    /// プレイヤー
    static let categoryPlayer: UInt32 = 0x1 << 0
    
    /// 敵
    static let categoryEnemy: UInt32 = 0x1 << 1
    
    /// 爆弾
    static let categoryBomb: UInt32 = 0x1 << 2
    
    /// 爆風
    static let categoryExplosion: UInt32 = 0x1 << 3
    
    /// ハードブロック
    static let categoryHardBlock: UInt32 = 0x1 << 4
    
    /// ソフトブロック
    static let categorySoftBlock: UInt32 = 0x1 << 5
    
    /// アイテム
    static let categoryItem: UInt32 = 0x1 << 6
    
    // MARK: - Colors
    
    /// 背景色
    static let backgroundColor = "#2C3E50"
    
    /// ハードブロック色
    static let hardBlockColor = "#7F8C8D"
    
    /// ソフトブロック色
    static let softBlockColor = "#E67E22"
    
    /// プレイヤー色
    static let playerColor = "#3498DB"
    
    /// 敵の色
    static let enemyColor = "#E74C3C"
    
    /// 爆弾の色
    static let bombColor = "#2C3E50"
    
    /// 爆風の色
    static let explosionColor = "#F39C12"
}

// MARK: - Direction Enum

/// 移動方向を表す列挙型
enum Direction: CaseIterable {
    case up
    case down
    case left
    case right
    
    /// 方向に対応するベクトル
    var vector: CGVector {
        switch self {
        case .up:    return CGVector(dx: 0, dy: 1)
        case .down:  return CGVector(dx: 0, dy: -1)
        case .left:  return CGVector(dx: -1, dy: 0)
        case .right: return CGVector(dx: 1, dy: 0)
        }
    }
    
    /// 反対方向
    var opposite: Direction {
        switch self {
        case .up:    return .down
        case .down:  return .up
        case .left:  return .right
        case .right: return .left
        }
    }
    
    /// グリッド座標のオフセット
    var gridOffset: GridPosition {
        switch self {
        case .up:    return GridPosition(x: 0, y: 1)
        case .down:  return GridPosition(x: 0, y: -1)
        case .left:  return GridPosition(x: -1, y: 0)
        case .right: return GridPosition(x: 1, y: 0)
        }
    }
}

// MARK: - Grid Position

/// グリッド上の位置を表す構造体
struct GridPosition: Equatable, Hashable {
    var x: Int
    var y: Int
    
    /// CGPointへの変換
    func toPoint() -> CGPoint {
        return CGPoint(
            x: CGFloat(x) * Constants.tileSize + Constants.tileSize / 2,
            y: CGFloat(y) * Constants.tileSize + Constants.tileSize / 2
        )
    }
    
    /// CGPointからの変換
    static func fromPoint(_ point: CGPoint) -> GridPosition {
        return GridPosition(
            x: Int(point.x / Constants.tileSize),
            y: Int(point.y / Constants.tileSize)
        )
    }
    
    /// 隣接位置の取得
    func adjacent(in direction: Direction) -> GridPosition {
        let offset = direction.gridOffset
        return GridPosition(x: x + offset.x, y: y + offset.y)
    }
    
    /// グリッド範囲内かチェック
    func isValid() -> Bool {
        return x >= 0 && x < Constants.gridColumns &&
               y >= 0 && y < Constants.gridRows
    }
}
