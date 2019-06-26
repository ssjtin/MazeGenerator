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
    var mazeId: Int?
    
    static let shared = FirebaseService()
    
    let db = Firestore.firestore()
    
    func createMaze(completion: @escaping(()->())) {
        
        guard let id = mazeId else { return }
        let batch = db.batch()
        
        //Create document for mazeId
        let newMazeRef = db.collection("mazes").document("\(id)")
        batch.setData(["winner": "nil"], forDocument: newMazeRef)
        
        //Create collection of players, add creator at start position
        let userRef = newMazeRef.collection("players").document(username)
        batch.setData(["position": [1,1]], forDocument: userRef)
        
        batch.commit { (err) in
            if let err = err {
                print(err.localizedDescription)
            } else {
                print("Batch write succeeded")
            }
            completion()
        }
    }
    
    func checkMazeExists(id: Int, completion: @escaping((Bool) -> ())) {
        let mazeRef = db.collection("mazes").document("\(id)")
        mazeRef.getDocument { (snapshot, _) in
            completion(snapshot!.exists)
        }
    }
    
    func createListener(completion: @escaping(([String: [Int]]) -> ())) {
        
        guard let id = mazeId else { return }

        let playersRef = db.collection("mazes").document("\(id)").collection("players")
        
        playersRef.addSnapshotListener { (snapshot, error) in
            guard let snapshot = snapshot else {
                return
            }
            
            var newPlayerData: [String: [Int]] = [:]
            
            for document in snapshot.documents {
                let data = document.data()
                newPlayerData.updateValue(data["position"] as! [Int], forKey: document.documentID)
            }
            
            completion(newPlayerData)
        }

    }
    
    func mazeCompletionListener(completion: @escaping((String) -> ())) {
        let mazeRef = db.collection("mazes").document("\(mazeId!)")
        mazeRef.addSnapshotListener { (snapshot, error) in
            guard let winner = snapshot?.data()?["winner"] as? String else { return }
            
            completion(winner)
        }
    }
    
    func updatePosition(position: [Int], completion: @escaping(() -> ())) {
        
        guard let id = mazeId else { return }
        
        let playerRef = db.collection("mazes").document("\(id)").collection("players").document(username)
        playerRef.setData(["position": position]) { (error) in
            //handle error
            completion()
        }
        
    }
    
    func playerDidFinishMaze(completion: @escaping((Bool) -> ())) {
        //Check for winner, then write user as winning player
        let mazeRef = db.collection("mazes").document("\(mazeId!)")
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            
            let mazeDocument: DocumentSnapshot
            
            do {
                try mazeDocument = transaction.getDocument(mazeRef)
                
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                completion(false)
                return nil
            }
            
            guard let winner = mazeDocument.data()?["winner"] as? String else {
                print("Error reading winner data")
                return nil
            }
            
            if winner == "nil" {
                transaction.updateData(["winner": self.username], forDocument: mazeRef)
                completion(true)
                return nil
            } else {
                print("\(winner) already won")
            }
 
            //Return out of runTransaction
            completion(false)
            return nil
            
        }) { (object, error) in
            if let err = error {
                print(err.localizedDescription)
            }
        }
        
    }

}
