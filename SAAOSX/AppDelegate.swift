//
//  AppDelegate.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 09/01/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Cocoa
import OraccJSONtoSwift

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    lazy var oraccInterface: OraccInterface = {
        if UserDefaults.standard.bool(forKey: PreferenceKey.useGithub.rawValue) {
            return try! OraccGithubToSwiftInterface()
        } else {
            return OraccToSwiftInterface()
        }
    }()
    
    lazy var glossaryController: GlossaryController = {
        return GlossaryController()
    }()
    
    lazy var pinnedTextController: PinnedTextController = {
        return try! PinnedTextController()
    }()
    

    func applicationDidFinishLaunching(_ aNotification: Notification) {
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func setOraccInterface(to interface: InterfaceType) {
        switch interface {
        case .Github:
            do {
                oraccInterface = try OraccGithubToSwiftInterface()
            } catch {
                fatalError("Unable to initialise an interface")
            }
        case .Oracc:
            oraccInterface = OraccToSwiftInterface()
        }
    }
    
    @IBAction func newProjectListWindow(_ sender: Any) {
        let storyboard = NSStoryboard.main
        
        guard let newWindow = storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("ProjectListWindow")) as? NSWindowController else {return}
        newWindow.showWindow(nil)
    }
    
    @IBAction func openPreferencesWindow(_ sender: Any) {
        if NSApp.windows.contains(where: {
            $0.title == "Preferences"
        }) {
            NSApp.windows.first(where: {$0.title == "Preferences"})?.makeKeyAndOrderFront(nil)
            return
        }
        let storyboard = NSStoryboard.init(name: NSStoryboard.Name(rawValue: "Preferences"), bundle: Bundle.main)
        
        guard let newWindow = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Preferences")) as? NSWindowController else {return}
        newWindow.showWindow(sender)
        
    }
    
    @IBAction func openDocument(_ sender: Any){
        let panel = NSOpenPanel.init()
        panel.allowsMultipleSelection = false
        panel.begin { response in
         
            guard let url = panel.urls.first else {return}
            
            switch url.pathExtension {
            case "oraccstringcontainer":
                if let stringContainerData = try? Data(contentsOf: url) {
                    let decoder = JSONDecoder()
                    if let textContainer = try? decoder.decode(TextEditionStringContainer.self, from: stringContainerData) {
                        
                        let storyboard = NSStoryboard.init(name: NSStoryboard.Name(rawValue: "TextEdition"), bundle: Bundle.main)
                        
                        guard let window = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("textWindow")) as? TextWindowController else {return}
                        
                        guard let textView = window.contentViewController as? TextViewController else { return }
                        textView.stringContainer = textContainer
                        window.textViewController = [textView]
                        
                        window.showWindow(self)
                    } else {self.openError(fileAt: url)}
                } else {self.openError(fileAt: url)}
                
            case "json":
                if let data = try? Data(contentsOf: url){
                    let decoder = JSONDecoder()
                    if let textEdition = try? decoder.decode(OraccTextEdition.self, from: data) {
                        let storyboard = NSStoryboard.init(name: NSStoryboard.Name(rawValue: "TextEdition"), bundle: Bundle.main)
                        guard let window = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("textWindow")) as? TextWindowController else {return}
                        guard let textView = window.contentViewController as? TextViewController else {return}
                        textView.stringContainer = TextEditionStringContainer(textEdition)
                        window.textViewController = [textView]
                        window.showWindow(self)
                    } else if let catalogue = try? decoder.decode(OraccCatalog.self, from: data) {
                        var texts = Array(catalogue.members.values)
                        texts.sort{$0.displayName < $1.displayName}
                        let catalogueProvider = CatalogueController(catalogue: catalogue, sorted: texts, source: .local)
                        let storyboard = NSStoryboard.init(name: NSStoryboard.Name(rawValue: "Main"), bundle: Bundle.main)
                        guard let newWindow = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("ProjectListWindow")) as? ProjectListWindowController else {return}
                        
                        newWindow.projectViewController.catalogueProvider = catalogueProvider
                        newWindow.setConnectionStatus(to: "local")
                        newWindow.showWindow(nil)
                    } else {self.openError(fileAt: url)}
                } else {self.openError(fileAt: url)}
                
            default:
                self.openError(fileAt: url)
            }
        }
    }
    
    func openError(fileAt url: URL) {
        let alert = NSAlert()
        alert.messageText = "Could not open file"
        alert.informativeText = "The file at \(url.path) does not contain valid Oracc data."
        _ = alert.runModal()
    }
}

