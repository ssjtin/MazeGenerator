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
        button.addTarget(self, action: #selector(showCreateMazePopup), for: .touchUpInside)
        return button
    }()
    
    let joinMazeButton: UIButton = {
        let button = UIButton()
        button.setTitle("Join Existing Maze", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(showJoinMazePopup), for: .touchUpInside)
        return button
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
    
    private func configureSubviews() {
        view.addSubview(stackView)
        stackView.addArrangedSubview(createMazeButton)
        stackView.addArrangedSubview(joinMazeButton)
        
        stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 88).isActive = true
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        stackView.heightAnchor.constraint(equalToConstant: 500).isActive = true
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
    
    @objc func showCreateMazePopup() {
        let alert = UIAlertController(title: "New Maze", message: "", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.tag = 1
            textField.placeholder = "Number of rows"
            textField.keyboardType = .numberPad
        }
        
        alert.addTextField { (textField) in
            textField.tag = 2
            textField.placeholder = "Number of columns"
            textField.keyboardType = .numberPad
        }
        
        let confirmAction = UIAlertAction(title: "OK", style: .default) { (action) in
            guard   let rowString = alert.textFields?.first(where: { $0.tag == 1 })?.text,
                    let colString = alert.textFields?.first(where: { $0.tag == 2 })?.text,
                    let row = Int(rowString),
                    let col = Int(colString)
                else { return }
            
            self.createMaze(with: row,cols: col)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func createMaze(with rows: Int, cols: Int) {
        //create random number
        let rnd = Int.random(in: 1000...9999)
        let mazeId = rnd*10000 + rows*100 + cols
        fb.mazeId = mazeId
        fb.createMaze {
            self.presentMazeController(id: mazeId)
        }
    }
    
    @objc func showJoinMazePopup() {
        let alert = UIAlertController(title: "Join Maze", message: "", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Enter maze ID"
            textField.keyboardType = .numberPad
        }
        
        let confirmAction = UIAlertAction(title: "OK", style: .default) { (action) in
            guard   let rowString = alert.textFields?[0].text,
                    let mazeID = Int(rowString)
                else { return }
            
            self.joinMaze(id: mazeID)
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func joinMaze(id: Int) {
        fb.checkMazeExists(id: id) { (exists) in
            if exists {
                self.fb.mazeId = id
                self.presentMazeController(id: id)
            } else {
                self.showInvalidIdAlert()
            }
        }
    }
    
    func showInvalidIdAlert() {
        let alert = UIAlertController(title: "Maze ID doesn't exist", message: "Please check and try again", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    func presentMazeController(id: Int) {
        let mazeVC = MazeViewController(mazeId: id)
        navigationController?.pushViewController(mazeVC, animated: true)
    }

}
