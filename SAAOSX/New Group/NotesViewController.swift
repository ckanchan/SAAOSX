//
//  NotesViewController.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 24/05/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Cocoa
import FirebaseAuth

import CDKSwiftOracc

class NotesViewController: NSViewController {
    
    @discardableResult static func new(for user: User) -> NotesViewController? {
        let storyboard = NSStoryboard.init(name: NSStoryboard.Name("Notes"), bundle: Bundle.main)
        guard let wc = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("NotesWindowController")) as? NSWindowController else {return nil}
        guard let vc = wc.contentViewController as? NotesViewController else {return nil}
        let notesManager = FirebaseGlobalNotesManager(for: user)
        vc.notesManager = notesManager
        notesManager.delegate = vc
        return vc
    }

    var notesManager: FirebaseGlobalNotesManager! {
        didSet {
            notesManager.getAllNotes { notes in
                self.notes =  notes.values.sorted {$0.id.description < $1.id.description}

            }
        }
    }
    
    var notes: [Note] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var currentlySelectedIndex: Int? = nil {
        didSet {
            if let index = currentlySelectedIndex {
                self.annotations = Array(notes[index].annotations.values)
            } else {
                self.annotations = nil
            }
        }
    }
    
    var annotations: [Note.Annotation]? = nil {
        didSet {
            collectionView.reloadData()
        }
    }

    @IBOutlet weak var collectionView: NSCollectionView! {
        didSet {
            collectionView.dataSource = self

        }
    }
    
    @IBOutlet weak var tableView: NSTableView! {
        didSet {
            self.tableView.delegate = self
            self.tableView.dataSource = self
        }
    }
}

extension NotesViewController: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let view = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView else {return nil}
        let note = notes[row]
        
        if tableColumn?.identifier.rawValue == "id" {
            view.textField?.stringValue = note.id.description
        } else if tableColumn?.identifier.rawValue == "note" {
            view.textField?.stringValue = note.notes
        } else if tableColumn?.identifier.rawValue == "tags" {
            if !note.annotations.isEmpty {
                var tags = Set<String>()
                for annotation in note.annotations.values {
                    tags.formUnion(annotation.tags)
                }
                
                view.textField?.stringValue = tags.joined(separator: "; ")
            }
        }
        return view
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard tableView.selectedRow != -1,
            tableView.selectedRow < notes.count else {
                self.currentlySelectedIndex = nil
                return
        }
        self.currentlySelectedIndex = tableView.selectedRow
    }
}

extension NotesViewController: GlobalNoteShowing {
    func noteAdded(_ note: Note) {
        self.notes.append(note)
    }
    
    func noteRemoved(_ textID: TextID) {
        guard let idx = notes.index(where: {$0.id == textID}) else {return}
        notes.remove(at: idx)
    }
    
    func noteChanged(_ note: Note) {
        guard let idx = notes.index(where: {$0.id == note.id}) else {return}
        notes[idx] = note
    }
}

extension NotesViewController: NSCollectionViewDataSource {
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        if self.currentlySelectedIndex != nil {
            return 1
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        if let selectedText = self.currentlySelectedIndex {
            return notes[selectedText].annotations.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Annotation"), for: indexPath)
        
        if let annotations = self.annotations {
            guard let annotationView = item as? Annotation else {return item}
            annotationView.annotation = annotations[indexPath.item]
            return item
        } else {
            return item
        }
    }
}
