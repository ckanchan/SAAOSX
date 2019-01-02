//
//  InfoViewController.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 17/01/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Cocoa
import CDKSwiftOracc

class InfoViewController: NSViewController, NSTextFieldDelegate {
    @IBOutlet weak var infoLabel: NSTextField!
    @IBOutlet weak var notesField: NSTextField!
    @IBOutlet weak var annotationsView: NSTableView!
    
    var textID: TextID? {
        didSet {
            self.notesField.isEditable = false
            if !cloudKitDB.userIsLoggedIn {
                self.notesField.stringValue = "Sign in to save notes"
            } else {
                guard let textID = self.textID else {return}
                var note: Note? = nil
                cloudKitDB.retrieveNotes(forTextID: textID,
                                         forRetrievedNote: {
                                            note = $0
                                            
                },
                                         onCompletion: { [weak notesField = self.notesField] _ in
                                            DispatchQueue.main.async {
                                                guard let notesField = notesField else {return}
                                                if let note = note {
                                                    notesField.stringValue = note.notes
                                                    self.notesField.isEditable = true
                                                } else {
                                                    notesField.placeholderString = "Type notes here..."
                                                    notesField.isEditable = true
                                                }
                                            }
                })
            }
        }
    }
    
    var annotations = [NodeReference: Annotation]() {
        didSet {
            annotationsView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.notesField.delegate = self
    }

    func controlTextDidEndEditing(_ obj: Notification) {
        //TODO: - write note level set code
        guard let textId = self.textID else {return}
        
        let newNote = Note(id: textId, notes: notesField.stringValue)

        //TODO: - Update note code
        cloudKitDB.saveNote(newNote)
        
    }
}

extension InfoViewController: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.annotations.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let view = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView else {return nil}
        
        let annotations = Array(self.annotations.values)
        let annotation = annotations[row]
        
        if tableColumn?.identifier.rawValue == "reference" {
            view.textField?.stringValue = annotation.nodeReference.description
        } else if tableColumn?.identifier.rawValue == "annotation" {
            view.textField?.stringValue = annotation.annotation
        }


        return view
    }
}
