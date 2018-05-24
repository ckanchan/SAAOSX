//
//  infoViewController.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 17/01/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Cocoa
import FirebaseAuth
import CDKSwiftOracc

class InfoViewController: NSViewController, NSTextFieldDelegate, TextNoteDisplaying {
    @IBOutlet weak var infoLabel: NSTextField!
    @IBOutlet weak var notesField: NSTextField!
    @IBOutlet weak var annotationsView: NSTableView!
    
    var textId: TextID? {
        didSet {
            if let user = self.user.user, let textID = self.textId {
                self.notesManager = FirebaseTextNoteManager(for: user, textID: textID, delegate: self)
                self.notesField.delegate = self
                self.notesField.isEditable = true
            }
        }
    }
    
    var notesManager: FirebaseTextNoteManager? {
        didSet {
            guard let nm = notesManager else {return}
            print(nm.listener)
        }
    }
    var annotations = [NodeReference: Note.Annotation]() {
        didSet {
            annotationsView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let user = self.user.user, let textID = self.textId {
            self.notesManager = FirebaseTextNoteManager(for: user, textID: textID, delegate: self)
            self.notesField.isEditable = true
            self.notesField.delegate = self
        } else {
            self.notesField.isEditable = false
            self.notesField.stringValue = "Sign in to save notes"
        }
    }
    
    func noteDidChange(_ note: Note) {
        self.notesField.stringValue = note.notes
        self.annotations = note.annotations
    }
    
    
    override func controlTextDidEndEditing(_ obj: Notification) {
        //TODO: - write note level set code
        guard let textId = self.textId else {return}
        
        let newNote = Note(id: textId, notes: notesField.stringValue, annotations: annotations)
        notesManager?.set(note: newNote)
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
