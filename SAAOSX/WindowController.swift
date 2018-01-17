//
//  WindowController.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 14/01/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController, NSComboBoxDelegate {

    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }

    func setTitle(_ s: String) {
        self.window?.title = s
    }
    
    func comboBoxSelectionDidChange(_ notification: Notification) {
        let box = notification.object as! NSComboBox
        
        let item = box.objectValueOfSelectedItem as! NSString
        let projectViewController = self.window?.contentViewController?.childViewControllers[0] as! ProjectListViewController
        switch item {
        case "SAA 01":
            projectViewController.loadCatalogue("saa01")
        case "SAA 05":
            projectViewController.loadCatalogue("saa05")
        case "SAA 10":
            projectViewController.loadCatalogue("saa10")
        default:
            return
        }
    }
}
