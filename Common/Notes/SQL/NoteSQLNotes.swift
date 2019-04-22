//
//  NoteSQLNotes.swift
//  SAAo-SX
//
//  Created by Chaitanya Kanchan on 31/03/2019.
//  Copyright © 2019 Chaitanya Kanchan. All rights reserved.
//

import Foundation
import SQLite
import CDKSwiftOracc
import CloudKit
import os

extension NoteSQLDatabase {
    func createNote(_ noteToSave: Note, updateCloudKit: Bool = true) {
        // Persist the note to the local database
        do {
            _ = try db.run(notesTable.insert(
                textID <- noteToSave.id.description,
                note <- noteToSave.notes
            ))
        } catch {
            os_log("Unable to save note with ID %s to database: %s",
                   log: Log.NoteSQLite,
                   type: .error,
                   String(noteToSave.id),
                   error.localizedDescription)
        }
        
        if updateCloudKit {
            //Sync the note with CloudKit
            cloudKitDB?.saveNote(noteToSave) {[weak self] result in
                guard let noteSQLDB = self else {return}
                switch result {
                case .success(let record):
                    noteSQLDB.updateCloudKitMetadata(forNote: noteToSave, record: record)
                    os_log("Saved note %s to CloudKit",
                           log: Log.CloudKit,
                           type: .info,
                           String(noteToSave.id))
                    
                case .failure(let error):
                    os_log("Unable to save note with ID %s to CloudKit, error %s",
                           log: Log.CloudKit,
                           type: .error,
                           String(noteToSave.id),
                           error.localizedDescription)
                }
            }
        }
    
        let notification = Notification.noteAdded(id: noteToSave.id)
        NotificationCenter.default.post(notification)
        
        os_log("Saved note with ID %s to database",
               log: Log.NoteSQLite,
               type: .info,
               String(noteToSave.id))
        
    }
    
    func retrieveNote(forID id: TextID) -> Note? {
        let query = notesTable.select(note).filter(textID == String(id))
        guard let row = try? db.pluck(query) else {return nil}
        let notes = row[note]
        return Note(id: id, notes: notes)
    }
    
    func updateNote(_ updatedNote: Note, updateCloudKit: Bool = true) {
        // Persist the note to the local database
        let id = String(updatedNote.id)
        let query = notesTable.filter(textID == id)
        
        do {
            _ = try db.run(query.update(
                note <- updatedNote.notes
            ))
        } catch {
            os_log("Unable to update note with ID %s to database, error %s",
                   log: Log.NoteSQLite,
                   type: .error,
                   String(updatedNote.id),
                   error.localizedDescription)
        }
        
        
        if updateCloudKit {
            // Get Cloudkit saved metadata
            guard let row = try? db.pluck(query),
                let ckRecordData = row[ckSystemFields] else {return}
            
            let unarchiver = NSKeyedUnarchiver(forReadingWith: ckRecordData)
            unarchiver.requiresSecureCoding = true
            guard let record = CKRecord(coder: unarchiver) else {return}
            record["notes"] = updatedNote.notes
            
            //Sync the note with CloudKit
            cloudKitDB?.modifyRecord(record) { [unowned self] result in
                switch result {
                case .success(let record):
                    self.updateCloudKitMetadata(forNote: updatedNote, record: record)
                    os_log("Synced updated note %s with CloudKit",
                           log: Log.CloudKit,
                           type: .info,
                           String(updatedNote.id))
                    
                case .failure(let error):
                    os_log("Error updating note with ID %s, error %s",
                           log: Log.CloudKit,
                           type: .error,
                           String(updatedNote.id),
                           error.localizedDescription)
                }
            }
        }
        
        let notification = Notification.noteUpdated(id: updatedNote.id)
        NotificationCenter.default.post(notification)
        
        os_log("Updated note with ID %s in database",
               log: Log.NoteSQLite,
               type: .info,
               String(updatedNote.id))
    }

    func deleteNote(forID id: TextID, updateCloudKit: Bool = true) {
        let query = notesTable.filter(textID == String(id))
        
        do {
            try delete(query: query)
        } catch {
            os_log("Unable to delete note %s, error %s",
                   log: Log.NoteSQLite,
                   type: .error,
                   String(id),
                   error.localizedDescription)
        }
        
        let notification = Notification.noteDeleted(id: id)
        NotificationCenter.default.post(notification)
        
    }
    
    func deleteNote(withRecordID recordID: CKRecord.ID) throws {
        let recordData = recordID.securelyEncoded()
        let query = notesTable.filter(ckRecordID == recordData)
        guard let row = try db.pluck(query) else {
            os_log("Unable to find record for CloudKit ID %s",
                   log: Log.NoteSQLite,
                   type: .error,
                   String(describing: recordID))
            return
        }
        
        let id = row[textID]
        let textID = TextID(stringLiteral: id)
        try db.run(query.delete())
        
        let notification = Notification.noteDeleted(id: textID)
        NotificationCenter.default.post(notification)
        os_log("Deleted local note %s after it was deleted in CloudKit",
               log: Log.NoteSQLite,
               type: .info,
               String(textID))
    }
    
    func processCloudKitNote(from record: CKRecord) {
        guard let note = Note(ckRecord: record) else {return}
        os_log("Received updated note %s from CloudKit",
               log: Log.CloudKit,
               type: .info,
               String(note.id))
        
        if let _ = self.retrieveNote(forID: note.id) {
            updateNote(note, updateCloudKit: false)
        } else {
            createNote(note, updateCloudKit: false)
        }
        updateCloudKitMetadata(forNote: note, record: record)
    }
    
    func retrieveAllNotes() throws -> [Note]  {
        var notes = [Note]()
        for row in try db.prepare(notesTable) {
            notes.append(Note(id: TextID(stringLiteral: row[textID]), notes: row[note]))
        }
        return notes
    }
}
