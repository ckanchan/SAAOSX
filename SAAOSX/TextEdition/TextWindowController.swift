//
//  TextWindowController.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 23/01/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Cocoa
import OraccJSONtoSwift

class TextWindowController: NSWindowController, NSSearchFieldDelegate {
    @IBOutlet weak var catalogueSearch: NSSearchField!
    @IBOutlet weak var bookmarksBtn: NSButton!
    
   @discardableResult static func new(_ entry: OraccCatalogEntry, strings: TextEditionStringContainer?, catalogue: CatalogueProvider?) -> TextWindowController? {
        let storyboard = NSStoryboard.init(name: NSStoryboard.Name(rawValue: "TextEdition"), bundle: Bundle.main)
        
        guard let textWindow = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("textWindow")) as? TextWindowController else { return nil}
        guard let textView = textWindow.contentViewController as? TextViewController else { return nil}
        
        if let strings = strings {
            textView.stringContainer = strings
        } else {
            guard let textEdition = try? textView.oracc.loadText(entry) else {return nil}
            textView.stringContainer = TextEditionStringContainer(textEdition)
        }
        
        textView.catalogueEntry = entry
        textView.catalogueController = catalogue
        textWindow.window?.title = "\(entry.displayName): \(entry.title)"
        textWindow.textViewController = [textView]
        
        textWindow.showWindow(nil)
        return textWindow
        
    }
    
    lazy var resultsPopover: NSPopover = {
        let popover = NSPopover()
        popover.behavior = .transient
        popover.contentViewController = self.quickSearchResultsViewController
        return popover
    }()
    
    lazy var quickSearchResultsViewController: QuickSearchResultsViewController = {
        let qsr = storyboard?.instantiateController(withIdentifier: .init("QuickSearchResultsViewController")) as! QuickSearchResultsViewController
        qsr.catalogueController = textViewController.first?.catalogueController
        qsr.textWindow = self
        self.textViewController.forEach { qsr.textViewController.addPointer(Unmanaged.passUnretained($0).toOpaque()) }
        return qsr
    }()
    
    var textViewController: [TextViewController] = []
    
    @IBAction func beginSearch(_ sender: Any) {
        catalogueSearch.becomeFirstResponder()
    }
    
    @IBAction func searchCatalogue(_ sender: NSSearchField) {
        let text = sender.stringValue
        if text != "" {
            
            if !resultsPopover.isShown {
            resultsPopover.show(relativeTo: catalogueSearch.visibleRect, of: catalogueSearch, preferredEdge: .maxY)
            }
            quickSearchResultsViewController.searchCatalogue(sender)
        }
    }
    
    func searchFieldDidStartSearching(_ sender: NSSearchField) {
        if !resultsPopover.isShown {
            resultsPopover.show(relativeTo: catalogueSearch.visibleRect, of: catalogueSearch, preferredEdge: .maxY)
        }
    }
    
    @IBAction func nextText(_ sender: NSMenuItem) {
        for controller in self.textViewController {
            controller.navigate(.right)
        }
    }
    
    @IBAction func previousText(_ sender: NSMenuItem) {
        for controller in self.textViewController {
            controller.navigate(.left)
        }
    }
    
}
