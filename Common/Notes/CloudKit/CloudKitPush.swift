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
    private func save(_ record: CKRecord, completionHandler: ((Result<CKRecord, Error>) -> Void)? = nil){
        CKContainer.default().privateCloudDatabase.save(record) { record, error in
            if let error = error {
                completionHandler?(.failure(error))
            } else if let record = record {
                print("Saved \(record)")
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
        guard userIsLoggedIn else {return}
        save(note.toCKRecord(), completionHandler: completionHandler)
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
    
    func deleteRecord(_ record: CKRecord) {
        let deleteOperation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [record.recordID])
        deleteOperation.modifyRecordsCompletionBlock = { _, deletedRecords, error in
            if let e = error {
                print(e)
            } else {
                print(deletedRecords ?? [])
            }
        }
        CKContainer.default().privateCloudDatabase.add(deleteOperation)
    }
    
//    func modifyAnnotation(_ annotation: Annotation) {
//        if let textAnnotations = self.annotations[annotation.nodeReference.base],
//            let _ = textAnnotations.first(where: {$0.nodeReference == annotation.nodeReference}) {
//            let modifyOperation = CKModifyRecordsOperation(recordsToSave: [], recordIDsToDelete: nil)
//            
//            modifyOperation.modifyRecordsCompletionBlock = {[weak self] record, _, error in
//                if let error = error {
//                    print(error.localizedDescription)
//                } else if let record = record {
//                    print(record)
//                    guard let ckdb = self else {return}
//                    let nodeReference = annotation.nodeReference
//                    let textID = nodeReference.base
//                    guard let index = ckdb.annotations[textID]?.firstIndex(where: {$0.nodeReference == nodeReference}) else {return}
//                    ckdb.annotations[textID]?.remove(at: index)
//                    ckdb.annotations[textID]?.append(annotation)
//                }
//            }
//            
//            CKContainer.default().privateCloudDatabase.add(modifyOperation)
//        }
//    }
}
