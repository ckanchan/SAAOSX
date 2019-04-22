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
    
    //Database schema
    let textID = Expression<String>("textid")
    let note = Expression<String>("note")
    let ckSystemFields = Expression<Data?>("ckSystemFields")
    let ckRecordID = Expression<Data?>("ckRecordID")
    let notesTable = Table("notes")
    
    let nodeReference = Expression<String>("nodeReference")
    let transliteration = Expression<String>("transliteration")
    let normalisation = Expression<String>("normalisation")
    let translation = Expression<String>("translation")
    let context = Expression<String>("context")
    let annotation = Expression<String>("annotation")
    let tags = Expression<String>("tags")
    let annotationTable = Table("annotations")
    
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
                ckSystemFields <- data as Data,
                ckRecordID <- recordID
                ))
        } catch {
            os_log("SQLite error updating CloudKit metadata for record with ID %s, error: %s",
                   log: Log.NoteSQLite,
                   type: .error,
                   String(describing: record.recordID),
                   error.localizedDescription)
        }
    }
    
    func updateCloudKitMetadata(forNote note: Note, record: CKRecord) {
        let tableRow = notesTable.filter(textID == String(note.id))
        updateCloudKitMetadata(tableRow: tableRow, record: record)
    }
    
    func updateCloudKitMetadata(forAnnotation annotation: Annotation, record: CKRecord) {
        let tableRow = annotationTable.filter(nodeReference == String(describing: annotation.nodeReference))
        updateCloudKitMetadata(tableRow: tableRow, record: record)
    }
    
    /// Initiates a delete operation that began locally, then propagates the changes to CloudKit
    ///
    /// - Parameter query: scoped SQLite query filtering the rows for deletion
    /// - Throws: SQLite errors
    func delete(query: Table) throws {
        guard let row = try? db.pluck(query) else {return}
        if let ckRecordInfo = row[ckSystemFields] {
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
        default:
            return
        }
    }
    
    init? (url: URL, cloudKitDB: CloudKitNotes?) {
        self.cloudKitDB = cloudKitDB
        do {
            let connection = try Connection(url.path)
            self.db = connection
            
            try connection.run(notesTable.create(ifNotExists: true) {table in
                table.column(textID, primaryKey: true)
                table.column(note)
                table.column(ckSystemFields)
                table.column(ckRecordID)
            })
            
            try connection.run(annotationTable.create(ifNotExists: true) {table in
                table.column(nodeReference, primaryKey: true)
                table.column(textID)
                table.column(transliteration)
                table.column(normalisation)
                table.column(translation)
                table.column(context)
                table.column(annotation)
                table.column(tags)
                table.column(ckSystemFields)
                table.column(ckRecordID)
            })
        } catch {
            os_log("Could not initialise SQLite Notes Database: %s",
                   log: Log.NoteSQLite,
                   type: .error,
                   error.localizedDescription)
            return nil
        }
    }
}
