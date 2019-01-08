//
//  CloudKitPush.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 06/01/2019.
//  Copyright © 2019 Chaitanya Kanchan. All rights reserved.
//

import Foundation
import CloudKit
import CDKSwiftOracc

extension CloudKitNotes {
    private func save(_ record: CKRecord, completionHandler: ((CKRecord) -> Void)? = nil){
        CKContainer.default().privateCloudDatabase.save(record) { record, error in
            if let error = error {
                print(error.localizedDescription)
            } else if let record = record {
                print("Saved \(record)")
                if let handler = completionHandler {
                    handler(record)
                }
            }
        }
    }
    
    func saveNote(_ note: Note, completionHandler: ((CKRecord) -> Void)? = nil) {
        guard userIsLoggedIn else {return}
        if notes.keys.contains(note.id) {
            let modifyOperation = CKModifyRecordsOperation(
                recordsToSave: [note.toCKRecord()],
                recordIDsToDelete: nil)
            
            modifyOperation.modifyRecordsCompletionBlock = {[weak self] records, _, error in
                if let error = error {
                    print(error.localizedDescription)
                } else if let records = records {
                    print(records)
                    guard let ckdb = self else {return}
                    ckdb.notes[note.id] = note
                    if let handler = completionHandler {
                        records.forEach {handler($0)}
                    }
                }
            }
            
            CKContainer.default().privateCloudDatabase.add(modifyOperation)
        } else {
            save(note.toCKRecord(), completionHandler: completionHandler)
        }
    }
    
    func saveAnnotation(_ annotation: Annotation) {
        guard userIsLoggedIn else {return}
        let record = annotation.toCKRecord()
        
        if let textAnnotations = self.annotations[annotation.nodeReference.base],
            let _ = textAnnotations.first(where: {$0.nodeReference == annotation.nodeReference}) {
            let modifyOperation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
            
            modifyOperation.modifyRecordsCompletionBlock = {[weak self] record, _, error in
                if let error = error {
                    print(error.localizedDescription)
                } else if let record = record {
                    print(record)
                    guard let ckdb = self else {return}
                    let nodeReference = annotation.nodeReference
                    let textID = nodeReference.base
                    guard let index = ckdb.annotations[textID]?.firstIndex(where: {$0.nodeReference == nodeReference}) else {return}
                    ckdb.annotations[textID]?.remove(at: index)
                    ckdb.annotations[textID]?.append(annotation)
                }
            }
            
            CKContainer.default().privateCloudDatabase.add(modifyOperation)
        } else {
            save(record)
        }
    }
}
