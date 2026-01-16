//
//  GridSystem.swift
//  BombermanGame
//
//  グリッドベースのマップ管理システム
//

import Foundation
import SpriteKit

/// グリッドシステム - マップの管理と座標変換を担当
final class GridSystem {
    
    // MARK: - Properties
    
    /// グリッドの列数
    let columns: Int
    
    /// グリッドの行数
    let rows: Int
    
    /// タイルサイズ
    let tileSize: CGFloat
    
    /// グリッドデータ（各マスの状態）
    private var grid: [[TileType]]
    
    /// エンティティのマップ（座標 -> エンティティ）
    private var entityMap: [GridPosition: [GridEntity]] = [:]
    
    // MARK: - Initialization
    
    init(columns: Int = Constants.gridColumns,
         rows: Int = Constants.gridRows,
         tileSize: CGFloat = Constants.tileSize) {
        self.columns = columns
        self.rows = rows
        self.tileSize = tileSize
        self.grid = Array(repeating: Array(repeating: .empty, count: rows), count: columns)
    }
    
    // MARK: - Grid Access
    
    /// 指定位置のタイルタイプを取得
    func getTile(at position: GridPosition) -> TileType? {
        guard isValidPosition(position) else { return nil }
        return grid[position.x][position.y]
    }
    
    /// 指定位置にタイルタイプを設定
    func setTile(_ type: TileType, at position: GridPosition) {
        guard isValidPosition(position) else { return }
        grid[position.x][position.y] = type
    }
    
    /// 位置が有効かチェック
    func isValidPosition(_ position: GridPosition) -> Bool {
        return position.x >= 0 && position.x < columns &&
               position.y >= 0 && position.y < rows
    }
    
    /// 指定位置が通行可能かチェック
    func isWalkable(at position: GridPosition, canPassWalls: Bool = false, canPassBombs: Bool = false) -> Bool {
        guard isValidPosition(position) else { return false }
        
        let tile = grid[position.x][position.y]
        
        switch tile {
        case .empty:
            // 爆弾チェック
            if !canPassBombs && hasBomb(at: position) {
                return false
            }
            return true
        case .softBlock:
            return canPassWalls
        case .hardBlock:
            return false
        case .item:
            return true
        }
    }
    
    /// 指定位置に爆弾があるかチェック
    func hasBomb(at position: GridPosition) -> Bool {
        guard let entities = entityMap[position] else { return false }
        return entities.contains { $0.type == .bomb }
    }
    
    /// 指定位置のエンティティを取得
    func getEntities(at position: GridPosition) -> [GridEntity] {
        return entityMap[position] ?? []
    }
    
    // MARK: - Entity Management
    
    /// エンティティを登録
    func registerEntity(_ entity: GridEntity, at position: GridPosition) {
        if entityMap[position] == nil {
            entityMap[position] = []
        }
        entityMap[position]?.append(entity)
    }
    
    /// エンティティを解除
    func unregisterEntity(_ entity: GridEntity, at position: GridPosition) {
        entityMap[position]?.removeAll { $0.id == entity.id }
        if entityMap[position]?.isEmpty == true {
            entityMap[position] = nil
        }
    }
    
    /// エンティティの位置を更新
    func moveEntity(_ entity: GridEntity, from oldPosition: GridPosition, to newPosition: GridPosition) {
        unregisterEntity(entity, at: oldPosition)
        registerEntity(entity, at: newPosition)
    }
    
    // MARK: - Coordinate Conversion
    
    /// グリッド座標からシーン座標へ変換
    func gridToScene(_ gridPos: GridPosition) -> CGPoint {
        return CGPoint(
            x: CGFloat(gridPos.x) * tileSize + tileSize / 2,
            y: CGFloat(gridPos.y) * tileSize + tileSize / 2
        )
    }
    
    /// シーン座標からグリッド座標へ変換
    func sceneToGrid(_ scenePos: CGPoint) -> GridPosition {
        return GridPosition(
            x: Int(scenePos.x / tileSize),
            y: Int(scenePos.y / tileSize)
        )
    }
    
    /// グリッドの中心に揃えた座標を返す
    func snapToGrid(_ scenePos: CGPoint) -> CGPoint {
        let gridPos = sceneToGrid(scenePos)
        return gridToScene(gridPos)
    }
    
    // MARK: - Map Generation
    
    /// 標準的なボンバーマンマップを生成
    func generateStandardMap(softBlockDensity: Double = 0.6) {
        // グリッドをクリア
        clearGrid()
        
        // 外周にハードブロックを配置
        for x in 0..<columns {
            setTile(.hardBlock, at: GridPosition(x: x, y: 0))
            setTile(.hardBlock, at: GridPosition(x: x, y: rows - 1))
        }
        for y in 0..<rows {
            setTile(.hardBlock, at: GridPosition(x: 0, y: y))
            setTile(.hardBlock, at: GridPosition(x: columns - 1, y: y))
        }
        
        // 内部に格子状のハードブロックを配置（偶数座標）
        for x in stride(from: 2, to: columns - 1, by: 2) {
            for y in stride(from: 2, to: rows - 1, by: 2) {
                setTile(.hardBlock, at: GridPosition(x: x, y: y))
            }
        }
        
        // ソフトブロックをランダムに配置
        placeSoftBlocks(density: softBlockDensity)
    }
    
