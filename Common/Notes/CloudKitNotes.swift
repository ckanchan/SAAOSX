//
//  CloudKitNotes.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 31/12/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Foundation
import CloudKit
import CDKSwiftOracc

class CloudKitNotes {
    static let recordIdentifier = "Note"
    static let encoder = JSONEncoder()
    
    var userIsLoggedIn: Bool
    
    @objc func userStatusDidChange() {
        CKContainer.default().accountStatus { [weak self] status, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            switch status {
            case .available:
                self?.userIsLoggedIn = true
            default:
                return
            }
        }
    }
    
    func saveNote(_ note: Note) {
        guard userIsLoggedIn else {return}
        let record = CKRecord(recordType: CloudKitNotes.recordIdentifier)
        let data = try! CloudKitNotes.encoder.encode(note.annotations)
        
        record["textID"] = note.id.description
        record["notes"] = note.notes
        record["annotations"] = data
        CKContainer.default().privateCloudDatabase.save(record) {record, error in
            if let error = error {
                print(error.localizedDescription)
            } else if let record = record {
                print("Saved \(record)")
            }
        }
    }
    
    func retrieveNote(forID id: String) -> Note? {
        return nil
    }
    
    init() {
        userIsLoggedIn = false
        self.userStatusDidChange()
        NotificationCenter.default.addObserver(self, selector: #selector(userStatusDidChange), name: .CKAccountChanged, object: nil)
    }
    
    
}
