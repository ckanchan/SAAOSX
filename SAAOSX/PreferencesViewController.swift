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
    @IBOutlet weak var providerSwitch: NSSegmentedControl!
    @IBOutlet weak var signedInLabel: NSTextField!
    @IBOutlet weak var signInButton: NSButton!
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
        temporaryFileLabel?.stringValue = "Cache size: \(sizeToDisplay)"
        if defaults.useGithub {
            providerSwitch.selectedSegment = 1
        } else {
            providerSwitch.selectedSegment = 0
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(setSignInLabels), name: .SignedIn, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setSignInLabels), name: .SignedOut, object: nil)
    }
    
    override func viewWillAppear() {
        setSignInLabels()
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

    @IBAction func setProviderDefault(_ sender: NSSegmentedControl) {
        if sender.selectedSegment == 1 {
            defaults.saveInterfaceSource(true)
            appDelegate.setOraccInterface(to: .Github)

        } else {
            defaults.saveInterfaceSource(false)
            appDelegate.setOraccInterface(to: .Oracc)
        }
    }
    
    @IBAction func sync(_ sender: NSButton) {
        if user.user == nil {
            if user.oauthCredentials == nil {
                self.credentialPrompt()
            }
            
            user.signIn()            
        } else {
            user.signOut()
        }
    }
    
    @objc func setSignInLabels() {
        if let userName = user.user?.email {
            signedInLabel.stringValue = userName
            signInButton.title = "Sign out"
        } else {
            signedInLabel.stringValue = "Not signed in"
            signInButton.title = "Sign in with Google"
        }
    }
    
    func credentialPrompt() {
        guard let credentialWindow = storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier.init("OAuthCredentialWindow")) as? NSWindowController else {return}
        
        guard let window = credentialWindow.window else {return}
        NSApplication.shared.runModal(for: window)
        
    }
    
    
}
