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
import os

extension CloudKitNotes {
    typealias CKCompletionHandler = ((Result<CKRecord, Error>) -> Void)?
    
    private func save(_ record: CKRecord, completionHandler: CKCompletionHandler = nil){
        CKContainer.default().privateCloudDatabase.save(record) { record, error in
            if let error = error {
                completionHandler?(.failure(error))
            } else if let record = record {
                os_log("Saved record to CloudKit",
                       log: Log.CloudKit,
                       type: .info)
                completionHandler?(.success(record))
            }
        }
    }
    
    func modifyRecord(_ record: CKRecord, completionHandler: CKCompletionHandler = nil) {
        modifyRecords([record], completionHandler: completionHandler)
    }
    
    func modifyRecords(_ records: [CKRecord], completionHandler: CKCompletionHandler = nil) {
        let modifyOperation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
        modifyOperation.perRecordCompletionBlock = {record, error in
            if let error = error {
                completionHandler?(.failure(error))
            } else {
                completionHandler?(.success(record))
            }
        }
    }
    
    func saveNote(_ note: Note, completionHandler: CKCompletionHandler = nil) {
        guard userIsLoggedIn else {
            os_log("User is not logged into iCloud, cannot save note %s to server",
                   log: Log.CloudKit,
                   type: .error,
                   String(note.id))
            return
        }
        save(CKRecord(note: note), completionHandler: completionHandler)
    }
    
    func saveAnnotation(_ annotation: Annotation, completionHandler: CKCompletionHandler = nil) {
        guard userIsLoggedIn else {
            os_log("User is not logged into iCloud, cannot save annotation %s to server",
                   log: Log.CloudKit,
                   type: .error,
                   String(annotation.nodeReference))
            return
        }
        save(CKRecord(annotation: annotation), completionHandler: completionHandler)
    }
    
    func saveTags(_ tags: UserTags, completionHandler: CKCompletionHandler = nil) {
        guard userIsLoggedIn else {return}
        save(CKRecord(userTags: tags), completionHandler: completionHandler)
    }
    
    func saveIndexedTag(_ tag: Tag, index: Set<NodeReference>, completionHandler: CKCompletionHandler = nil) {
        guard userIsLoggedIn else {
            os_log("User is not logged into iCloud, cannot save index for tag %s to server",
                   log: Log.CloudKit,
                   type: .error,
                   tag)
            return
        }
        save(CKRecord(tag: tag, index: index), completionHandler: completionHandler)
    }
    
    func saveIndexedTags(_ tagIndex: [Tag: Set<NodeReference>],
                         perRecordCompletionHandler completionHandler: CKCompletionHandler = nil) {
        guard userIsLoggedIn else {
            os_log("User is not logged into iCloud, cannot save indexes for tags %s to server",
                   log: Log.CloudKit,
                   type: .error,
                   tagIndex.keys.joined(separator: ", "))
            return
        }
        
        let records = tagIndex.map {CKRecord(tag: $0.key, index: $0.value)}
        let saveOperation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
        saveOperation.perRecordCompletionBlock = {record, error in
            if let error = error {
                completionHandler?(.failure(error))
            } else {
                completionHandler?(.success(record))
            }
        }
    }
    
    func deleteRecord(withID id: CKRecord.ID) {
        let deleteOperation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [id])
        deleteOperation.modifyRecordsCompletionBlock = { _, deletedRecords, error in
            if let e = error {
                os_log("Error deleting record with ID: %s, error: %s",
                       log: Log.CloudKit,
                       type: .error,
                       String(describing: id),
                       e.localizedDescription)
            } else {
                os_log("Deleted record with ID: %s",
                       log: Log.CloudKit,
                       type: .info,
                       String(describing: id))
            }
        }
        CKContainer.default().privateCloudDatabase.add(deleteOperation)
    }
    
    func deleteRecord(_ record: CKRecord) {
        deleteRecord(withID: record.recordID)
    }
}
