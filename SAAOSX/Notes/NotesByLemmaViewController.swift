//
//  NotesByLemmaViewController.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 26/05/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Cocoa

class NotesByLemmaViewController: NSViewController, NoteDisplaying {
    func refreshTable() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView?.reloadData()
        }
    }
    
    @IBOutlet weak var tableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
