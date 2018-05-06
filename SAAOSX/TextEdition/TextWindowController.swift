//
//  TextWindowController.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 23/01/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Cocoa
import CDKSwiftOracc

class TextWindowController: NSWindowController, NSSearchFieldDelegate {
    @IBOutlet weak var catalogueSearch: NSSearchField!
    @IBOutlet weak var bookmarksBtn: NSButton!
    
    static let defaultformattingPreferences: OraccTextEdition.FormattingPreferences = NSFont.systemFont(ofSize: NSFont.systemFontSize).makeDefaultPreferences()
    
    @discardableResult static func new(_ entry: OraccCatalogEntry, strings: TextEditionStringContainer?, catalogue: CatalogueProvider?, searchTerm: String? = nil) -> TextWindowController? {
        
        let panes = UserDefaults.standard.integer(forKey: PreferenceKey.textWindowNumber.rawValue)
        
        switch panes {
        case 0:
            let storyboard = NSStoryboard.init(name: NSStoryboard.Name(rawValue: "TextEdition"), bundle: Bundle.main)
            
            guard let textWindow = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("textWindow")) as? TextWindowController else { return nil}
            guard let textView = textWindow.contentViewController as? TextViewController else { return nil}
            
            if let strings = strings {
                strings.render(withPreferences: defaultformattingPreferences)
                textView.stringContainer = strings
            } else {
                guard let textEdition = try? textView.oracc.loadText(entry) else {return nil}
                textView.stringContainer = TextEditionStringContainer(textEdition)
            }
            
            textView.searchTerm = searchTerm
            textView.catalogueEntry = entry
            textView.catalogue = catalogue
            textWindow.window?.title = "\(entry.displayName): \(entry.title)"
            textWindow.textViewController = [textView]
            
            textWindow.showWindow(nil)
            return textWindow
            
        case 1:
            let storyboard = NSStoryboard.init(name: NSStoryboard.Name(rawValue: "TextEdition"), bundle: Bundle.main)
            guard let window = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("SplitTextWindow")) as? TextWindowController else { return nil}
            guard let splitTextViewController = window.contentViewController as? NSSplitViewController else { return nil}
            guard let controllers = splitTextViewController.childViewControllers as? [TextViewController] else {return nil}
            
            let stringContainer: TextEditionStringContainer
            if let str = strings {
                str.render(withPreferences: defaultformattingPreferences)
                stringContainer = str
            } else {
                guard let textEdition = try? controllers.first!.oracc.loadText(entry) else {return nil}
                stringContainer = TextEditionStringContainer(textEdition)
            }
            
            controllers.forEach{
                $0.searchTerm = searchTerm
                $0.stringContainer = stringContainer
                $0.catalogueEntry = entry
                $0.catalogue = catalogue
                $0.splitViewController = splitTextViewController
                window.textViewController.append($0)
            }
            
            controllers[1].textSelected.selectedSegment = 3
            window.contentViewController = splitTextViewController
            window.window?.title = "\(entry.displayName): \(entry.title)"
            window.window?.setFrame(NSRect(x: 640, y: 640, width: 1000, height: 800), display: false)
            window.catalogueSearch.stringValue = entry.title
            window.catalogueSearch.delegate = window
            window.showWindow(self)

            return window
            
        default:
            return nil
        }
    }
    
    lazy var resultsPopover: NSPopover = {
        let popover = NSPopover()
        popover.behavior = .transient
        popover.contentViewController = self.quickSearchResultsViewController
        return popover
    }()
    
    lazy var quickSearchResultsViewController: QuickSearchResultsViewController = {
        let qsr = storyboard?.instantiateController(withIdentifier: .init("QuickSearchResultsViewController")) as! QuickSearchResultsViewController
        qsr.catalogueController = textViewController.first?.catalogue
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
