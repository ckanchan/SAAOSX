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
    
    var annotations = [Annotation]() {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.annotationsView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.notesField.delegate = self
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(annotationsDidChange),
                                               name: .annotationsChangedForText,
                                               object: nil)
    }
    
    func controlTextDidEndEditing(_ obj: Notification) {
        guard let textId = self.textID else {return}
        if notesField.stringValue.isEmpty {
            notesDB.deleteNote(forID: textId)
        } else {
            let newNote = Note(id: textId, notes: notesField.stringValue)
            if let oldNote = notesDB.retrieveNote(forID: textId) {
                guard oldNote.notes != newNote.notes else {return}
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
        
        let annotation = annotations[row]
        
        if tableColumn?.identifier.rawValue == "reference" {
            view.textField?.stringValue = annotation.nodeReference.description
        } else if tableColumn?.identifier.rawValue == "annotation" {
            view.textField?.stringValue = annotation.annotation
        }


        return view
    }
}

@objc extension InfoViewController {
    func annotationsDidChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: TextID],
            let changedText = userInfo["textID"],
            let textID = self.textID,
            textID == changedText else {return}
        
        self.annotations = notesDB.retrieveAnnotations(forID: textID)
    }
}
