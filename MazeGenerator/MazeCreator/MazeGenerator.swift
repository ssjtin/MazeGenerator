//
//  MazeGeneratorService.swift
//  MazeGenerator
//
//  Created by Hoang Luong on 12/6/19.
//  Copyright © 2019 Hoang Luong. All rights reserved.
//

import UIKit

struct Cell: Hashable {
    let row: Int
    let column: Int
}

enum Direction: Hashable {
    case Left
    case Right
    case Up
    case Down
}

class MazeGenerator {
    
    let seedValue: UInt64
    let rng: RandomNumberGenerator
    
    //Start Cell
    let initialCell = Cell(row: 1, column: 1)
    
    //Size of maze
    let numberOfColumns: Int
    let numberOfRows: Int
    
    //Current path
    var path: [Cell] = [Cell(row: 1, column: 1)]
    
    //Hold history of cells visited up to current point
    var visitedCellsHistory: Set<Cell> = [Cell(row: 1, column: 1)]
    
    //Reference for what each cell looks like/possible paths through cells
    var cellExitDictionary = [Cell: Set<Direction>]()
    var exitCell: Cell!
    
    init(numberOfRows: Int, numberOfColumns: Int, seedValue: UInt64) {
        self.numberOfRows = numberOfRows
        self.numberOfColumns = numberOfColumns
        self.seedValue = seedValue
        
        rng = RandomNumberGenerator(seedValue: seedValue)
    }
    
    func startGeneratingMaze() {
        findNextStep()
    }
    
    func findNextStep() {
        guard let currentCell = path.last else { return }
        if let availableCells = findAvailableCells(for: currentCell) {
            let nextCell = randomCell(from: availableCells)
            path.append(nextCell)
            visitedCellsHistory.insert(nextCell)
            //Update cell entry/exit directions
            updateCellData(fromCell: currentCell, toCell: nextCell)
            if visitedCellsHistory.count == (numberOfRows*numberOfColumns) {
                //reached exit cell
                exitCell = nextCell
                print("Maze generation completed, with \(visitedCellsHistory.count) cells and exit at row: \(exitCell.row), col: \(exitCell.column)")
            } else {
                findNextStep()
            }
        } else {
            //backtrack
            _ = path.popLast()
            if path.last == initialCell {
                //backtracked all the way to start
                print("MAZE FINISHED")
            } else {
                findNextStep()
            }
        }
        
    }
    
    func updateCellData(fromCell: Cell, toCell: Cell) {
        var originDirection: Direction = .Left
        var destinationDirection: Direction = .Right
        
        //configure exit and entry directions for origin and destination cell
        if      fromCell.column < toCell.column { originDirection = .Right; destinationDirection = .Left }
        else if fromCell.column > toCell.column { originDirection = .Left; destinationDirection = .Right }
        else if fromCell.row < toCell.row { originDirection = .Down; destinationDirection = .Up }
        else if fromCell.row > toCell.row { originDirection = .Up; destinationDirection = .Down }
        
        if var currentFromCellDirections = cellExitDictionary[fromCell] {
            //insert new exit direction to existing set and update for origin cell
            currentFromCellDirections.insert(originDirection)
            cellExitDictionary.updateValue(currentFromCellDirections, forKey: fromCell)
        } else {
            //insert first exit direction for origin cell
            let fromCellDirection: Set<Direction> = [originDirection]
            cellExitDictionary.updateValue(fromCellDirection, forKey: fromCell)
        }
        //insert first exit direction for destination cell (opposite to entrance direction)
        let toCellDirection: Set<Direction> = [destinationDirection]
        cellExitDictionary.updateValue(toCellDirection, forKey: toCell)

    }
    
    func randomCell(from cells: [Cell]) -> Cell {
        let random = rng.generateNextValue(lowest: 0, highest: cells.count-1)
        return cells[random]
    }
    
    func findAvailableCells(for cell: Cell) -> [Cell]? {
        //Get all surround cells in full grid
        let surroundingCells = calculateSurroundingCells(for: cell)
        
        //This shouldn't be possible
        if surroundingCells.count == 0 {
            return nil
        }
        
        let availableCells = filterUnvisitedCells(from: surroundingCells, comparedWith: visitedCellsHistory)
        //Return nil if no unvisited cells around current cell
        if availableCells.count == 0 {
            return nil
        }
        
        return availableCells
    }
    
    func filterUnvisitedCells(from cells: [Cell], comparedWith visitedCells: Set<Cell>) -> [Cell] {
        let cellSet = Set(cells)
        let visitedCellSet = Set(visitedCells)
        let unvisitedCells = cellSet.subtracting(visitedCellSet)
        return Array(unvisitedCells).sorted(by: { $0.row < $1.row }).sorted(by: { $0.column < $1.column })
    }
    
    //Returns all valid cells in grid surrounding specified CELL
    func calculateSurroundingCells(for cell: Cell) -> [Cell] {
        let currentRow = cell.row
        let currentColumn = cell.column
        
        var surroundingCells = [Cell]()
        
        if currentColumn > 1 {
            //cell to the left
            surroundingCells.append(Cell(row: currentRow, column: currentColumn-1))
        }
        
        if currentColumn < numberOfColumns {
            //cell to the right
            surroundingCells.append(Cell(row: currentRow, column: currentColumn+1))
        }
        
        if currentRow > 1 {
            //cell above
            surroundingCells.append(Cell(row: currentRow-1, column: currentColumn))
        }
        
        if currentRow < numberOfRows {
            //cell below
            surroundingCells.append(Cell(row: currentRow+1, column: currentColumn))
        }
        
        return surroundingCells
    }
 
}
