//
//  MazeGenerator.Swift
//  MazeGenerator
//
//  Created by Hoang Luong on 12/6/19.
//  Copyright © 2019 Hoang Luong. All rights reserved.
//

import UIKit

class MazeViewController: UIViewController {
    
    let mazeId: Int
    let fb = FirebaseService.shared
    
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
    
    init(mazeId: Int) {
        self.mazeId = mazeId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavBar()
        
        view.backgroundColor = .white
        
        renderMaze()
        
        //Movement buttons
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
    
    private func configureNavBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Quit", style: .plain, target: self, action: #selector(quitMaze))
    }
    
    @objc func quitMaze() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func renderMaze() {

        let width = view.frame.width * 0.9
        let originX = view.frame.midX - width/2
        let originY = view.frame.midY - width/2
        let mazeRect = CGRect(x: originX, y: originY, width: width, height: width)
        
        maze = MazeGrid(mazeId: mazeId, username: fb.username, frame: mazeRect)
        
        //Create a database listener that updates player position info
        fb.createListener(mazeId: mazeId) { (data) in
            self.maze.playerData = data
            if data[self.fb.username] == nil {
                self.fb.updatePosition(mazeId: self.mazeId, position: [1,1], completion: {
                    self.view.addSubview(self.maze)
                })
            }
        }
    }
    
    @objc func goUp() {
        movePlayer(.Up)
    }
    
    @objc func goDown() {
        movePlayer(.Down)
    }
    
    @objc func goLeft() {
        movePlayer(.Left)
    }
    
    @objc func goRight() {
        movePlayer(.Right)
    }
    
    func movePlayer(_ direction: Direction) {
        if let newPosition = maze.attemptToMove(direction) {
            fb.updatePosition(mazeId: mazeId, position: [newPosition.0, newPosition.1], completion: { })
            
        }
    }
    
}
