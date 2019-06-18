//
//  MazeGrid.swift
//  MazeGenerator
//
//  Created by Hoang Luong on 12/6/19.
//  Copyright © 2019 Hoang Luong. All rights reserved.
//

import UIKit

class MazeGrid: UIView {
    
    let cellExitDictionary: [Cell: Set<Direction>]
    var cells = [MazeCell]()
    var currentCell: MazeCell?
    var exitCell = Cell(row: 1, column: 1)
    
    init(rows: Int, columns: Int, cellExitDictionary: [Cell: Set<Direction>], frame: CGRect) {
        self.cellExitDictionary = cellExitDictionary
        super.init(frame: frame)
        
        configureGrid(rows, by: columns)
    }
    
    func configureGrid(_ rows: Int, by columns: Int) {
        
        let containerStackView = UIStackView(frame: self.frame)
        containerStackView.axis = .vertical
        containerStackView.distribution = .fillEqually
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(containerStackView)
        containerStackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        containerStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        containerStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        containerStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        for row in 1...rows {
            //create row stackview
            let stackView: UIStackView = {
                let sv = UIStackView()
                sv.axis = .horizontal
                sv.distribution = .fillEqually
                sv.translatesAutoresizingMaskIntoConstraints = false
                return sv
            }()
            
            containerStackView.addArrangedSubview(stackView)
            
            for column in 1...columns {
                guard let exitDirections = cellExitDictionary[Cell(row: row, column: column)] else { return }
                
                let mazeCell = MazeCell(rowNumber: row, columnNumber: column, exitDirections: exitDirections, frame: .zero)
                stackView.addArrangedSubview(mazeCell)
                cells.append(mazeCell)
            }
        }
    }
    
    func enterCell(atRow row: Int, column: Int) {
        //Place icon at specific coordinate
        let cell = cells.first(where: { $0.coordinate == (row, column) })
        currentCell = cell
        cell?.animateIcon()
    }
    
    func attemptToMove(_ direction: Direction) {
        guard let cell = currentCell else { return }
        guard let possibleDirections = cellExitDictionary[Cell(row: cell.coordinate.0, column: cell.coordinate.1)] else { return }
        //If move is valid, progress to next cell
        if possibleDirections.contains(direction) {
            let nextMazeCell = nextCell(direction, from: currentCell!)
            currentCell?.removeIcon()
            nextMazeCell.animateIcon()
            currentCell = nextMazeCell
        } else if (cell.coordinate.0 == exitCell.row) && (cell.coordinate.1 == exitCell.column) {
            print("you did it booooi")
        } else {
            print("can't go that way")
        }
    }
    
    func nextCell(_ direction: Direction, from currentCell: MazeCell) -> MazeCell {
        let currentRow = currentCell.coordinate.0
        let currentColumn = currentCell.coordinate.1
        var newCoordinates: (Int, Int) = (1, 1)
        
        switch direction {
        case .Up:
            newCoordinates = (currentRow-1, currentColumn)
        case .Down:
            newCoordinates = (currentRow+1, currentColumn)
        case .Left:
            newCoordinates = (currentRow, currentColumn-1)
        case .Right:
            newCoordinates = (currentRow, currentColumn+1)
        }
        
        if let nextCell = cells.first(where: { $0.coordinate == newCoordinates} ) {
            return nextCell
        } else {
            return currentCell
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


