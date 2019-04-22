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
        notesTabViewController.notes = (try? notesTabViewController.notesDB.retrieveAllNotes()) ?? []
        
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
        let annotations = notesDB.retrieveAnnotations(forID: note)
        annotationsViewController.annotations = annotations
        
    }
    
    @objc func search(_ sender: NSSearchField) {
        let searchText = sender.stringValue.lowercased()

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(noteWasAdded),
                                               name: .noteAdded,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(noteWasUpdated),
                                               name: .noteUpdated,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(noteWasDeleted),
                                               name: .noteDeleted,
                                               object: nil)
    }
}



@objc extension NotesTabViewController {
    func noteWasAdded(_ notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: TextID],
            let textID = userInfo["textID"],
            let note = notesDB.retrieveNote(forID: textID) else {return}
        
        self.notes.append(note)
    }
    
    func noteWasUpdated(_ notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: TextID],
            let textID = userInfo["textID"],
            let note = notesDB.retrieveNote(forID: textID),
            let idx = notes.firstIndex(where: {$0.id == note.id}) else {return}
        
        notes[idx] = note
    }
    
    func noteWasDeleted(_ notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: TextID],
            let textID = userInfo["textID"],
            let idx = notes.firstIndex(where: {$0.id == textID}) else {return}
        
        notes.remove(at: idx)
    }

}
