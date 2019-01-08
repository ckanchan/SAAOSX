//
//  CloudKitPull.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 06/01/2019.
//  Copyright © 2019 Chaitanya Kanchan. All rights reserved.
//

import Foundation
import CloudKit
import CDKSwiftOracc

extension CloudKitNotes {
    func retrieveAllNotes(completionHandler: @escaping (([TextID: Note]) -> Void)) {
        guard userIsLoggedIn else {return}
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: CKRecord.RecordTypes.Note, predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        var notes = [TextID: Note]()
        operation.recordFetchedBlock = { record in
            guard let note = record.toNote() else {return}
            notes[note.id] = note
        }
        
        operation.queryCompletionBlock = { [weak self] _, error in
            if let error = error {
                print(error.localizedDescription)
            }
            DispatchQueue.main.async {
                guard let ckdb = self else {return}
                ckdb.notes = notes
                completionHandler(ckdb.notes)
            }
        }
        
        CKContainer.default().privateCloudDatabase.add(operation)
    }
    
    func retrieveNotes(forTextID textID: TextID,
                       forRetrievedNote performTask: @escaping((Note) -> Void),
                       onCompletion: @escaping((CKQueryOperation.Cursor?) -> Void)) {
        
        guard userIsLoggedIn else { return }
        if let note = notes[textID] {
            performTask(note)
            onCompletion(nil)
        } else {
            let query = CKQuery(recordType: CKRecord.RecordTypes.Note, predicate: Query.TextID(textID))
            let operation = CKQueryOperation(query: query)
            operation.recordFetchedBlock = { [weak self] record in
                guard let note = record.toNote() else {return}
                DispatchQueue.main.async {
                    guard let ckdb = self else {return}
                    ckdb.notes[note.id] = note
                    performTask(ckdb.notes[note.id]!)
                }
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
    
    func retrieveAllAnnotations(completionHandler: @escaping(([TextID: [Annotation]])-> Void)) {
        guard userIsLoggedIn else {return}
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: CKRecord.RecordTypes.Annotation, predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        var annotations = [Annotation]()
        operation.recordFetchedBlock = { record in
            guard let annotation = record.toAnnotation() else {return}
            annotations.append(annotation)
        }
        
        operation.queryCompletionBlock = { [weak self] _, error in
            if let error = error {
                print(error.localizedDescription)
            }
            let results = Dictionary(grouping: annotations, by: {$0.nodeReference.base})
            
            DispatchQueue.main.async {
                guard let ckdb = self else {return}
                ckdb.annotations = results
                completionHandler(ckdb.annotations)
            }
        }
        
        CKContainer.default().privateCloudDatabase.add(operation)
    }
    
    func retrieveAnnotations(forTextID id: TextID) -> [Annotation] {
        if let annotations = annotations[id] {
            return annotations
        } else {
            return []
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
}
