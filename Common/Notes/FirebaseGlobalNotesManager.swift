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

protocol NoteDelegate: AnyObject {
    func noteAdded(_ note: Note)
    func noteRemoved(_ textID: TextID)
    func noteChanged(_ note: Note)
    
    func searchResultsUpdated(_ notes: [Note])
}

class FirebaseGlobalNotesManager {
    private let db = Database.database().reference()
    private let user: User
    weak var delegate: NoteDelegate?
    
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
    
    private var searchListener: DatabaseHandle? {
        didSet {
            if let oldValue = oldValue {
                db.removeObserver(withHandle: oldValue)
            }
        }
    }
    
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
    
    func searchDatabase(for citationForm: String) {
        //let query = db.child("users").child(user.uid).queryOrdered(byChild: "annotations/normalisation").queryEqual(toValue: "\(citationForm)")
        
        let query = db.child("users").child(user.uid).queryOrdered(byChild: "normalisation").queryEqual(toValue: citationForm.lowercased())
        self.searchListener = query.observe(.value) { snapshot in
            print(snapshot)
        }
    }
    
    func endSearch() {
        self.searchListener = nil
    }
    
    
    init(for user: User) {
        self.user = user
        self.searchListener = nil
        print("Initialised listeners \(self.noteAddedListener)\(self.noteDeletedListener)\(self.noteChangedListener)")
    }
    
    deinit {
        db.removeObserver(withHandle: noteAddedListener)
        db.removeObserver(withHandle: noteDeletedListener)
        db.removeObserver(withHandle: noteChangedListener)
        if let searchHandle = searchListener {
            db.removeObserver(withHandle: searchHandle)
        }
    }
}
