//
//  MazeGenerator.Swift
//  MazeGenerator
//
//  Created by Hoang Luong on 12/6/19.
//  Copyright © 2019 Hoang Luong. All rights reserved.
//

import UIKit

class MazeViewController: UIViewController {
    
    let leftButton: UIButton = {
        let button = UIButton()
        button.setTitle("Left", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.addTarget(self, action: #selector(goLeft), for: .touchUpInside)
        return button
    }()
    
    let rightButton: UIButton = {
        let button = UIButton()
        button.setTitle("Right", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.addTarget(self, action: #selector(goRight), for: .touchUpInside)
        return button
    }()
    
    let upButton: UIButton = {
        let button = UIButton()
        button.setTitle("Up", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.addTarget(self, action: #selector(goUp), for: .touchUpInside)
        return button
    }()
    
    let downButton: UIButton = {
        let button = UIButton()
        button.setTitle("Down", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.addTarget(self, action: #selector(goDown), for: .touchUpInside)
        return button
    }()
    
    let buttonStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    var maze: MazeGrid!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let firebase = FirebaseService()
        firebase.write()
        
        view.backgroundColor = .white
        
        let rows = 10
        let columns = 10
        
        let width = view.frame.width * 0.9
        let originX = view.frame.midX - width/2
        let originY = view.frame.midY - width/2
        let mazeRect = CGRect(x: originX, y: originY, width: width, height: width)
        
        let generator = MazeGenerator(numberOfRows: rows, numberOfColumns: columns)
        generator.startGeneratingMaze()
        
        maze = MazeGrid(rows: rows, columns: columns, cellExitDictionary: generator.cellExitDictionary, frame: mazeRect)
        maze.exitCell = generator.exitCell
        
        view.addSubview(maze)
        
        maze.enterCell(atRow: 1, column: 1)
        
        view.addSubview(buttonStackView)
        buttonStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        buttonStackView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        buttonStackView.addArrangedSubview(upButton)
        buttonStackView.addArrangedSubview(downButton)
        buttonStackView.addArrangedSubview(leftButton)
        buttonStackView.addArrangedSubview(rightButton)
    }
    
    @objc func goUp() {
        maze.attemptToMove(.Up)
    }
    
    @objc func goDown() {
        maze.attemptToMove(.Down)
    }
    
    @objc func goLeft() {
        maze.attemptToMove(.Left)
    }
    
    @objc func goRight() {
        maze.attemptToMove(.Right)
    }
    
}
