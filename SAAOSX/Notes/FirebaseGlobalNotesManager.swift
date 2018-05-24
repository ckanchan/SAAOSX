//
//  FirebaseGlobalNotesManager.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 24/05/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Foundation
import CDKSwiftOracc

import FirebaseCore
import FirebaseAuth
import FirebaseDatabase

protocol GlobalNoteShowing: AnyObject {
    func noteAdded(_ note: Note)
    func noteRemoved(_ textID: TextID)
    func noteChanged(_ note: Note)
}

class FirebaseGlobalNotesManager {
    private let db = Database.database().reference()
    private let user: User
    weak var delegate: GlobalNoteShowing?
    
    lazy var noteAddedListener: DatabaseHandle = {
        return db.child("users").child(user.uid).observe(.childAdded) { [weak self] snapshot in
            guard let rawData = snapshot.value else {return}
            guard let dictionary = rawData as? [String: Any] else {return}
            guard let note = Note(withFirebaseData: dictionary) else {return}
            self?.delegate?.noteAdded(note)
        }
    }()
    
    lazy var noteDeletedListener: DatabaseHandle = {
        return db.child("users").child(user.uid).observe(.childRemoved){ [weak self] snapshot in
            let index = snapshot.key
            let id = TextID(stringLiteral: index)
            self?.delegate?.noteRemoved(id)
        }
    }()
    
    lazy var noteChangedListener: DatabaseHandle = {
        return db.child("users").child(user.uid).observe(.childChanged) { [weak self] snapshot in
            guard let rawData = snapshot.value else {return}
            guard let dictionary = rawData as? [String: Any] else {return}
            guard let note = Note(withFirebaseData: dictionary) else {return}
            self?.delegate?.noteChanged(note)
        }
    }()
    
    func getAllNotes(then performCompletion: @escaping ([TextID: Note]) -> Void) {
        db.child("users").child(user.uid).observeSingleEvent(of: .value) {snapshot in
            guard let rawData = snapshot.value else {return}
            guard var topLevelDict = rawData as? [String: Any] else {return}
            topLevelDict.removeValue(forKey: "tags")
            guard let dictionary = topLevelDict as? [String: [String: Any]] else {return}
            
            let notes: [TextID: Note] = Dictionary(uniqueKeysWithValues:
                dictionary.compactMap {
                    guard let note = Note(withFirebaseData: $0.value) else {return nil}
                    let id = TextID.init(stringLiteral: $0.key)
                    return (id, note)
                }
            )
            
            performCompletion(notes)
        }
    }
    
    init(for user: User) {
        self.user = user
        print("Initialised listeners \(self.noteAddedListener)\(self.noteDeletedListener)\(self.noteChangedListener)")
    }
    
    deinit {
        db.removeObserver(withHandle: noteAddedListener)
        db.removeObserver(withHandle: noteDeletedListener)
        db.removeObserver(withHandle: noteChangedListener)
    }
}
