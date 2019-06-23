//
//  CreateNewMazeViewController.swift
//  MazeGenerator
//
//  Created by Hoang Luong on 19/6/19.
//  Copyright © 2019 Hoang Luong. All rights reserved.
//

import UIKit

class CreateNewMazeViewController: UIViewController {
    
    let fb = FirebaseService.shared
    
    let columns = 10
    let rows = 10
    
    //Initate view objects
    let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.distribution = .fillEqually
        return sv
    }()
    
    let createMazeButton: UIButton = {
        let button = UIButton()
        button.setTitle("New Maze", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(createMaze), for: .touchUpInside)
        return button
    }()
    
    let joinMazeButton: UIButton = {
        let button = UIButton()
        button.setTitle("Join Existing Maze", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(joinMaze), for: .touchUpInside)
        return button
    }()
    
    let identifierInputField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    //View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        configureSubviews()
        checkUser()
    }
    
    private func checkUser() {
        if let user = UserDefaults.standard.string(forKey: "username") {
            //fetch username
            navigationItem.title = user
            fb.username = user
        } else {
            presentLoginAlert()
        }
    }
    
    private func presentLoginAlert() {
        let alert = UIAlertController(title: "Login", message: "Enter username", preferredStyle: .alert)
        alert.addTextField { (textfield) in
            textfield.placeholder = "John Smith"
        }
        let action = UIAlertAction(title: "Done", style: .default) { (action) in
            if let username = alert.textFields![0].text {
                UserDefaults.standard.set(username, forKey: "username")
                self.navigationItem.title = username
                self.fb.username = username
            }
        }
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func configureSubviews() {
        
        view.addSubview(stackView)
        stackView.addArrangedSubview(createMazeButton)
        stackView.addArrangedSubview(joinMazeButton)
        stackView.addArrangedSubview(identifierInputField)
        
        stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 88).isActive = true
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        stackView.heightAnchor.constraint(equalToConstant: 500).isActive = true
    }
    
    @objc func createMaze() {
        //create random number
        let rnd = Int.random(in: 1000...9999)
        let mazeId = rnd*10000 + rows*100 + columns
        UserDefaults.standard.set(mazeId, forKey: "id")
        fb.createMaze(id: mazeId, size: (row: 12, col: 12)) {
            
        }
        let mazeVC = MazeViewController(mazeId: mazeId)
        navigationController?.pushViewController(mazeVC, animated: true)
    
    }
    
    @objc func joinMaze() {
        guard let mazeIdString = identifierInputField.text, let mazeId = Int(mazeIdString) else { return }
        fb.checkMazeExists(id: mazeId) { (exists) in
            if exists {
                self.presentMazeController(id: mazeId)
            }
        }
    }
    
    func presentMazeController(id: Int) {
        let mazeVC = MazeViewController(mazeId: id)
        navigationController?.pushViewController(mazeVC, animated: true)
    }

}
