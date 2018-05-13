//
//  NotesViewController.swift
//  SAAiOS
//
//  Created by Chaitanya Kanchan on 12/05/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import UIKit
import Firebase

class NotesViewController: UIViewController, UITextViewDelegate {
    
    @discardableResult static func new(id: String, for user: User) -> NotesViewController {
        let dbController = DatabaseController(for: user)
        let notesViewController = NotesViewController()
        notesViewController.notesDBController = dbController
        notesViewController.id = id
        return notesViewController
    }
    
    var notesDBController: DatabaseController!
    lazy var textView = { return UITextView() }()
    var id: String = "" {
        didSet {
            self.getNotes()
        }
    }

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
    
    func getNotes() {
        guard let notesDBController = self.notesDBController else {return}
        DispatchQueue.global().async { [unowned self] in
            notesDBController.getNotes(for: self.id){ note in
                DispatchQueue.main.async {
                    self.textView.text = note.notes.joined(separator: "\n")
                }
            }
        }
    }
    
    func setNotes(){
        guard let notesDBController = self.notesDBController else {return}
        let note = Note(id: self.id, notes: [textView.text])
        notesDBController.set(note: note)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.setNotes()
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
