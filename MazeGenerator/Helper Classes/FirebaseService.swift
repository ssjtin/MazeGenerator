//
//  FirebaseService.swift
//  MazeGenerator
//
//  Created by Hoang Luong on 18/6/19.
//  Copyright © 2019 Hoang Luong. All rights reserved.
//

import FirebaseFirestore

class FirebaseService {
    
    var username = ""
    
    static let shared = FirebaseService()
    
    let db = Firestore.firestore()
    
    func createMaze(id: Int, size: (row: Int, col: Int), completion: @escaping(()->())) {
        
        let batch = db.batch()
        
        //Create document for mazeId
        let newMazeRef = db.collection("mazes").document("\(id)")
        batch.setData(["winner": "nil"], forDocument: newMazeRef)
        
        //Create colleciton of players, add creator at start position
        let userRef = newMazeRef.collection("players").document(username)
        batch.setData(["position": [1,1]], forDocument: userRef)
        
        batch.commit { (err) in
            if let err = err {
                print(err.localizedDescription)
                completion()
            } else {
                print("Batch write succeeded")
                self.createListener(mazeId: id, completion: { (error) in
                    completion()
                })
            }
        }
    }
    
    func checkMazeExists(id: Int, completion: @escaping((Bool) -> ())) {
        let mazeRef = db.collection("mazes").document("\(id)")
        mazeRef.getDocument { (snapshot, _) in
            completion(snapshot!.exists)
        }
    }
    
    func createListener(mazeId: Int, completion: @escaping(([String: [Int]]) -> ())) {
        let playersRef = db.collection("mazes").document("\(mazeId)").collection("players")
        
        playersRef.addSnapshotListener { (snapshot, error) in
            
            guard let snapshot = snapshot else {
                return
            }
            
            var newPlayerData: [String: [Int]] = [:]
            
            for document in snapshot.documents {
                let data = document.data()
                newPlayerData.updateValue(data["position"] as! [Int], forKey: document.documentID)
            }
            
            snapshot.documentChanges.forEach({ (change) in
                
                switch change.type {
                case .modified, .added: ()
                case .removed: ()
                @unknown default:
                    fatalError()
                }
                
            })
            print(newPlayerData)
            completion(newPlayerData)
        }
        
    }
    
    func updatePosition(mazeId: Int, position: [Int], completion: @escaping(() -> ())) {
        let playerRef = db.collection("mazes").document("\(mazeId)").collection("players").document(username)
        playerRef.setData(["position": position]) { (error) in
            //handle error
            completion()
        }
    }

}
