//
//  TextWindowController.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 23/01/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Cocoa

class TextWindowController: NSWindowController, NSSearchFieldDelegate {
    @IBOutlet weak var catalogueSearch: NSSearchField!
    
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
    
 
}
