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
    private func save(_ record: CKRecord, completionHandler: ((Result<CKRecord, Error>) -> Void)? = nil){
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
    
    func modifyRecord(_ record: CKRecord, completionHandler: ((Result<CKRecord, Error>) -> Void)? = nil) {
        let modifyOperation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        modifyOperation.perRecordCompletionBlock = { record, error in
            if let e = error {
                completionHandler?(.failure(e))
            } else {
                completionHandler?(.success(record))
            }
        }
        CKContainer.default().privateCloudDatabase.add(modifyOperation)
    }
    
    func saveNote(_ note: Note, completionHandler: ((Result<CKRecord, Error>) -> Void)? = nil) {
        guard userIsLoggedIn else {
            os_log("User is not logged into iCloud, cannot save note %s to server",
                   log: Log.CloudKit,
                   type: .error,
                   String(note.id))
            return
        }
        save(CKRecord(note: note), completionHandler: completionHandler)
    }
    
    func saveAnnotation(_ annotation: Annotation, completionHandler: ((Result<CKRecord, Error>) -> Void)? = nil) {
        guard userIsLoggedIn else {return}
        save(CKRecord(annotation: annotation), completionHandler: completionHandler)
    }
    
    func saveTags(_ tags: UserTags, completionHandler: ((Result<CKRecord, Error>) -> Void)? = nil) {
        guard userIsLoggedIn else {return}
        save(CKRecord(userTags: tags), completionHandler: completionHandler)
    }
    
    func deleteRecord(_ record: CKRecord) {
        let deleteOperation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [record.recordID])
        deleteOperation.modifyRecordsCompletionBlock = { _, deletedRecords, error in
            if let e = error {
                os_log("Error deleting record with ID: %s, error: %s", log: Log.CloudKit, type: .error, String(describing: record), e.localizedDescription)
            } else {
                os_log("Deleted record with ID: %s", log: Log.CloudKit, type: .info, String(describing: record))
            }
        }
        CKContainer.default().privateCloudDatabase.add(deleteOperation)
    }
}
