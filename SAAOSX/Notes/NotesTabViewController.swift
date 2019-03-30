//
//  NotesTabViewController.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 24/05/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Cocoa
import CDKSwiftOracc

protocol NoteStore: AnyObject {
    var notes: [Note] {get}
    func setAnnotations(for textID: TextID)
}

protocol NoteDisplaying: AnyObject {
    func refreshTable()
}

class NotesTabViewController: NSTabViewController, NoteStore {
    @discardableResult static func new() -> NotesTabViewController? {
        let storyboard = NSStoryboard(name: "Notes", bundle: Bundle.main)
        guard let wc = storyboard.instantiateController(withIdentifier: "NotesWindowController") as? NSWindowController else {return nil}
        guard let splitView = wc.contentViewController as? NSSplitViewController else {return nil}
        guard let notesTabViewController = splitView.children[0] as? NotesTabViewController else {return nil}
        guard let annotationsViewController = splitView.children[1] as? AnnotationsViewController else {return nil}
        
        notesTabViewController.annotationsViewController = annotationsViewController
        notesTabViewController.cloudKitDB.retrieveAllNotes(completionHandler: {[weak notesTabViewController ] notes in
            notesTabViewController?.notes = Array(notes.values)
        })
        
        return notesTabViewController
    }

    
    var notes: [Note] = [] {
        didSet {
            children
                .compactMap{$0 as? NoteDisplaying}
                .forEach{$0.refreshTable()}
        }
    }
    
    weak var annotationsViewController: AnnotationsViewController!
    
    // This method displays annotations in the right half of the table view controller.
    func setAnnotations(for note: TextID) {
        let annotations = cloudKitDB.retrieveAnnotations(forTextID: note)
        annotationsViewController.annotations = annotations
        
    }
    
    @objc func search(_ sender: NSSearchField) {
        let searchText = sender.stringValue.lowercased()

    }
}



extension NotesTabViewController: NoteDelegate {
    func noteAdded(_ note: Note) {
        self.notes.append(note)
    }
    
    func noteRemoved(_ textID: TextID) {
        guard let idx = notes.firstIndex(where: {$0.id == textID}) else {return}
        notes.remove(at: idx)
    }
    
    func noteChanged(_ note: Note) {
        guard let idx = notes.firstIndex(where: {$0.id == note.id}) else {return}
        notes[idx] = note
    }
    
    func searchResultsUpdated(_ notes: [Note]) {
        return
    }
}
