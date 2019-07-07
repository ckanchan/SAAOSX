//
//  PreferencesViewController.swift
//  SAAiOS
//
//  Created by Chaitanya Kanchan on 10/05/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import UIKit

class PreferencesViewController: UITableViewController {
    var downloadedVolumes: Set<String> {
        get {
            Set(UserDefaults.standard.stringArray(forKey: "downloadedVolumes") ?? [])
        } set {
            UserDefaults.standard.set(Array(newValue), forKey: "downloadedVolumes")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(updateTableView), name: Notification.Name("downloadedVolumesDidChange"), object: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int { 2 }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Downloaded Volumes"
        case 1: return "Other"
        default: return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return SAAVolume.allVolumes.count
        case 1: return 0
        default: return 0
        }
    }
    
    @objc func updateTableView(_ notification: Notification) {
        DispatchQueue.main.async {
            guard let userInfo = notification.userInfo as? [String: String],
                let volumeCode = userInfo["volume"],
                let op = userInfo["op"],
                let row = SAAVolume.allVolumes.firstIndex(where: {$0.code == volumeCode}),
                let cell = self.tableView.cellForRow(at: IndexPath(row: row, section: 0)) else {return}
            switch op {
            case "add":
                cell.accessoryView = nil
                cell.accessoryType = .checkmark
                self.downloadedVolumes.insert(volumeCode)
            case "delete":
                cell.accessoryType = .none
                return
            default:
                return
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "VolumeCell", for: indexPath)
            let volume = SAAVolume.allVolumes[indexPath.row]
            cell.imageView?.image = volume.image
            cell.textLabel?.text = volume.title
            cell.detailTextLabel?.text = volume.code.capitalized
            
            if downloadedVolumes.contains(volume.code) {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        switch indexPath.section {
        case 0:
            let volume = SAAVolume.allVolumes[indexPath.row]
            if downloadedVolumes.contains(volume.code) {
                tableView.deselectRow(at: indexPath, animated: true)
                try! sqlite.delete(volume)
                downloadedVolumes.remove(volume.code)
                cell.accessoryType = .none
                
            } else {
                tableView.deselectRow(at: indexPath, animated: true)
                let progressIndicator = UIActivityIndicatorView(style: .medium)
                cell.accessoryView = progressIndicator
                progressIndicator.startAnimating()
                sqlite.insert(volume)
            }
        default:
            return
        }
    }
}
