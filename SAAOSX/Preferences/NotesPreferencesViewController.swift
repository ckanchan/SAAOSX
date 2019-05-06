//
//  NotesPreferencesViewController.swift
//  SAAo-SX
//
//  Created by Chaitanya Kanchan on 06/05/2019.
//  Copyright © 2019 Chaitanya Kanchan. All rights reserved.
//

import Cocoa
import CloudKit

class NotesPreferencesViewController: NSViewController {
    @IBAction func exportAllNotes(_ sender: Any) {
        guard let catalogue = sqlite else {return}
        let noteExporter = NoteExporter(catalogue: catalogue, noteDB: notesDB)
        
        do {
            guard let data = try noteExporter.exportAllNotes(to: .MicrosoftWord) else {return}
            
            let panel = NSSavePanel()
            panel.allowedFileTypes = ["docx"]
            panel.begin { response in
                guard response == .OK,
                    let url = panel.url else {return}
                
                do {
                    try data.write(to: url)
                } catch {
                    print(error.localizedDescription)
                }
            }
        } catch {
            let alert = NSAlert(error: error)
            alert.runModal()
        }
    }
    
    @IBAction func deleteCloudKitData(_ sender: Any) {
        func handleError(_ error: Error) {
            let alert = NSAlert(error: error)
            DispatchQueue.main.async {
                alert.runModal()
            }
        }
        
        let zoneHandler = {(result: Result<[CKRecordZone.ID], Error>) in
            if case let Result.failure(error) = result {
                handleError(error)
            }}
        
        let subscriptionHandler = {(result: Result<CKSubscription.ID, Error>) in
            if case let Result.failure(error) = result {
                handleError(error)
            }}
        
        
        notesDB.cloudKitDB?.deleteAllCloudKitData(zoneDeletionHandler: zoneHandler,
                                                  subscriptionDeletionHandler: subscriptionHandler)
    }
}
