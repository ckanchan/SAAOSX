//
//  WindowController.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 14/01/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Cocoa

class ProjectListWindowController: NSWindowController, NSComboBoxDelegate {
    @IBOutlet weak var loadingIndicator: NSProgressIndicator!
    @IBOutlet weak var searchField: NSSearchField!
    lazy var projectViewController: ProjectListViewController = {
        let splitView = self.contentViewController as! NSSplitViewController
        return splitView.childViewControllers.first! as! ProjectListViewController
    }()
    
    override func windowDidLoad() {
        super.windowDidLoad()
    }

    func setTitle(_ s: String) {
        self.window?.title = s
    }
    
    func comboBoxSelectionDidChange(_ notification: Notification) {
        let box = notification.object as! NSComboBox
        
        let item = box.objectValueOfSelectedItem as! NSString
        switch item {
        case "SAA 01":
            projectViewController.loadCatalogue("saa01")
        case "SAA 02":
            projectViewController.loadCatalogue("saa02")
        case "SAA 05":
            projectViewController.loadCatalogue("saa05")
        case "SAA 10":
            projectViewController.loadCatalogue("saa10")
        case "SAA 13":
            projectViewController.loadCatalogue("saa13")
        case "SAA 15":
            projectViewController.loadCatalogue("saa15")
        case "SAA 16":
            projectViewController.loadCatalogue("saa16")
        case "SAA 17":
            projectViewController.loadCatalogue("saa17")
        case "SAA 18":
            projectViewController.loadCatalogue("saa18")
        case "SAA 19":
            projectViewController.loadCatalogue("saa19")
        default:
            return
        }
    }
    
    @IBAction func performFindPanelAction(_ sender: Any){
        searchField.selectText(nil)
    }
    
    @IBAction func search(_ sender: NSSearchFieldCell) {
        projectViewController.search(sender)
    }
    
    
}
