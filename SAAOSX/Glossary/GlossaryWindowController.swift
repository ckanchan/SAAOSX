//
//  GlossaryWindowController.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 20/01/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Cocoa

class GlossaryWindowController: NSWindowController {
    @IBOutlet weak var searchField: NSSearchField!

    @discardableResult static func new(_ sender: Any) -> GlossaryWindowController? {
        let storyboard = NSStoryboard.init(name: "Main", bundle: Bundle.main)

        guard let glossaryWindow = storyboard.instantiateController(withIdentifier: "GlossaryWindow") as? GlossaryWindowController else {return nil}
        guard let splitViewController = glossaryWindow.contentViewController as? GlossarySplitViewController else {return nil}

        splitViewController.searchField = glossaryWindow.searchField
        guard let glossaryListViewController = splitViewController.children.first as? GlossaryListViewController else {return nil}

        glossaryListViewController.definitionViewController = splitViewController.children.last as? GlossaryEntryViewController
        glossaryWindow.window?.title = "Glossary"
        glossaryWindow.showWindow(sender)
        return glossaryWindow
    }

    @objc static func searchField(_ sender: NSMenuItem) {
        let searchString = "cf:\(sender.title)"
        if let window = NSApp.windows.first(where: {$0.title == "Glossary"}) {
            let vw = window.contentViewController! as! GlossarySplitViewController
            vw.searchField?.stringValue = searchString
            window.makeKeyAndOrderFront(sender)
            vw.performFindPanelAction(sender)
            let glvc = vw.children.first as! GlossaryListViewController
            glvc.search(vw.searchField!)

            guard glvc.glossaryTableView.numberOfRows != 0 else {return}
            let idx = IndexSet([0])
            glvc.glossaryTableView.selectRowIndexes(idx, byExtendingSelection: false)
        } else {
            let window = GlossaryWindowController.new(self)
            window?.searchField.stringValue = searchString
            window?.window?.makeKeyAndOrderFront(sender)
            let glvc = window?.contentViewController?.children.first as! GlossaryListViewController
            glvc.search(window!.searchField)

            guard glvc.glossaryTableView.numberOfRows != 0 else {return}
            let idx = IndexSet([0])
            glvc.glossaryTableView.selectRowIndexes(idx, byExtendingSelection: false)
        }
    }
}
