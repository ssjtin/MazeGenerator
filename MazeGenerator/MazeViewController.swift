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
        
        view.backgroundColor = .white
        configureNavBar()
        renderMaze()
    }
    
    private func configureNavBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Quit", style: .plain, target: self, action: #selector(quitMaze))
    }
    
    @objc func quitMaze() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func renderMaze() {
        
        //Configure maze frame
        let width = view.frame.width * 0.9
        let originX = view.frame.midX - width/2
        let originY = view.frame.midY - width/2
        let mazeRect = CGRect(x: originX, y: originY, width: width, height: width)
        
        //Instantiate and setup maze grid
        maze = MazeGrid(mazeId: mazeId, username: fb.username, frame: mazeRect)
        maze.delegate = self
        self.view.addSubview(self.maze)
        
        //Create a database listener that updates player position info
        self.fb.createListener() { (data) in
            self.maze.playerData = data
        }
        
        self.fb.mazeCompletionListener { (winner) in
            print(winner)
        }
    }
    
}

extension MazeViewController: MazeGridDelegate {
    
    func handleEnteredExitCell() {
        fb.playerDidFinishMaze { (success) in
            print(success)
        }
    }
    
}
