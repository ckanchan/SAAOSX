//
//  NotesViewController.swift
//  SAAiOS
//
//  Created by Chaitanya Kanchan on 12/05/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import UIKit
import Firebase
import CDKSwiftOracc

class NotesViewController: UIViewController, UITextViewDelegate {
    
    @discardableResult static func new(id: TextID, for user: User) -> NotesViewController {
        let notesViewController = NotesViewController()
        let dbController = FirebaseTextNoteManager(for: user, textID: id, delegate: notesViewController)
        notesViewController.notesDBController = dbController
        return notesViewController
    }
    
    var notesDBController: FirebaseTextNoteManager!
    lazy var textView = { return UITextView() }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = textView
        textView.isEditable = true
        textView.delegate = self
        registerThemeNotifications()
    }
    
    deinit {
        deregisterThemeNotifications()
    }
    
    
    // WARNING this has an empty annotations dictionary!
    func setNotes(){
        guard let notesDBController = self.notesDBController else {return}
        let note = Note(id: notesDBController.textID, notes: textView.text, annotations: [:])
        notesDBController.set(note: note)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.setNotes()
    }
}

extension NotesViewController: TextNoteDisplaying {
    func noteDidChange(_ note: Note) {
        self.textView.text = note.notes
    }
}

extension NotesViewController: Themeable {
    func enableDarkMode() {
        textView.enableDarkMode()
    }
    
    func disableDarkMode() {
        textView.disableDarkMode()
    }
    
}