    /// ソフトブロックの配置
    private func placeSoftBlocks(density: Double) {
        // プレイヤー開始位置周辺は空けておく
        let playerSafeZones = getPlayerSafeZones()
        
        for x in 1..<(columns - 1) {
            for y in 1..<(rows - 1) {
                let pos = GridPosition(x: x, y: y)
                
                // すでにハードブロックがある場合はスキップ
                if getTile(at: pos) == .hardBlock {
                    continue
                }
                
                // プレイヤー開始位置周辺はスキップ
                if playerSafeZones.contains(pos) {
                    continue
                }
                
                // 確率でソフトブロックを配置
                if Double.random(in: 0...1) < density {
                    setTile(.softBlock, at: pos)
                }
            }
        }
    }
    
    /// プレイヤー開始位置周辺の安全地帯を取得
    private func getPlayerSafeZones() -> Set<GridPosition> {
        var safeZones = Set<GridPosition>()
        
        // 四隅のプレイヤー開始位置
        let startPositions = [
            GridPosition(x: 1, y: 1),                           // 左下
            GridPosition(x: columns - 2, y: 1),                 // 右下
            GridPosition(x: 1, y: rows - 2),                    // 左上
            GridPosition(x: columns - 2, y: rows - 2)           // 右上
        ]
        
        for start in startPositions {
            safeZones.insert(start)
            // 隣接する2マスも安全地帯に
            safeZones.insert(GridPosition(x: start.x + 1, y: start.y))
            safeZones.insert(GridPosition(x: start.x, y: start.y + 1))
            safeZones.insert(GridPosition(x: start.x - 1, y: start.y))
            safeZones.insert(GridPosition(x: start.x, y: start.y - 1))
        }
        
        return safeZones
    }
    
    /// グリッドをクリア
    func clearGrid() {
        grid = Array(repeating: Array(repeating: .empty, count: rows), count: columns)
        entityMap.removeAll()
    }
    
    // MARK: - Pathfinding Helper
    
    /// 指定位置の隣接する通行可能なマスを取得
    func getWalkableNeighbors(of position: GridPosition, canPassWalls: Bool = false, canPassBombs: Bool = false) -> [GridPosition] {
        var neighbors: [GridPosition] = []
        
        for direction in Direction.allCases {
            let neighborPos = position.adjacent(in: direction)
            if isWalkable(at: neighborPos, canPassWalls: canPassWalls, canPassBombs: canPassBombs) {
                neighbors.append(neighborPos)
            }
        }
        
        return neighbors
    }
    
    // MARK: - Explosion Path
    
    /// 爆発の影響範囲を計算
    func calculateExplosionRange(from position: GridPosition, power: Int) -> [GridPosition] {
        var affectedPositions: [GridPosition] = [position]
        
        for direction in Direction.allCases {
            for distance in 1...power {
                let targetPos = GridPosition(
                    x: position.x + direction.gridOffset.x * distance,
                    y: position.y + direction.gridOffset.y * distance
                )
                
                guard isValidPosition(targetPos) else { break }
                
                let tile = getTile(at: targetPos)
                
                switch tile {
                case .hardBlock:
                    // ハードブロックで止まる（影響なし）
                    break
                case .softBlock:
                    // ソフトブロックで止まる（破壊対象）
                    affectedPositions.append(targetPos)
                    break
                case .empty, .item, .none:
                    affectedPositions.append(targetPos)
                    continue
                }
                
                // ブロックで止まった場合はこの方向の探索終了
                if tile == .hardBlock || tile == .softBlock {
                    break
                }
            }
        }
        
        return affectedPositions
    }
    
    // MARK: - Debug
    
    /// グリッドの状態を文字列で表示（デバッグ用）
    func debugPrint() {
        print("Grid (\(columns)x\(rows)):")
        for y in (0..<rows).reversed() {
            var line = ""
            for x in 0..<columns {
                let tile = grid[x][y]
                switch tile {
                case .empty: line += "."
                case .hardBlock: line += "#"
                case .softBlock: line += "□"
                case .item: line += "?"
                }
            }
            print(line)
        }
    }
}

// MARK: - Tile Type

/// マスの種類
enum TileType {
    case empty      // 空白（通行可能）
    case hardBlock  // ハードブロック（破壊不可）
    case softBlock  // ソフトブロック（破壊可能）
    case item       // アイテム
}

// MARK: - Grid Entity

/// グリッド上のエンティティを表す構造体
struct GridEntity: Identifiable {
    let id: UUID
    let type: EntityType
    weak var node: SKNode?
    
    init(id: UUID = UUID(), type: EntityType, node: SKNode? = nil) {
        self.id = id
        self.type = type
        self.node = node
    }
}

/// エンティティの種類
enum EntityType {
    case player
    case enemy
    case bomb
    case item
    case explosion
}
