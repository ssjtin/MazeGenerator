//
//  MazeGrid.swift
//  MazeGenerator
//
//  Created by Hoang Luong on 12/6/19.
//  Copyright © 2019 Hoang Luong. All rights reserved.
//

import UIKit

protocol MazeGridDelegate: class {
    func handleEnteredExitCell()
}

class MazeGrid: UIView {
    
    let mazeId: Int
    let username: String
    
    var delegate: MazeGridDelegate?
    
    var playerData: [String: [Int]] = [:] {
        didSet {
            renderPlayers()
        }
    }
    // Array holds reference to all maze cell UIVIEWs in grid
    var cells = [MazeCell]()
    
    // Info of Cell object and exit direcitons
    let cellExitDictionary: [Cell: Set<Direction>]
    
    var currentCell: MazeCell?
    let exitCell: Cell! 
    
    init(mazeId: Int, username: String, frame: CGRect) {
        self.mazeId = mazeId
        self.username = username
        
        //Retrieve rows and columns value from id (last four digits)
        let idArray = String(mazeId).compactMap { Int(String($0)) }
        let rows = idArray[4]*10 + idArray[5]
        let columns = idArray[6]*10 + idArray[7]
        
        //Generate maze info from maze id
        let generator = MazeGenerator(numberOfRows: rows, numberOfColumns: columns, seedValue: UInt64(mazeId))
        generator.startGeneratingMaze()
        //Set maze values
        cellExitDictionary = generator.cellExitDictionary
        exitCell = generator.exitCell
        
        super.init(frame: frame)
        
        //Draw maze
        configureGrid(rows, by: columns)
        renderExitCell()
    }
    
    func configureGrid(_ rows: Int, by columns: Int) {
        //Render vertical stackview of horizontal stackviews containing maze cells
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
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapCell))
                let mazeCell = MazeCell(rowNumber: row, columnNumber: column, exitDirections: exitDirections, frame: .zero)
                //mazeCell.isUserInteractionEnabled = true
                mazeCell.addGestureRecognizer(tapGesture)
                stackView.addArrangedSubview(mazeCell)
                cells.append(mazeCell)
            }
        }
    }
    
    func renderExitCell() {
        if let cell = cells.first(where: { ($0.coordinate.0 == exitCell.row) && ($0.coordinate.1 == exitCell.column) }) {
            cell.setExit()
        }
    }
    
    func enterCell(atRow row: Int, column: Int) {
        //Place icon at specific coordinate
        let cell = cells.first(where: { $0.coordinate == (row, column) })
        currentCell = cell
        cell?.animateIcon()
    }
    
    func renderPlayers() {
        //Redraw player sprites from updated player data
        clearCells()
        for (player, position) in playerData {
            if player == username {
                currentCell = cells.first(where: { $0.coordinate == (position[0], position[1]) })
            }
            cells.first(where: { $0.coordinate == (position[0], position[1]) })?.animateIcon()
        }
    }
    
    //Remove icons from all cells in maze grid
    func clearCells() {
        for cell in cells {
            cell.removeIcon()
        }
    }
    
    func attemptToMove(toward toCell: MazeCell) {
        guard let cell = currentCell else { return }
        guard let possibleDirections = cellExitDictionary[Cell(row: cell.coordinate.0, column: cell.coordinate.1)] else { return }
        
        //Case tapping current cell
        guard cell != toCell else { isUserInteractionEnabled = true; return }
        
        var direction: Direction!
        //Check tapped cell is on same X or Y axis
        if cell.coordinate.0 == toCell.coordinate.0 {
            if cell.coordinate.1 < toCell.coordinate.1 {
                direction = .Right
            } else if cell.coordinate.1 > toCell.coordinate.1 {
                direction = .Left
            }
        } else if cell.coordinate.1 == toCell.coordinate.1 {
            if cell.coordinate.0 < toCell.coordinate.0 {
                direction = .Down
            } else if cell.coordinate.0 > toCell.coordinate.0 {
                direction = .Up
            }
        } else {
            print("not valid direction")
            isUserInteractionEnabled = true
            return
        }

        //If move is valid, progress to next cell
        if possibleDirections.contains(direction) {
            let nextMazeCell = nextCell(direction, from: cell)
            cell.removeIcon()
            nextMazeCell.animateIcon()
            currentCell = nextMazeCell
            
            //Check if new current cell is exit cell
            if  (currentCell!.coordinate.0 == exitCell.row) &&
                (currentCell!.coordinate.1 == exitCell.column) {
                //Notify delegate player reached exit cell
                delegate?.handleEnteredExitCell()
            }
        }
        //Enable tap recognition
        isUserInteractionEnabled = true
    }
    
    func nextCell(_ direction: Direction, from currentCell: MazeCell) -> MazeCell {
        let currentRow = currentCell.coordinate.0
        let currentColumn = currentCell.coordinate.1
        let newCoordinates: (Int, Int)!
        
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
    
    @objc func didTapCell(sender: UITapGestureRecognizer) {
        //Disable gesture interaction until move resolves
        isUserInteractionEnabled = false
        
        if let cell = sender.view as? MazeCell {
            attemptToMove(toward: cell)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


