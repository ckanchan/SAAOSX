//
//  SplitViewController.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 20/01/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Cocoa

class GlossarySplitViewController: NSSplitViewController {
    weak var searchField: NSSearchField?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }

    @IBAction func glossarySearch(_ sender: NSSearchField) {
        let glossaryViewController = self.children.first! as! GlossaryListViewController
        glossaryViewController.search(sender)
    }

    @IBAction func performFindPanelAction(_ sender: Any) {
        searchField?.selectText(nil)
    }

}
