//
//  NoteSQLDatabase.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 31/12/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Foundation
import SQLite
import CDKSwiftOracc
import CloudKit
import os

final class NoteSQLDatabase {
    let db: Connection
    weak var cloudKitDB: CloudKitNotes?
    
    func updateCloudKitMetadata(tableRow: Table, record: CKRecord) {
        let data = NSMutableData()
        let coder = NSKeyedArchiver(forWritingWith: data)
        coder.requiresSecureCoding = true
        record.encodeSystemFields(with: coder)
        coder.finishEncoding()
        
        let recordID = record.recordID.securelyEncoded()
        
        do {
            try db.run(tableRow.update(
                Schema.ckSystemFields <- data as Data,
                Schema.ckRecordID <- recordID
                ))
        } catch {
            os_log("Could not update CloudKit metadata for record with ID %s, error: %{public}s",
                   log: Log.NoteSQLite,
                   type: .error,
                   String(describing: record.recordID),
                   error.localizedDescription)
        }
    }
    
    func updateCloudKitMetadata(forNote note: Note, record: CKRecord) {
        let tableRow = Schema.notesTable.filter(Schema.textID == String(note.id))
        updateCloudKitMetadata(tableRow: tableRow, record: record)
    }
    
    func updateCloudKitMetadata(forAnnotation annotation: Annotation, record: CKRecord) {
        let tableRow = Schema.annotationTable.filter(Schema.nodeReference == String(annotation.nodeReference))
        updateCloudKitMetadata(tableRow: tableRow, record: record)
    }
    
    func updateCloudKitMetadata(forIndexedTag tag: Tag?, record: CKRecord) {
        if let tag = tag {
            let tableRow = Schema.tagsTable.filter(Schema.tag == tag)
            updateCloudKitMetadata(tableRow: tableRow, record: record)
        } else {
            let id = record.recordID.securelyEncoded()
            let tableRow = Schema.tagsTable.filter(Schema.ckRecordID == id)
            updateCloudKitMetadata(tableRow: tableRow, record: record)
        }
    }
    
    func clearAllCloudKitMetadata() throws {
        try db.run(Schema.notesTable.update(
            Schema.ckRecordID <- nil,
            Schema.ckSystemFields <- nil
        ))
        
        try db.run(Schema.tagsTable.update(
            Schema.ckRecordID <- nil,
            Schema.ckSystemFields <- nil
        ))
        
        try db.run(Schema.annotationTable.update(
            Schema.ckRecordID <- nil,
            Schema.ckSystemFields <- nil
        ))
    }
    
    /// Initiates a delete operation that began locally, then propagates the changes to CloudKit
    ///
    /// - Parameter query: scoped SQLite query filtering the rows for deletion
    /// - Throws: SQLite errors
    func deleteFromSQLAndCloud(query: Table) throws {
        guard let row = try? db.pluck(query) else {return}
        if let ckRecordInfo = row[Schema.ckSystemFields] {
            let unarchiver = NSKeyedUnarchiver(forReadingWith: ckRecordInfo)
            unarchiver.requiresSecureCoding = true
            if let record = CKRecord(coder: unarchiver) {
                cloudKitDB?.deleteRecord(record)
            }
        }        
        try db.run(query.delete())
    }
    
    /// Called when a record has been deleted from CloudKit, deleting the record in the local database
    ///
    /// - Parameters:
    ///   - recordID: unique CloudKit record key
    ///   - type: whether to search in `NoteTable` or `AnnotationTable`
    /// - Throws: SQLite errors
    func delete(recordID: CKRecord.ID, type: NoteType) throws {
        switch type {
        case .Note:
            try deleteNote(withRecordID: recordID)
        case .Annotation:
            try deleteAnnotation(withRecordID: recordID)
        case .Tag:
            try deleteIndexedTag(withRecordID: recordID)
        }
    }
    
    init? (url: URL, cloudKitDB: CloudKitNotes?) {
        self.cloudKitDB = cloudKitDB
        do {
            let connection = try Connection(url.path)
            self.db = connection
            
            try connection.run(Schema.notesTable.create(ifNotExists: true) {table in
                table.column(Schema.textID, primaryKey: true)
                table.column(Schema.note)
                table.column(Schema.ckSystemFields)
                table.column(Schema.ckRecordID)
            })
            
            try connection.run(Schema.notesTable.createIndex(Schema.textID,
                                                             unique: true,
                                                             ifNotExists: true))
            
            try connection.run(Schema.annotationTable.create(ifNotExists: true) {table in
                table.column(Schema.nodeReference, primaryKey: true)
                table.column(Schema.textID)
                table.column(Schema.transliteration)
                table.column(Schema.normalisation)
                table.column(Schema.translation)
                table.column(Schema.context)
                table.column(Schema.annotation)
                table.column(Schema.tags, collate: .nocase)
                table.column(Schema.ckSystemFields)
                table.column(Schema.ckRecordID)
            })
            
            try connection.run(Schema.annotationTable.createIndex(Schema.nodeReference,
                                                                  unique: true,
                                                                  ifNotExists: true))
            
            try connection.run(Schema.tagsTable.create(ifNotExists: true) {table in
                table.column(Schema.tag)
                table.column(Schema.nodeReferences)
                table.column(Schema.ckSystemFields)
                table.column(Schema.ckRecordID)
            })
            
            try connection.run(Schema.tagsTable.createIndex(Schema.tag,
                                                            unique: true,
                                                            ifNotExists: true))
            
        } catch {
            os_log("Could not initialise SQLite Notes Database: %s",
                   log: Log.NoteSQLite,
                   type: .error,
                   error.localizedDescription)
            return nil
        }
    }
}
