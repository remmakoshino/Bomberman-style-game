//
//  GridSystemTests.swift
//  BombermanGameTests
//
//  グリッドシステムのテスト
//

import XCTest
@testable import BombermanGame

final class GridSystemTests: XCTestCase {
    
    var gridSystem: GridSystem!
    
    override func setUp() {
        super.setUp()
        gridSystem = GridSystem()
    }
    
    override func tearDown() {
        gridSystem = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testGridSystemInitialization() {
        XCTAssertEqual(gridSystem.columns, Constants.gridColumns)
        XCTAssertEqual(gridSystem.rows, Constants.gridRows)
        XCTAssertEqual(gridSystem.tileSize, Constants.tileSize)
    }
    
    func testCustomGridSize() {
        let customGrid = GridSystem(columns: 15, rows: 13, tileSize: 32)
        
        XCTAssertEqual(customGrid.columns, 15)
        XCTAssertEqual(customGrid.rows, 13)
        XCTAssertEqual(customGrid.tileSize, 32)
    }
    
    // MARK: - Position Validation Tests
    
    func testValidPosition() {
        XCTAssertTrue(gridSystem.isValidPosition(GridPosition(x: 0, y: 0)))
        XCTAssertTrue(gridSystem.isValidPosition(GridPosition(x: 5, y: 5)))
        XCTAssertTrue(gridSystem.isValidPosition(GridPosition(x: gridSystem.columns - 1, y: gridSystem.rows - 1)))
    }
    
    func testInvalidPosition() {
        XCTAssertFalse(gridSystem.isValidPosition(GridPosition(x: -1, y: 0)))
        XCTAssertFalse(gridSystem.isValidPosition(GridPosition(x: 0, y: -1)))
        XCTAssertFalse(gridSystem.isValidPosition(GridPosition(x: gridSystem.columns, y: 0)))
        XCTAssertFalse(gridSystem.isValidPosition(GridPosition(x: 0, y: gridSystem.rows)))
    }
    
    // MARK: - Tile Access Tests
    
    func testSetAndGetTile() {
        let position = GridPosition(x: 5, y: 5)
        
        gridSystem.setTile(.hardBlock, at: position)
        XCTAssertEqual(gridSystem.getTile(at: position), .hardBlock)
        
        gridSystem.setTile(.softBlock, at: position)
        XCTAssertEqual(gridSystem.getTile(at: position), .softBlock)
        
        gridSystem.setTile(.empty, at: position)
        XCTAssertEqual(gridSystem.getTile(at: position), .empty)
    }
    
    func testGetTileAtInvalidPosition() {
        let invalidPosition = GridPosition(x: -1, y: -1)
        XCTAssertNil(gridSystem.getTile(at: invalidPosition))
    }
    
    // MARK: - Walkability Tests
    
    func testWalkableOnEmptyTile() {
        let position = GridPosition(x: 1, y: 1)
        gridSystem.setTile(.empty, at: position)
        
        XCTAssertTrue(gridSystem.isWalkable(at: position))
    }
    
    func testNotWalkableOnHardBlock() {
        let position = GridPosition(x: 1, y: 1)
        gridSystem.setTile(.hardBlock, at: position)
        
        XCTAssertFalse(gridSystem.isWalkable(at: position))
    }
    
    func testNotWalkableOnSoftBlock() {
        let position = GridPosition(x: 1, y: 1)
        gridSystem.setTile(.softBlock, at: position)
        
        XCTAssertFalse(gridSystem.isWalkable(at: position))
    }
    
    func testWalkableOnSoftBlockWithWallPass() {
        let position = GridPosition(x: 1, y: 1)
        gridSystem.setTile(.softBlock, at: position)
        
        XCTAssertTrue(gridSystem.isWalkable(at: position, canPassWalls: true))
    }
    
    func testWalkableOnItemTile() {
        let position = GridPosition(x: 1, y: 1)
        gridSystem.setTile(.item, at: position)
        
        XCTAssertTrue(gridSystem.isWalkable(at: position))
    }
    
    // MARK: - Map Generation Tests
    
    func testGenerateStandardMap() {
        gridSystem.generateStandardMap()
        
        // 外周はハードブロック
        XCTAssertEqual(gridSystem.getTile(at: GridPosition(x: 0, y: 0)), .hardBlock)
        XCTAssertEqual(gridSystem.getTile(at: GridPosition(x: gridSystem.columns - 1, y: 0)), .hardBlock)
        XCTAssertEqual(gridSystem.getTile(at: GridPosition(x: 0, y: gridSystem.rows - 1)), .hardBlock)
        
        // 偶数座標にハードブロック（内部格子）
        XCTAssertEqual(gridSystem.getTile(at: GridPosition(x: 2, y: 2)), .hardBlock)
        XCTAssertEqual(gridSystem.getTile(at: GridPosition(x: 4, y: 4)), .hardBlock)
        
        // プレイヤー開始位置は空
        XCTAssertEqual(gridSystem.getTile(at: GridPosition(x: 1, y: 1)), .empty)
    }
    
    func testClearGrid() {
        gridSystem.generateStandardMap()
        gridSystem.clearGrid()
        
        // すべてのタイルが空
        for x in 0..<gridSystem.columns {
            for y in 0..<gridSystem.rows {
                XCTAssertEqual(gridSystem.getTile(at: GridPosition(x: x, y: y)), .empty)
            }
        }
    }
    
    // MARK: - Coordinate Conversion Tests
    
    func testGridToScene() {
        let gridPos = GridPosition(x: 2, y: 3)
        let scenePos = gridSystem.gridToScene(gridPos)
        
        let expectedX = CGFloat(2) * Constants.tileSize + Constants.tileSize / 2
        let expectedY = CGFloat(3) * Constants.tileSize + Constants.tileSize / 2
        
        XCTAssertEqual(scenePos.x, expectedX, accuracy: 0.001)
        XCTAssertEqual(scenePos.y, expectedY, accuracy: 0.001)
    }
    
    func testSceneToGrid() {
        let scenePos = CGPoint(x: 100, y: 150)
        let gridPos = gridSystem.sceneToGrid(scenePos)
        
        let expectedX = Int(100 / Constants.tileSize)
        let expectedY = Int(150 / Constants.tileSize)
        
        XCTAssertEqual(gridPos.x, expectedX)
        XCTAssertEqual(gridPos.y, expectedY)
    }
    
    func testSnapToGrid() {
        let offset = CGPoint(x: 10, y: 15)
        let basePos = gridSystem.gridToScene(GridPosition(x: 3, y: 4))
        let offsetPos = CGPoint(x: basePos.x + offset.x, y: basePos.y + offset.y)
        
        let snapped = gridSystem.snapToGrid(offsetPos)
        
        XCTAssertEqual(snapped.x, basePos.x, accuracy: 0.001)
        XCTAssertEqual(snapped.y, basePos.y, accuracy: 0.001)
    }
    
    // MARK: - Explosion Range Tests
    
    func testCalculateExplosionRangeBasic() {
        gridSystem.clearGrid()
        
        let center = GridPosition(x: 5, y: 5)
        let power = 2
        
        let range = gridSystem.calculateExplosionRange(from: center, power: power)
        
        // 中心は含まれる
        XCTAssertTrue(range.contains(center))
        
        // 4方向に広がる
        XCTAssertTrue(range.contains(GridPosition(x: 5, y: 6)))
        XCTAssertTrue(range.contains(GridPosition(x: 5, y: 7)))
        XCTAssertTrue(range.contains(GridPosition(x: 5, y: 4)))
        XCTAssertTrue(range.contains(GridPosition(x: 5, y: 3)))
        XCTAssertTrue(range.contains(GridPosition(x: 6, y: 5)))
        XCTAssertTrue(range.contains(GridPosition(x: 7, y: 5)))
        XCTAssertTrue(range.contains(GridPosition(x: 4, y: 5)))
        XCTAssertTrue(range.contains(GridPosition(x: 3, y: 5)))
    }
    
    func testCalculateExplosionRangeBlockedByHardBlock() {
        gridSystem.clearGrid()
        gridSystem.setTile(.hardBlock, at: GridPosition(x: 5, y: 7))
        
        let center = GridPosition(x: 5, y: 5)
        let power = 3
        
        let range = gridSystem.calculateExplosionRange(from: center, power: power)
        
        // ハードブロックの位置は含まれない
        XCTAssertFalse(range.contains(GridPosition(x: 5, y: 7)))
        // ハードブロックの先も含まれない
        XCTAssertFalse(range.contains(GridPosition(x: 5, y: 8)))
    }
    
    func testCalculateExplosionRangeStopsAtSoftBlock() {
        gridSystem.clearGrid()
        gridSystem.setTile(.softBlock, at: GridPosition(x: 5, y: 7))
        
        let center = GridPosition(x: 5, y: 5)
        let power = 3
        
        let range = gridSystem.calculateExplosionRange(from: center, power: power)
        
        // ソフトブロックの位置は含まれる（破壊対象）
        XCTAssertTrue(range.contains(GridPosition(x: 5, y: 7)))
        // ソフトブロックの先は含まれない
        XCTAssertFalse(range.contains(GridPosition(x: 5, y: 8)))
    }
    
    // MARK: - Walkable Neighbors Tests
    
    func testGetWalkableNeighbors() {
        gridSystem.clearGrid()
        
        let center = GridPosition(x: 5, y: 5)
        let neighbors = gridSystem.getWalkableNeighbors(of: center)
        
        // すべて空なので4方向すべて
        XCTAssertEqual(neighbors.count, 4)
        XCTAssertTrue(neighbors.contains(GridPosition(x: 5, y: 6)))
        XCTAssertTrue(neighbors.contains(GridPosition(x: 5, y: 4)))
        XCTAssertTrue(neighbors.contains(GridPosition(x: 6, y: 5)))
        XCTAssertTrue(neighbors.contains(GridPosition(x: 4, y: 5)))
    }
    
    func testGetWalkableNeighborsWithBlocks() {
        gridSystem.clearGrid()
        gridSystem.setTile(.hardBlock, at: GridPosition(x: 5, y: 6))
        gridSystem.setTile(.softBlock, at: GridPosition(x: 6, y: 5))
        
        let center = GridPosition(x: 5, y: 5)
        let neighbors = gridSystem.getWalkableNeighbors(of: center)
        
        // 2方向のみ通行可能
        XCTAssertEqual(neighbors.count, 2)
        XCTAssertTrue(neighbors.contains(GridPosition(x: 5, y: 4)))
        XCTAssertTrue(neighbors.contains(GridPosition(x: 4, y: 5)))
    }
}

// MARK: - GridPosition Tests

extension GridSystemTests {
    
