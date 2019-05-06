//
//  NotesByTagViewController.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 26/05/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Cocoa

class NotesByTagViewController: NSViewController, NoteDisplaying {
    func refreshTable() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView?.reloadData()
        }
    }
    
    @IBOutlet weak var tableView: NSTableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    
    var tags: [String] = [] {
        didSet {
            tags.sort()
            DispatchQueue.main.async { [weak self] in
                self?.tableView?.reloadData()
            }
        }
    }
    
    unowned var noteStore: NoteStore!
    var currentlySelectedIndex: Int? = nil {
        didSet {
            if let idx = currentlySelectedIndex {
                noteStore.setAnnotations(for: tags[idx])
            }
        }
    }
    
    @objc func tagsDidChange(_ notification: Notification) {
        tags = Array(notesDB.tagSet?.tags ?? Set<Tag>())
    }
    
    @objc func annotationsDidChange(_ notification: Notification) {
        if let selectedIndex = currentlySelectedIndex {
            guard tags.count > selectedIndex else {
                currentlySelectedIndex = nil
                return
            }
            noteStore.setAnnotations(for: tags[selectedIndex])
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        tags = Array(notesDB.tagSet?.tags ?? Set<Tag>())
        self.noteStore = (parent as! NoteStore)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(tagsDidChange),
                                               name: .tagsDidChange,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(annotationsDidChange), name: .annotationsChangedForText,
                                               object: nil)
        
    }
}

extension NotesByTagViewController: NSTableViewDataSource, NSTableViewDelegate {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return notesDB.tagSet?.tags.count ?? 0
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let view = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView else {return nil}
        if tableColumn?.identifier.rawValue == "Tag" {
            view.textField?.stringValue = tags[row]
        }
        return view
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard tableView.selectedRow != -1,
            tableView.selectedRow < tags.count else {
            self.currentlySelectedIndex = nil
            return
        }
        
        self.currentlySelectedIndex = tableView.selectedRow
    }
    
}
