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
    
    enum Query {
        static func TextID(_ id: TextID) -> NSPredicate {
            let textID = id.description
            return NSPredicate(format: "textID == %@", textID)
        }
    }
    
    var userTags: UserTags {
        get {
            guard let tags = NSUbiquitousKeyValueStore.default.array(forKey: "userTags") as? [Tag] else {return UserTags([])}
            return UserTags(tags)
        } set(tags) {
            let array = Array(tags.tags)
            NSUbiquitousKeyValueStore.default.set(array, forKey: "userTags")
        }
    }
    
    var userIsLoggedIn: Bool
    
    private var records = [TextID: CKRecord.ID]()
    
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
    
    private func save(_ record: CKRecord){
        CKContainer.default().privateCloudDatabase.save(record) { [weak self] record, error in
            if let error = error {
                print(error.localizedDescription)
            } else if let record = record {
                print("Saved \(record)")
                if record.recordType == CKRecord.RecordTypes.Note {
                    guard let cloudKitNotes = self,
                        let textIDStr = record["textID"] as? String else {return}
                    let textID = TextID(stringLiteral: textIDStr)
                    cloudKitNotes.records[textID] = record.recordID
                }
            }
        }
    }
    
    func saveNote(_ note: Note) {
        guard userIsLoggedIn else {return}
        if records.keys.contains(note.id) {
            let modifyOperation = CKModifyRecordsOperation(
                recordsToSave: [note.toCKRecord()],
                recordIDsToDelete: nil)
            
            modifyOperation.modifyRecordsCompletionBlock = {_, _, error in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
            
            CKContainer.default().privateCloudDatabase.add(modifyOperation)
        } else {
            save(note.toCKRecord())
        }
    }
    
    func saveAnnotation(_ annotation: Annotation) {
        guard userIsLoggedIn else {return}
        let record = CKRecord(recordType: CKRecord.RecordTypes.Annotation)
        record["textID"] = annotation.nodeReference.base.description
        record["nodeReference"] = annotation.nodeReference.description
        record["transliteration"] = annotation.transliteration
        record["normalisation"] = annotation.normalisation
        record["translation"] = annotation.translation
        record["context"] = annotation.context
        record["annotation"] = annotation.annotation
        record["tags"] = Array(annotation.tags)
        
        save(record)
    }
    
    func retrieveAllNotes(completionHandler: @escaping (([Note]) -> Void)) {
        guard userIsLoggedIn else {return}
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: CKRecord.RecordTypes.Note, predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        var notes = [Note]()
        operation.recordFetchedBlock = { record in
            guard let note = record.toNote() else {return}
            notes.append(note)
        }
        
        operation.queryCompletionBlock = { _, error in
            if let error = error {
                print(error.localizedDescription)
            }
            DispatchQueue.main.async {
                completionHandler(notes)
            }
        }
        
        CKContainer.default().privateCloudDatabase.add(operation)
    }
    
    func retrieveNotes(forTextID textID: TextID,
                       forRetrievedNote performTask: @escaping((Note) -> Void),
                       onCompletion: @escaping((CKQueryOperation.Cursor?) -> Void)) {
        
        guard userIsLoggedIn else { return }
        if let cloudKitID = records[textID] {
            CKContainer.default().privateCloudDatabase.fetch(withRecordID: cloudKitID) { record, error in
                if let error = error {
                    print(error.localizedDescription)
                }
                if let record = record,
                    let note = record.toNote() {
                    performTask(note)
                    onCompletion(nil)
                }
            }
        } else {
            let query = CKQuery(recordType: CKRecord.RecordTypes.Note, predicate: Query.TextID(textID))
            let operation = CKQueryOperation(query: query)
            operation.recordFetchedBlock = { [weak self] record in
                if let cloudKitNotes = self {
                    cloudKitNotes.records[textID] = (record.recordID)
                }
                guard let note = record.toNote() else {return}
                performTask(note)
            }
            
            operation.queryCompletionBlock = { cursor, error in
                if let error = error {
                    print(error.localizedDescription)
                }
                onCompletion(cursor)
            }
            
            CKContainer.default().privateCloudDatabase.add(operation)
        }
    }
    
    func retrieveAnnotations(forTextID id: TextID,
                             forRetrievedAnnotation performTask: @escaping((Annotation) -> Void),
                             onCompletion: @escaping((CKQueryOperation.Cursor?) -> Void)) {
        
        guard userIsLoggedIn else { return }
        let query = CKQuery(recordType: CKRecord.RecordTypes.Annotation, predicate: Query.TextID(id))
        let operation = CKQueryOperation(query: query)
        operation.recordFetchedBlock = { record in
            guard let annotation = record.toAnnotation() else {return}
            performTask(annotation)
        }
        operation.queryCompletionBlock = {(cursor, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            onCompletion(cursor)
        }
        
        CKContainer.default().privateCloudDatabase.add(operation)
    }
    
    init() {
        userIsLoggedIn = false
        self.userStatusDidChange()
        NotificationCenter.default.addObserver(self, selector: #selector(userStatusDidChange), name: .CKAccountChanged, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
}

protocol NoteDelegate: AnyObject {
    func noteAdded(_ note: Note)
    func noteRemoved(_ textID: TextID)
    func noteChanged(_ note: Note)
    
    func searchResultsUpdated(_ notes: [Note])
}

extension Note {
    func toCKRecord() -> CKRecord {
        let record = CKRecord(recordType: CKRecord.RecordTypes.Note)
        record["textID"] = self.id.description
        record["notes"] = self.notes
        return record
    }
}
