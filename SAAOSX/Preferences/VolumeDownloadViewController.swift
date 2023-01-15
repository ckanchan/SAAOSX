//
//  VolumeDownloadViewController.swift
//  SAAo-SX
//
//  Created by Chaitanya Kanchan on 15/01/2023.
//  Copyright © 2023 Chaitanya Kanchan. All rights reserved.
//

import Cocoa

class VolumeDownloadViewController: NSViewController {

    @IBOutlet weak var volumeTableView: NSTableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}

extension VolumeDownloadViewController: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        Volume.allVolumes.count
    }
}
