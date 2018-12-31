//
//  infoViewController.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 17/01/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Cocoa
import CDKSwiftOracc

class InfoViewController: NSViewController, NSTextFieldDelegate, TextNoteDisplaying {
    @IBOutlet weak var infoLabel: NSTextField!
    @IBOutlet weak var notesField: NSTextField!
    @IBOutlet weak var annotationsView: NSTableView!
    
    var textId: TextID?
    
    var annotations = [NodeReference: Note.Annotation]() {
        didSet {
            annotationsView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
            self.notesField.isEditable = false
            self.notesField.stringValue = "Sign in to save notes"
    }
    
    func noteDidChange(_ note: Note) {
        self.notesField.stringValue = note.notes
        self.annotations = note.annotations
    }
    
    
    func controlTextDidEndEditing(_ obj: Notification) {
        //TODO: - write note level set code
        guard let textId = self.textId else {return}
        
        let newNote = Note(id: textId, notes: notesField.stringValue, annotations: annotations)

        //TODO: - Update note code
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
