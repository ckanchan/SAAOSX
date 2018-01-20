//
//  GlossaryListViewController.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 20/01/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Cocoa
import OraccJSONtoSwift

class GlossaryListViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    @IBOutlet weak var glossaryTableView: NSTableView!
    var glossaryEntries: [GlossaryEntry]?
    var filteredGlossary: [GlossaryEntry] = []
    var searchBarIsEmpty: Bool = true
    var definitionViewController: GlossaryEntryViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override func viewWillAppear() {
        if glossaryEntries != nil {
            glossaryTableView.reloadData()
        }
        
        
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if !searchBarIsEmpty {
            return filteredGlossary.count
        }
        return glossaryEntries?.count ?? 0
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let view = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView else {return nil}
        
        let glossaryEntry: GlossaryEntry
        
        if !searchBarIsEmpty {
            glossaryEntry = filteredGlossary[row]
        } else {
            guard let g = glossaryEntries?[row] else {return nil}
            glossaryEntry = g
        }
        
        guard let tableColumn = tableColumn else {return nil}
        switch tableColumn.identifier.rawValue {
        case "CitationForm":
            view.textField?.stringValue = glossaryEntry.citationForm
        case "GuideWord":
            view.textField?.stringValue = glossaryEntry.guideWord ?? "n/a"
        default:
            break
        }
        
        return view
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let glossaryEntry: GlossaryEntry
        
        if !searchBarIsEmpty {
            glossaryEntry = filteredGlossary[glossaryTableView.selectedRow]
        } else {
            guard let g = glossaryEntries?[glossaryTableView.selectedRow] else {return}
            glossaryEntry = g
        }
        
        if let definitionViewController = definitionViewController {
            definitionViewController.glossaryEntry = glossaryEntry
        }
    }
    
    
    // MARK :- Search functions
    func filterContentForSearchText(_ searchText: String) {
        guard let entries = self.glossaryEntries else { return }
        filteredGlossary = entries.filter {
            $0.description.lowercased().contains(searchText.lowercased())
        }
    }
    
    @IBAction func search(_ sender: NSSearchField) {
        if !sender.stringValue.isEmpty {
            searchBarIsEmpty = false
            filterContentForSearchText(sender.stringValue)
            glossaryTableView.reloadData()
        } else {
            searchBarIsEmpty = true
            glossaryTableView.reloadData()
        }
    }
    
    
}
