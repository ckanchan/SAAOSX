//
//  ProjectListViewController.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 14/01/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Cocoa
import OraccJSONtoSwift

class ProjectListViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

    @IBOutlet weak var catalogueEntryView: NSTableView!
    
    lazy var projectList: [OraccProjectEntry] = {
        return try! appDelegate.oraccInterface.getOraccProjects()
    }()
    
    var catalogue: OraccCatalog?
    var texts: [OraccCatalogEntry]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCatalogue("saa01")
    }
    
    func loadCatalogue(_ s: String) {
        let cat = projectList.first{$0.pathname.contains(s)}
        catalogue = try! appDelegate.oraccInterface.loadCatalogue(cat!)
        texts = Array(catalogue!.members.values)
        texts?.sort{$0.displayName < $1.displayName}
        catalogueEntryView.reloadData()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return texts?.count ?? 0
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let vw = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView else { return nil}
        
        
        if tableColumn?.identifier.rawValue == "saaNumber" {
        vw.textField?.stringValue = texts![row].displayName
        } else if tableColumn?.identifier.rawValue == "title"{
            vw.textField?.stringValue = texts![row].title
        } else if tableColumn?.identifier.rawValue == "sender" {
            vw.textField?.stringValue = texts![row].ancientAuthor ?? "(unassigned)"
        }
        
        return vw
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard let splitViewController = parent as? NSSplitViewController else { return }
        
        if let editionView = splitViewController.childViewControllers[1] as? EditionViewController {
            let text = texts![catalogueEntryView.selectedRow]
            self.title = text.title
            editionView.catalogueData = text
            editionView.text = try? appDelegate.oraccInterface.loadText(text.id, inCatalogue: self.catalogue!)
        }
        
    }
    
}
