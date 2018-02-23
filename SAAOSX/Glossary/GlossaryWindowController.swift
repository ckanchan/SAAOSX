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
    
    
    static func new(_ sender: Any){
        let storyboard = NSStoryboard.init(name: NSStoryboard.Name(rawValue: "Main"), bundle: Bundle.main)
        
        guard let glossaryWindow = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("GlossaryWindow")) as? GlossaryWindowController else {return}
        guard let splitViewController = glossaryWindow.contentViewController as? GlossarySplitViewController else {return}
        
        splitViewController.searchField = glossaryWindow.searchField
        guard let glossaryListViewController = splitViewController.childViewControllers.first as? GlossaryListViewController else {return}
        
        glossaryListViewController.definitionViewController = splitViewController.childViewControllers.last as? GlossaryEntryViewController
        glossaryWindow.showWindow(sender)
    }
    
}
