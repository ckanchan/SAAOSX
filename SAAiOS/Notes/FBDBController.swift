//
//  FBDBController.swift
//  SAAiOS
//
//  Created by Chaitanya Kanchan on 12/05/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

struct Note {
    var id: String
    var notes: [String]
    
    var firebaseData: [String: Any] {
        let data: [String: Any] = ["id": self.id, "notes": self.notes]
        return data
    }
    
    init(id: String, notes: [String]){
        self.id = id
        self.notes = notes
    }
    
    init?(withFirebaseData data: [String: Any]) {
    guard let id = data["id"] as? String else {return nil}
    guard let notes = data["notes"] as? [String] else {return nil}
    
    self.init(id: id, notes: notes)
    }
}


struct DatabaseController {
    let db = Firestore.firestore()
    
    func set(note: Note) {
        db.collection("Notes").document("\(note.id)").setData(note.firebaseData)
    }
    
    func getNotes(for textID: String, completionHandler: @escaping (Note) -> Void) {
        let docRef = db.collection("Notes").document(textID)
        
        docRef.getDocument{(document, error) in
            if let document = document, document.exists {
                guard let dict = document.data() else {return}
                guard let note = Note(withFirebaseData: dict) else {return}
                completionHandler(note)
            }
        }
        
    }
}


