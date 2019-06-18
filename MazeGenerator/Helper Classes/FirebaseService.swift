//
//  FirebaseService.swift
//  MazeGenerator
//
//  Created by Hoang Luong on 18/6/19.
//  Copyright © 2019 Hoang Luong. All rights reserved.
//

import FirebaseFirestore

class FirebaseService {
    
    let db = Firestore.firestore()
    
    func write() {
        db.collection("cities").document("LA").setData([
            "name": "Los Angeles",
            "state": "CA",
            "country": "USA"
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
    
    
}






