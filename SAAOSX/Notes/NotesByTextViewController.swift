//
//  NotesByTextViewController.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 26/05/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Cocoa

class NotesByTextViewController: NSViewController, NoteDisplaying {
    func refreshTable() {
        tableView.reloadData()
    }
    
    @IBOutlet weak var tableView: NSTableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    
    unowned var noteStore: NoteStore!
    var currentlySelectedIndex: Int? = nil {
        didSet {
            if let idx = currentlySelectedIndex {
                noteStore.setAnnotations(for: noteStore.notes[idx].id)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.noteStore = (parent as! NoteStore)
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        tableView.reloadData()
    }
    
}

extension NotesByTextViewController: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return noteStore.notes.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let view = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView else {return nil}
        let note = noteStore.notes[row]
        
        if tableColumn?.identifier.rawValue == "id" {
            view.textField?.stringValue = note.id.description
        } else if tableColumn?.identifier.rawValue == "note" {
            view.textField?.stringValue = note.notes
        }

        return view
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard tableView.selectedRow != -1,
            tableView.selectedRow < noteStore.notes.count else {
                self.currentlySelectedIndex = nil
                return
        }
        self.currentlySelectedIndex = tableView.selectedRow
    }
}
