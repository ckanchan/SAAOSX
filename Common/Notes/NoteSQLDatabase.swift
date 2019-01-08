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
    let note = Expression<Data>("note")
    let ckSystemFields = Expression<Data?>("ckSystemFields")
    let notesTable = Table("notes")
    
    let nodeReference = Expression<String>("nodeReference")
    let annotation = Expression<Data>("annotation")
    let annotationTable = Table("annotations")
    
    
    let db: Connection
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    
    let cloudKitDB: CloudKitNotes?
    
    func retrieveNote(forID id: String) -> Note? {
        let query = notesTable.select(note).filter(textID == id)
        guard let r = try? db.pluck(query),
            let row = r else {return nil}
        
        let data = row[note]
        return try? decoder.decode(Note.self, from: data)
    }
    
    func saveNote(_ noteToSave: Note) -> Bool {
        // Persist the note to the local database
        let id = noteToSave.id.description
        guard let data = try? encoder.encode(noteToSave) else {return false}
        do {
            _ = try db.run(notesTable.insert(
                textID <- id,
                note <- data
            ))
            
            //Sync the note with CloudKit
            cloudKitDB?.saveNote(noteToSave) {[weak self] record in
                guard let noteSQLDB = self else {return}
                
                let row = noteSQLDB.notesTable.filter(noteSQLDB.textID == id)
                
                let data = NSMutableData()
                let coder = NSKeyedArchiver(forWritingWith: data)
                coder.requiresSecureCoding = true
                record.encode(with: coder)
                coder.finishEncoding()
                
                do {
                    try noteSQLDB.db.run(row.update(noteSQLDB.ckSystemFields <- data as Data))
                } catch {
                    print(error.localizedDescription)
                }
            }
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }

    init? (url: URL, cloudKitDB: CloudKitNotes) {
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
                table.column(ckSystemFields)
                
            })
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
}
