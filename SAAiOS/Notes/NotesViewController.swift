//
//  NotesViewController.swift
//  SAAiOS
//
//  Created by Chaitanya Kanchan on 12/05/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import UIKit

class NotesViewController: UIViewController, UITextViewDelegate {
    lazy var notesDBController = DatabaseController()
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
        DispatchQueue.global().async { [unowned self] in
            self.notesDBController.getNotes(for: self.id){ note in
                DispatchQueue.main.async {
                    self.textView.text = note.notes.joined(separator: "\n")
                }
            }
        }
    }
    
    func setNotes(){
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
