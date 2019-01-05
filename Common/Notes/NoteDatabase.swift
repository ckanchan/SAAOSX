//
//  NoteDatabase.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 31/12/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Foundation
import SQLite
import CDKSwiftOracc

final class NoteDatabase {
    
    //Database schema
    let textid = Expression<String>("textid")
    let note = Expression<Data>("note")
    let notesTable = Table("notes")
    
    let db: Connection
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    
    func retrieveNote(forID id: String) -> Note? {
        let query = notesTable.select(note).filter(textid == id)
        guard let r = try? db.pluck(query),
            let row = r else {return nil}
        
        let data = row[note]
        return try? decoder.decode(Note.self, from: data)
    }
    
    func saveNote(_ noteToSave: Note) -> Bool {
        let id = noteToSave.id.description
        guard let data = try? encoder.encode(noteToSave) else {return false}
        do {
            _ = try db.run(notesTable.insert(
                textid <- id,
                note <- data
            ))
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }

    init? (url: URL) {
        do {
            let connection = try Connection(url.path)
            self.db = connection
            
            try connection.run(notesTable.create(ifNotExists: true) {table in
                table.column(textid, primaryKey: true)
                table.column(note)
            })
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
}
