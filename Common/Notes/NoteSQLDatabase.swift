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

final class NoteSQLDatabase {
    
    //Database schema
    let textID = Expression<String>("textid")
    let note = Expression<String>("note")
    let ckSystemFields = Expression<Data?>("ckSystemFields")
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
    let cloudKitDB: CloudKitNotes?
    
    func updateCloudKitMetadata(forID id: TextID, record: CKRecord) {
        let row = notesTable.filter(textID == String(describing: id))
        let data = NSMutableData()
        let coder = NSKeyedArchiver(forWritingWith: data)
        coder.requiresSecureCoding = true
        record.encodeSystemFields(with: coder)
        coder.finishEncoding()
        do {
            try db.run(row.update(ckSystemFields <- data as Data))
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func retrieveNote(forID id: TextID) -> Note? {
        let query = notesTable.select(note).filter(textID == String(describing: id))
        guard let row = try? db.pluck(query) else {return nil}        
        let notes = row[note]
        return Note(id: id, notes: notes)
    }
    
    func saveNote(_ noteToSave: Note) {
        // Persist the note to the local database
        do {
            _ = try db.run(notesTable.insert(
                textID <- noteToSave.id.description,
                note <- noteToSave.notes
            ))
            
            //Sync the note with CloudKit
            cloudKitDB?.saveNote(noteToSave) {[weak self] result in
                guard let noteSQLDB = self else {return}
                switch result {
                case .success(let record):
                    noteSQLDB.updateCloudKitMetadata(forID: noteToSave.id, record: record)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func updateNote(_ noteToUpdate: Note) {
        // Persist the note to the local database
        let id = String(describing: noteToUpdate.id)
        let query = notesTable.filter(textID == String(describing: id))
        
        do {
            _ = try db.run(query.update(
                note <- noteToUpdate.notes
            ))
            
            guard let row = try? db.pluck(query),
                let ckRecordData = row[ckSystemFields] else {return}
            
            let unarchiver = NSKeyedUnarchiver(forReadingWith: ckRecordData)
            unarchiver.requiresSecureCoding = true
            guard let record = CKRecord(coder: unarchiver) else {return}
            record["notes"] = noteToUpdate.notes
            
            
            //Sync the note with CloudKit
            cloudKitDB?.modifyRecord(record) { [weak self] result in
                guard let noteDB = self else {return}
                switch result {
                case .success(let record):
                    noteDB.updateCloudKitMetadata(forID: noteToUpdate.id, record: record)
                    print(record)
                case .failure(let error):
                    print(error.localizedDescription)
                }
                
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func deleteNote(forID id: TextID) throws {
        let query = notesTable.filter(textID == String(describing: id))
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

    init? (url: URL, cloudKitDB: CloudKitNotes?) {
        self.cloudKitDB = cloudKitDB
        do {
            let connection = try Connection(url.path)
            self.db = connection
            
            try connection.run(notesTable.create(ifNotExists: true) {table in
                table.column(textID, primaryKey: true)
                table.column(note)
                table.column(ckSystemFields)
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
            })
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
}
