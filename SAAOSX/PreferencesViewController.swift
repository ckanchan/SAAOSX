//
//  PreferencesViewController.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 23/01/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Cocoa
import CDKSwiftOracc

class PreferencesViewController: NSViewController {
    @IBOutlet weak var textPreferenceSwitch: NSSegmentedControl!
    @IBOutlet weak var temporaryFileLabel: NSTextField!
    
    lazy var defaults: UserDefaultsController = {
        return UserDefaultsController()
    }()

    var tempSize: Int {
        let size: Int
        let tmpDir = FileManager.default.temporaryDirectory.appendingPathComponent("oraccGithubCache", isDirectory: true)

        if let paths = try? FileManager.default.subpathsOfDirectory(atPath: tmpDir.path) {
            let fullPaths = paths.map {tmpDir.appendingPathComponent($0)}
            size = fullPaths.reduce(0) { result, next in
                let nextSize = try? next.resourceValues(forKeys: [.totalFileAllocatedSizeKey]).totalFileAllocatedSize ?? 0
                return result + (nextSize ?? 0)
            }
           return size
        }
        return 0
    }

    var sizeToDisplay: String {
        textPreferenceSwitch.selectSegment(withTag: defaults.textWindow)
        let byteCountFormatter = ByteCountFormatter()
        byteCountFormatter.allowedUnits = .useMB
        byteCountFormatter.countStyle = .file
        return byteCountFormatter.string(for: tempSize) ?? ""
    }

    @IBAction func setPreferenceDefault(_ sender: NSSegmentedControl) {
        defaults.saveTextPreference(sender.selectedSegment)
    }
    
    @IBAction func exportAllNotes(_ sender: Any) {
        guard let catalogue = sqlite else {return}
        let noteExporter = NoteExporter(catalogue: catalogue, noteDB: notesDB)
        
        do {
            guard let data = try noteExporter.exportAllNotes(to: .MicrosoftWord) else {return}
            
            let panel = NSSavePanel()
            panel.allowedFileTypes = ["docx"]
            panel.begin { response in
                guard response == .OK,
                    let url = panel.url else {return}
                
                do {
                    try data.write(to: url)
                } catch {
                    print(error.localizedDescription)
                }
            }
        } catch {
            let alert = NSAlert(error: error)
            alert.runModal()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        temporaryFileLabel?.stringValue = "Cache size: \(sizeToDisplay)"
    }

    @IBAction func temporaryFileClear(_ sender: Any) {
        let tmpDir = FileManager.default.temporaryDirectory.appendingPathComponent("oraccGithubCache", isDirectory: true)

        do {
            try FileManager.default.removeItem(at: tmpDir)
            try FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: false, attributes: nil)
        } catch {
            print(error)
        }

        temporaryFileLabel.stringValue = "Cache size: \(sizeToDisplay)"
    }
}
