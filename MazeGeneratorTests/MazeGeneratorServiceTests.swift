//
//  MazeGeneratorTests.swift
//  MazeGeneratorTests
//
//  Created by Hoang Luong on 12/6/19.
//  Copyright © 2019 Hoang Luong. All rights reserved.
//

import XCTest
@testable import MazeGenerator

class MazeGeneratorServiceTests: XCTestCase {
    
    let mazeService = MazeGenerator()
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testUnvisitedCellFunction() {
        let possibleCells = [
            Cell(row: 1, column: 3),
            Cell(row: 2, column: 2),
            Cell(row: 1, column: 1)
        
        ]
        let visitedCells = [
            Cell(row: 1, column: 1),
            Cell(row: 2, column: 1),
            Cell(row: 3, column: 1),
        ]
        
        let result = mazeService.filterUnvisitedCells(from: possibleCells, comparedWith: visitedCells)
        
        XCTAssertEqual(result, [Cell(row: 2, column: 2), Cell(row: 1, column: 3)])
    }
    
    
    


}
