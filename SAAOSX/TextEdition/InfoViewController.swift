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
            if let id = textID {
                if let note = notesDB.retrieveNote(forID: id) {
                    notesField.stringValue = note.notes
                } else {
                    notesField.placeholderString = "Type note here..."
                }
            } else {
                notesField.isEditable = false
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
        guard let textId = self.textID else {return}
        if notesField.stringValue.isEmpty {
            notesDB.deleteNote(forID: textId)
        } else {
            let newNote = Note(id: textId, notes: notesField.stringValue)
            if let _ = notesDB.retrieveNote(forID: textId) {
                notesDB.updateNote(newNote)
            } else {
                notesDB.createNote(newNote)
            }
        }
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
