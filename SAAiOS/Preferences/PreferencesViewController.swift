//
//  PreferencesViewController.swift
//  SAAiOS
//
//  Created by Chaitanya Kanchan on 10/05/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import UIKit

class PreferencesViewController: UITableViewController {
    var downloadsSize: Int {
        return (try? sqlite.url.resourceValues(forKeys: [.totalFileAllocatedSizeKey]).totalFileAllocatedSize) ?? 0
    }
    
    private lazy var byteCountFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = .useMB
        formatter.countStyle = .file
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(updateTableView), name: Notification.Name("downloadedVolumesDidChange"), object: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int { return 2 }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Text Volumes"
        case 1: return "Storage"
        default: return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return SAAVolume.allVolumes.count
        case 1: return 2
        default: return 0
        }
    }
    
    @objc func updateTableView(_ notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            guard let userInfo = notification.userInfo as? [String: String],
                let volumeCode = userInfo["volume"],
                let op = userInfo["op"] else {return}
            switch op {
            case "add":
                self?.downloadedVolumes.insert(volumeCode)
                guard let volume = SAAVolume(code: volumeCode),
                    let idx = SAAVolume.allVolumes.firstIndex(of: volume),
                    let cell = self?.tableView.cellForRow(at: IndexPath(row: idx, section: 0))
                    else {return}
                
                self?.tableView.reloadData()
                cell.accessoryType = .checkmark
                
            case "delete":
                self?.tableView.reloadData()
                
            default:
                break
            }
            
            if let s = self {
                let storageCell = s.tableView.cellForRow(at: IndexPath(row: 0, section: 1))
                storageCell?.textLabel?.text = "Download size: \(s.byteCountFormatter.string(for: s.downloadsSize) ?? "?")"
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
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Download size: \(self.byteCountFormatter.string(for: downloadsSize) ?? "?")"
                cell.textLabel?.textColor = .gray
                cell.selectionStyle = .none
            case 1:
                cell.textLabel?.text = "Delete all downloads"
                cell.textLabel?.textColor = .red
            default:
                break
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
                let progressIndicator = UIActivityIndicatorView(style: .gray)
                cell.accessoryView = progressIndicator
                progressIndicator.startAnimating()
                sqlite.insert(volume)
            }
            
        case 1:
            if indexPath.row == 1 {
                deleteAll()
                tableView.deselectRow(at: indexPath, animated: true)
            }
        default:
            return
        }
    }
    
    func deleteAll() {
        let alert = UIAlertController(title: "Delete all?", message: "Deleting all texts from downloads will mean you will need to redownload at least one volume again to use the app", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let db = self.sqlite
        let delete = UIAlertAction(title: "Delete All", style: .destructive){ _ in
            db.deleteAll() { result in
                switch result {
                case .success:
                    UserDefaults.standard.removeObject(forKey: "downloadedVolumes")
                    DispatchQueue.main.async { [weak self] in
                        self?.tableView.reloadData()
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        
        alert.addAction(cancel)
        alert.addAction(delete)
        present(alert, animated: true)
    }
}

