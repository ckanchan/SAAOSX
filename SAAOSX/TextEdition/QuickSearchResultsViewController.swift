//
//  QuickSearchResultsViewController.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 24/01/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Cocoa
import OraccJSONtoSwift

class QuickSearchResultsViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    @IBOutlet weak var ResultsTableView: NSTableView!
    
    weak var catalogueController: CatalogueProvider?
    weak var textWindow: TextWindowController?
    var textViewController: NSPointerArray = NSPointerArray.weakObjects()
    
    var results: [OraccCatalogEntry] = []
    var selectedText: OraccCatalogEntry? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ResultsTableView.doubleAction = #selector(doubleClickLoadText(_:))
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        self.results = []
        self.selectedText = nil
        textWindow?.resultsPopover.close()
    }
    
    @IBAction func searchCatalogue(_ sender: NSSearchField){
        let filterText = sender.stringValue
        guard let results = catalogueController?.texts.filter({$0.description.lowercased().contains(filterText.lowercased())}) else {return}
        self.results = results
        self.view.window?.windowController?.showWindow(self)
        
        self.ResultsTableView.reloadData()
    }
    
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let vw = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView else { return nil }
        
        let text = results[row]

        if tableColumn?.identifier.rawValue == "saaNumber" {
            vw.textField?.stringValue = text.displayName
        } else if tableColumn?.identifier.rawValue == "title"{
            vw.textField?.stringValue = text.title
        }
        
        return vw
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard ResultsTableView.selectedRow != -1 else {
        self.view.window?.close()
        return
        }
        let txt = results[ResultsTableView.selectedRow]
        selectedText = txt
    }
    
    @objc func doubleClickLoadText(_ sender: Any){
        guard ResultsTableView.selectedRow != -1 else {
            self.view.window?.close()
            return
        }
        
        if let text = selectedText {
            loadNewText(text)
        } else {
            print("No text available")
            let window = storyboard?.instantiateController(withIdentifier: .init("alert")) as! NSWindowController
            window.showWindow(nil)
        }
    }
    
    func loadNewText(_ entry: OraccCatalogEntry){
        DispatchQueue.global(qos: .userInitiated).async {
            if let text = try? self.oracc.loadText(entry){
                DispatchQueue.main.async {
                    let stringContainer = TextEditionStringContainer(text)
                    
                    for controller in self.textViewController.allObjects as! [TextViewController] {
                        controller.catalogueEntry = entry
                        controller.stringContainer = stringContainer
                        controller.setText(self)
                        controller.windowController?.window?.title = "\(entry.displayName): \(entry.title)"
                    }
                    self.textWindow?.resultsPopover.close()
                    
                }
            }
        }
    }
}