    func testGridPositionEquality() {
        let pos1 = GridPosition(x: 3, y: 5)
        let pos2 = GridPosition(x: 3, y: 5)
        let pos3 = GridPosition(x: 3, y: 6)
        
        XCTAssertEqual(pos1, pos2)
        XCTAssertNotEqual(pos1, pos3)
    }
    
    func testGridPositionToPoint() {
        let pos = GridPosition(x: 2, y: 3)
        let point = pos.toPoint()
        
        let expectedX = CGFloat(2) * Constants.tileSize + Constants.tileSize / 2
        let expectedY = CGFloat(3) * Constants.tileSize + Constants.tileSize / 2
        
        XCTAssertEqual(point.x, expectedX, accuracy: 0.001)
        XCTAssertEqual(point.y, expectedY, accuracy: 0.001)
    }
    
    func testGridPositionFromPoint() {
        let point = CGPoint(x: 100, y: 150)
        let pos = GridPosition.fromPoint(point)
        
        XCTAssertEqual(pos.x, Int(100 / Constants.tileSize))
        XCTAssertEqual(pos.y, Int(150 / Constants.tileSize))
    }
    
    func testGridPositionAdjacent() {
        let pos = GridPosition(x: 5, y: 5)
        
        XCTAssertEqual(pos.adjacent(in: .up), GridPosition(x: 5, y: 6))
        XCTAssertEqual(pos.adjacent(in: .down), GridPosition(x: 5, y: 4))
        XCTAssertEqual(pos.adjacent(in: .left), GridPosition(x: 4, y: 5))
        XCTAssertEqual(pos.adjacent(in: .right), GridPosition(x: 6, y: 5))
    }
    
