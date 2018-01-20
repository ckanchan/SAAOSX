//
//  ProjectListViewController.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 14/01/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Cocoa
import OraccJSONtoSwift
import QuartzCore

class ProjectListViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

    @IBOutlet weak var catalogueEntryView: NSTableView!
    
    lazy var projectList: [OraccProjectEntry] = {
        return try! appDelegate.oraccInterface.getOraccProjects()
    }()
    
    lazy var windowController: ProjectListWindowController = {
        return self.view.window?.windowController as! ProjectListWindowController
    }()
    
    lazy var infoSidebar: InfoSideBarViewController = {
        let split = self.parent! as! NSSplitViewController
        return split.childViewControllers.last! as! InfoSideBarViewController
    }()
    
    var catalogue: OraccCatalog?
    var texts: [OraccCatalogEntry]?
    var selectedText: OraccCatalogEntry? = nil

    
    override func viewDidAppear() {
        loadCatalogue("saa01")
        windowController.setTitle(self.catalogue?.project ?? "SAAoSX")
        catalogueEntryView.doubleAction = #selector(doubleClickLoadText(_:))
    }
    
  
    
    func loadCatalogue(_ s: String) {
        self.windowController.loadingIndicator.startAnimation(nil)
        DispatchQueue.global(qos: .userInitiated).async {
            self.searchBarIsEmpty = true
            self.selectedText = nil
            self.filteredTexts = []
            let cat = self.projectList.first{$0.pathname.contains(s)}
            self.catalogue = try! self.appDelegate.oraccInterface.loadCatalogue(cat!)
            self.texts = Array(self.catalogue!.members.values)
            self.texts?.sort{$0.displayName < $1.displayName}
            DispatchQueue.main.async {
                self.catalogueEntryView.reloadData()
                self.windowController.loadingIndicator.stopAnimation(nil)
                self.windowController.setTitle(self.catalogue?.project ?? "SAAoSX")
            }
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if !searchBarIsEmpty {
            return filteredTexts.count
        }
        return texts?.count ?? 0
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let vw = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView else { return nil }
        
        let text: OraccCatalogEntry
        if !searchBarIsEmpty {
            text = filteredTexts[row]
        } else {
            guard let txt = texts?[row] else { return nil }
            text = txt
        }
        
        if tableColumn?.identifier.rawValue == "saaNumber" {
        vw.textField?.stringValue = text.displayName
        } else if tableColumn?.identifier.rawValue == "title"{
            vw.textField?.stringValue = text.title
        } else if tableColumn?.identifier.rawValue == "sender" {
            vw.textField?.stringValue = text.ancientAuthor ?? "(unassigned)"
        }
        
        return vw
    }
    
    func loadTextWindow(withText textEdition: OraccTextEdition, catalogueEntry: OraccCatalogEntry) {
            guard let window = self.storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("textWindow")) as? NSWindowController else { return }
            guard let textView = window.contentViewController as? TextViewController else { return }
            
            window.window?.title = "\(catalogueEntry.displayName): \(catalogueEntry.title)"
            textView.textEdition = textEdition
            textView.catalogueEntry = catalogueEntry
                window.showWindow(nil)
    }
    
    func loadSplitTextWindow(withText textEdition: OraccTextEdition, catalogueEntry: OraccCatalogEntry){
        guard let splitTextWindow = self.storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("splitTextView")) as? NSSplitViewController else {return}
        guard let controllers = splitTextWindow.childViewControllers as? [TextViewController] else {return}
        controllers.forEach{
            $0.textEdition = textEdition
            $0.catalogueEntry = catalogueEntry
        }
        
        guard let window = self.storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("textWindow")) as? NSWindowController else { return }
        window.contentViewController = splitTextWindow
        window.window?.title = "\(catalogueEntry.displayName): \(catalogueEntry.title)"
        window.window?.setFrame(NSRect(x: 640, y: 640, width: 1000, height: 800), display: true)
        window.showWindow(nil)

    }
    
    func callLoadTextWindow(_ textEntry: OraccCatalogEntry){
        DispatchQueue.global(qos: .userInitiated).async {
            if let textEdition = try? self.oracc.loadText(textEntry) {
                DispatchQueue.main.async {
                    //self.loadTextWindow(withText: textEdition, catalogueEntry: textEntry)
                    self.loadSplitTextWindow(withText: textEdition, catalogueEntry: textEntry)
                    self.windowController.loadingIndicator.stopAnimation(nil)
                }
            } else {
                DispatchQueue.main.async {
                    self.windowController.loadingIndicator.stopAnimation(nil)
                }
            }
        }
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if !searchBarIsEmpty {
            selectedText = filteredTexts[catalogueEntryView.selectedRow]
        } else {
            guard let txt = texts?[catalogueEntryView.selectedRow] else { return  }
            selectedText = txt
        }
        
        infoSidebar.infoLabel.stringValue = selectedText?.description ?? "No text selected"
        
    }
    
    override func keyUp(with event: NSEvent) {
        if (event.keyCode == 36) {
            if let text = selectedText {
                windowController.loadingIndicator.startAnimation(nil)
                callLoadTextWindow(text)
            }
        } else {
            super.keyUp(with: event)
        }
    }
    
    @objc func doubleClickLoadText(_ sender: Any){
        if let text = selectedText {
            windowController.loadingIndicator.startAnimation(nil)
            callLoadTextWindow(text)
        }
    }
    
    

    // MARK :- Search functions
    var filteredTexts: [OraccCatalogEntry] = []
    var searchBarIsEmpty: Bool = true
    
    
    func filterContentForSearchText(_ searchText: String){
        guard let texts = self.texts else { return }
        filteredTexts = texts.filter {
            $0.description.lowercased().contains(searchText.lowercased())
        }
    }
    
    @IBAction func search(_ sender: NSSearchFieldCell) {
        if !sender.stringValue.isEmpty {
            searchBarIsEmpty = false
            filterContentForSearchText(sender.stringValue)
            catalogueEntryView.reloadData()
        } else {
            searchBarIsEmpty = true
            catalogueEntryView.reloadData()
        }
    }
    
    @IBAction func viewOnline(_ sender: Any) {
        if let text = selectedText {
            var baseURL = URL(string: "http://oracc.org")!
            baseURL.appendPathComponent(text.project)
            baseURL.appendPathComponent(text.id)
            baseURL.appendPathComponent("html")
            NSWorkspace.shared.open(baseURL)
        }
    }

    @IBAction func newProjectListWindow(_ sender: Any) {
        guard let newWindow = storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("ProjectListWindow")) as? NSWindowController else {return}
        newWindow.showWindow(nil)
    }
    
    @IBAction func newDocument(_ sender: Any){
        newProjectListWindow(self)
    }
    
    @IBAction func glossary(_ sender: Any){
        guard catalogue != nil else {return}
        
        var glossary: OraccGlossary?
        self.windowController.loadingIndicator.startAnimation(nil)
        DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
            glossary = try? self.oracc.loadGlossary(.neoAssyrian, inCatalogue: self.catalogue!)
            
            DispatchQueue.main.async {
                if let glossary = glossary {
                    guard let glossaryWindow = self.storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("GlossaryWindow")) as? GlossaryWindowController else {return}
                    guard let splitViewController = glossaryWindow.contentViewController as? GlossarySplitViewController else {return}
                    
                    splitViewController.searchField = glossaryWindow.searchField
                    guard let glossaryListViewController = splitViewController.childViewControllers.first as? GlossaryListViewController else {return}
                    
                    glossaryListViewController.glossaryEntries = glossary.entries
                    glossaryListViewController.definitionViewController = splitViewController.childViewControllers.last as? GlossaryEntryViewController
                    glossaryWindow.showWindow(nil)
                }
                self.windowController.loadingIndicator.stopAnimation(nil)
            }
        }
    }
}
