//
//  FBDBController.swift
//  SAAiOS
//
//  Created by Chaitanya Kanchan on 12/05/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Foundation
import CDKSwiftOracc

import FirebaseCore
import FirebaseAuth
import FirebaseDatabase

protocol TextNoteDisplaying: AnyObject {
    func noteDidChange(_ note: Note)
}

protocol SingleAnnotationDisplaying: AnyObject {
    func annotationDidChange(_ annotation: Note.Annotation)
}


/// Class that manages notes for a given TextID
class FirebaseTextNoteManager {
    private let db = Database.database().reference()
    weak var delegate: TextNoteDisplaying?
    let user: User
    let textID: TextID

    
    lazy var listener: DatabaseHandle = {
        return db.child("users").child(user.uid).child(self.textID.description).observe(.value) { snapshot in
            guard let rawValue = snapshot.value else {return}
            guard let dictionary = rawValue as? Dictionary<String, Any> else {return}
            guard let note = Note.init(withFirebaseData: dictionary) else {return}
            self.delegate?.noteDidChange(note)
        }
    }()
    
    func set(note: Note) {
        db.child("users").child(user.uid).child(note.id.description).setValue(note.firebaseData)
        delegate?.noteDidChange(note)
    }
    
    init(for user: User, textID: TextID, delegate: TextNoteDisplaying){
        self.user = user
        self.textID = textID
        self.delegate = delegate
    }
    
    deinit {
        db.removeObserver(withHandle: listener)
    }
}

class FirebaseAnnotationManager {
    private let db = Database.database().reference()
    
    weak var delegate: SingleAnnotationDisplaying?
    let user: User
    let textID: TextID
    let node: NodeReference
    
    lazy var listener: DatabaseHandle = {
        return db.child("users").child(user.uid).child(self.textID.description).child("annotations").child(node.description.periodsToDashes).observe(.value) { snapshot in
            guard let rawValue = snapshot.value else {return}
            guard let dictionary = rawValue as? Dictionary<String, Any> else {return}
            guard let annotation = Note.Annotation(withFirebaseDictionary: dictionary) else {return}
            self.delegate?.annotationDidChange(annotation)
        }
    }()
    
    func set(annotation: Note.Annotation) {
        db.child("users").child(user.uid).child(textID.description).child("annotations").child(node.description.periodsToDashes).setValue(annotation.firebaseData)
    }
    
    
    init(for user: User, textID: TextID, node: NodeReference, delegate: SingleAnnotationDisplaying){
        self.user = user
        self.textID = textID
        self.node = node
        self.delegate = delegate
        print("Initialised \(self.listener)")
    }
    
    deinit {
        db.removeObserver(withHandle: listener)
    }
}

