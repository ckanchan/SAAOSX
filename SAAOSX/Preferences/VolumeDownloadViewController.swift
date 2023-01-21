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
    @IBOutlet weak var volumeLabel: NSTextField!
    @IBOutlet weak var volumeDescription: NSTextField!
    @IBOutlet weak var volumeImageView: NSImageView!
    lazy var defaults: UserDefaultsController = {
        return UserDefaultsController()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        volumeTableView.reloadData()
    }
    
}

extension VolumeDownloadViewController: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        Volume.allVolumes.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let view = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView else { return nil }
        
        let volume = Volume.allVolumes[row]
        if tableColumn?.identifier.rawValue == "volumeName" {
            view.textField?.stringValue = volume.title
        } else if tableColumn?.identifier.rawValue == "isDownloaded" {
            let isDownloaded = defaults.downloadedVolumes.contains(volume.code)
            view.textField?.stringValue = isDownloaded ? "Downloaded" : ""
        }
        
        return view
        
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let volume = Volume.allVolumes[volumeTableView.selectedRow]
        volumeLabel.stringValue = volume.title
        volumeDescription.stringValue =  volume.blurb
        volumeImageView.image = volume.image
        
    }
}
