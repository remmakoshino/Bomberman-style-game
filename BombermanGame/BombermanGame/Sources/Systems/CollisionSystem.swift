//
//  CollisionSystem.swift
//  BombermanGame
//
//  衝突判定システム
//

import Foundation
import SpriteKit

/// 衝突システム - 物理衝突とゲームロジックの衝突判定を管理
final class CollisionSystem {
    
    // MARK: - Properties
    
    /// グリッドシステムへの参照
    weak var gridSystem: GridSystem?
    
    // MARK: - Initialization
    
    init(gridSystem: GridSystem) {
        self.gridSystem = gridSystem
    }
    
    // MARK: - Collision Detection
    
    /// プレイヤーと敵の衝突判定
    func checkPlayerEnemyCollision(player: Player, enemies: [Enemy]) -> Enemy? {
        guard !player.isDead && !player.isInvincible else { return nil }
        
        let playerPos = player.gridPosition
        
        for enemy in enemies where !enemy.isDead {
            if enemy.gridPosition == playerPos {
                return enemy
            }
            
            // より精密な衝突判定（オプション）
            let distance = player.position.distance(to: enemy.position)
            let collisionDistance = (player.size.width + enemy.size.width) / 2 * 0.7
            
            if distance < collisionDistance {
                return enemy
            }
        }
        
        return nil
    }
    
    /// プレイヤーとアイテムの衝突判定
    func checkPlayerItemCollision(player: Player, items: [Item]) -> Item? {
        guard !player.isDead else { return nil }
        
        let playerPos = player.gridPosition
        
        for item in items where !item.isCollected {
            if item.gridPos == playerPos {
                return item
            }
        }
        
        return nil
    }
    
    /// プレイヤーと爆風の衝突判定
    func checkPlayerExplosionCollision(player: Player, explosions: [Explosion]) -> Bool {
        guard !player.isDead && !player.isInvincible else { return false }
        
        for explosion in explosions {
            if explosion.isAffecting(position: player.gridPosition) {
                return true
            }
        }
        
        return false
    }
    
    /// 敵と爆風の衝突判定
    func checkEnemyExplosionCollisions(enemies: [Enemy], explosions: [Explosion]) -> [Enemy] {
        var affectedEnemies: [Enemy] = []
        
        for enemy in enemies where !enemy.isDead {
            for explosion in explosions {
                if explosion.isAffecting(position: enemy.gridPosition) {
                    affectedEnemies.append(enemy)
                    break
                }
            }
        }
        
        return affectedEnemies
    }
    
    /// 爆弾と爆風の衝突判定（連鎖爆発用）
    func checkBombExplosionCollisions(bombs: [Bomb], explosions: [Explosion]) -> [Bomb] {
        var affectedBombs: [Bomb] = []
        
        for bomb in bombs where !bomb.hasExploded {
            for explosion in explosions {
                if explosion.isAffecting(position: bomb.gridPosition) {
                    affectedBombs.append(bomb)
                    break
                }
            }
        }
        
        return affectedBombs
    }
    
    // MARK: - Movement Collision
    
    /// 移動可能かチェック
    func canMove(from position: GridPosition,
                 to direction: Direction,
                 canPassWalls: Bool = false,
                 canPassBombs: Bool = false) -> Bool {
        guard let gridSystem = gridSystem else { return false }
        
        let targetPos = position.adjacent(in: direction)
        return gridSystem.isWalkable(at: targetPos, canPassWalls: canPassWalls, canPassBombs: canPassBombs)
    }
    
    /// 移動後の位置を取得（壁にめり込まないよう調整）
    func getAdjustedPosition(from currentPos: CGPoint,
                             to targetPos: CGPoint,
                             canPassWalls: Bool = false,
                             canPassBombs: Bool = false) -> CGPoint {
        guard let gridSystem = gridSystem else { return targetPos }
        
        let targetGridPos = GridPosition.fromPoint(targetPos)
        
        if gridSystem.isWalkable(at: targetGridPos, canPassWalls: canPassWalls, canPassBombs: canPassBombs) {
            return targetPos
        }
        
        // 壁にぶつかった場合、グリッドの中心に補正
        let currentGridPos = GridPosition.fromPoint(currentPos)
        return gridSystem.gridToScene(currentGridPos)
    }
    
    // MARK: - Ray Casting
    
    /// 指定方向に遮蔽物なくレイを投射
    func castRay(from position: GridPosition,
                 direction: Direction,
                 maxDistance: Int) -> [GridPosition] {
        guard let gridSystem = gridSystem else { return [] }
        
        var positions: [GridPosition] = []
        
        for distance in 1...maxDistance {
            let offset = direction.gridOffset
            let targetPos = GridPosition(
                x: position.x + offset.x * distance,
                y: position.y + offset.y * distance
            )
            
            guard gridSystem.isValidPosition(targetPos) else { break }
            
            let tile = gridSystem.getTile(at: targetPos)
            
            if tile == .hardBlock {
                break
            }
            
            positions.append(targetPos)
            
            if tile == .softBlock {
                break
            }
        }
        
        return positions
    }
    
    // MARK: - Area Check
    
    /// 指定範囲内のエンティティを取得
    func getEntitiesInRange(center: GridPosition, range: Int) -> [GridPosition] {
        var positions: [GridPosition] = []
        
        for x in (center.x - range)...(center.x + range) {
            for y in (center.y - range)...(center.y + range) {
                let pos = GridPosition(x: x, y: y)
                if pos.isValid() {
                    positions.append(pos)
                }
            }
        }
        
        return positions
    }
    
    /// 指定位置が安全かチェック（爆弾の爆発範囲外か）
    func isSafePosition(_ position: GridPosition, bombs: [Bomb]) -> Bool {
        guard let gridSystem = gridSystem else { return true }
        
        for bomb in bombs where !bomb.hasExploded {
            let explosionRange = gridSystem.calculateExplosionRange(
                from: bomb.gridPosition,
                power: bomb.firePower
            )
            
            if explosionRange.contains(position) {
                return false
            }
        }
        
        return true
    }
}

// MARK: - Collision Result

/// 衝突結果
struct CollisionResult {
    let type: CollisionType
    let position: GridPosition
    let entities: [Any]
}

/// 衝突の種類
enum CollisionType {
    case playerEnemy
    case playerExplosion
    case playerItem
    case enemyExplosion
    case bombExplosion
    case blockExplosion
}
