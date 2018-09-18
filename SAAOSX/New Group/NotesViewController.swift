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

protocol NoteStore: AnyObject {
    var notes: [Note] {get}
    func setAnnotations(for note: Note)
}

protocol NoteDisplaying: AnyObject {
    func refreshTable()
}

class NotesTabViewController: NSTabViewController, NoteStore {
    @discardableResult static func new(for user: User) -> NotesTabViewController? {
        let storyboard = NSStoryboard.init(name: NSStoryboard.Name("Notes"), bundle: Bundle.main)
        guard let wc = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("NotesWindowController")) as? NSWindowController else {return nil}
        guard let splitView = wc.contentViewController as? NSSplitViewController else {return nil}
        guard let notesViewController = splitView.childViewControllers[0] as? NotesTabViewController else {return nil}
        guard let annotationsViewController = splitView.childViewControllers[1] as? AnnotationsViewController else {return nil}
        let notesManager = FirebaseGlobalNotesManager(for: user)
        notesViewController.notesManager = notesManager
        notesManager.delegate = notesViewController
        
        notesViewController.annotationsViewController = annotationsViewController
        
        return notesViewController
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
            childViewControllers
                .compactMap{$0 as? NoteDisplaying}
                .forEach{$0.refreshTable()}
        }
    }
    
    weak var annotationsViewController: AnnotationsViewController!
    
    func setAnnotations(for note: Note) {
        annotationsViewController.annotations = Array(note.annotations.values)
    }
    
    @objc func search(_ sender: NSSearchField) {
        let searchText = sender.stringValue.lowercased()
        notesManager.searchDatabase(for: searchText)
    }
    
    @objc func searchLocal(_ sender: NSSearchField) {
        let searchText = sender.stringValue.lowercased()
        let annotations: [Note.Annotation] = self.notes.reduce([Note.Annotation]()){ array, note in
            let subannotations = Array(note.annotations.values)
            return array + subannotations
        }
        let results = annotations.filter{$0.normalisation == searchText}
        
        annotationsViewController.annotations = results
    }
}



extension NotesTabViewController: NoteDelegate {
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
    
    func searchResultsUpdated(_ notes: [Note]) {
        return
    }
}