    func testGridPositionIsValid() {
        XCTAssertTrue(GridPosition(x: 0, y: 0).isValid())
        XCTAssertTrue(GridPosition(x: 5, y: 5).isValid())
        XCTAssertFalse(GridPosition(x: -1, y: 0).isValid())
        XCTAssertFalse(GridPosition(x: Constants.gridColumns, y: 0).isValid())
    }
}

// MARK: - Direction Tests

extension GridSystemTests {
    
    func testDirectionVector() {
        XCTAssertEqual(Direction.up.vector.dx, 0)
        XCTAssertEqual(Direction.up.vector.dy, 1)
        
        XCTAssertEqual(Direction.down.vector.dx, 0)
        XCTAssertEqual(Direction.down.vector.dy, -1)
        
        XCTAssertEqual(Direction.left.vector.dx, -1)
        XCTAssertEqual(Direction.left.vector.dy, 0)
        
        XCTAssertEqual(Direction.right.vector.dx, 1)
        XCTAssertEqual(Direction.right.vector.dy, 0)
    }
    
    func testDirectionOpposite() {
        XCTAssertEqual(Direction.up.opposite, .down)
        XCTAssertEqual(Direction.down.opposite, .up)
        XCTAssertEqual(Direction.left.opposite, .right)
        XCTAssertEqual(Direction.right.opposite, .left)
    }
}
