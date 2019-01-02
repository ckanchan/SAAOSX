//
//  AppDelegate.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 09/01/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Cocoa
import CDKSwiftOracc
import CoreSpotlight
import CDKOraccInterface

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    lazy var oraccInterface: OraccInterface = {
        if UserDefaults.standard.bool(forKey: PreferenceKey.useGithub.rawValue) {
            return try! OraccGithubToSwiftInterface()
        } else {
            return OraccToSwiftInterface()
        }
    }()

    lazy var glossary: Glossary = { return Glossary() }()
    lazy var bookmarks: Bookmarks = { return try! Bookmarks() }()
    lazy var sqlite: SQLiteCatalogue? = { return SQLiteCatalogue() }()
    lazy var cloudKitDB: CloudKitNotes = { return CloudKitNotes() }()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSAppleEventManager.shared().setEventHandler(self, andSelector: #selector(handleAppleEvent(event:replyEvent:)), forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
        
        cloudKitDB.userStatusDidChange()
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
        ProjectListWindowController.new(catalogue: nil)
    }
    
    @IBAction func newGlossaryWindow(_ sender: Any){
        GlossaryWindowController.new(self)
    }
    
    @IBAction func newNotesWindow(_ sender: Any){
        //TODO :- Check User is signed in?
        guard let notesViewController = NotesTabViewController.new() else {return}
        notesViewController.view.window?.makeKeyAndOrderFront(self)
        
    }

    @IBAction func openPreferencesWindow(_ sender: Any) {
        if NSApp.windows.contains(where: {
            $0.title == "Preferences"
        }) {
            NSApp.windows.first(where: {$0.title == "Preferences"})?.makeKeyAndOrderFront(nil)
            return
        }
        let storyboard = NSStoryboard.init(name: "Preferences", bundle: Bundle.main)

        guard let newWindow = storyboard.instantiateController(withIdentifier: "Preferences") as? NSWindowController else {return}
        newWindow.showWindow(sender)

    }

    @IBAction func openDocument(_ sender: Any) {
        let panel = NSOpenPanel.init()
        panel.allowsMultipleSelection = false
        panel.begin { _ in

            guard let url = panel.urls.first else {return}

            switch url.pathExtension {

            case "json":
                if let data = try? Data(contentsOf: url) {
                    let decoder = JSONDecoder()
                    if let textEdition = try? decoder.decode(OraccTextEdition.self, from: data) {
                        let stringContainer = TextEditionStringContainer(textEdition)
                        let dummyData = OraccCatalogEntry.initFromSaved(id: "nil", displayName: "nil", ancientAuthor: nil, title: url.lastPathComponent, project: "file")

                        TextWindowController.new(dummyData, strings: stringContainer, catalogue: nil)

                    } else if let catalogue = try? decoder.decode(OraccCatalog.self, from: data) {
                        var texts = Array(catalogue.members.values)
                        texts.sort {$0.displayName < $1.displayName}
                        let catalogueProvider = Catalogue(catalogue: catalogue, sorted: texts, source: .local)

                        let newWindow = ProjectListWindowController.new(catalogue: catalogueProvider)

                        newWindow.setConnectionStatus(to: "local")

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

    func application(_ application: NSApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([NSUserActivityRestoring]) -> Void) -> Bool {
        if userActivity.activityType == CSSearchableItemActionType {
            if let cdliID = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
                if let result = self.bookmarks.contains(textID: cdliID) {
                    if result {
                        guard let entry = self.bookmarks.getCatalogueEntry(forID: cdliID) else {return openFromDatabase(withID: cdliID)}
                        let strings = self.bookmarks.getTextStrings(cdliID)
                        TextWindowController.new(entry, strings: strings, catalogue: bookmarks)
                        return true
                    }
                } else {
                    return openFromDatabase(withID: cdliID)
                }
            }
        }
        return false
    }

    func openFromDatabase(withID id: String) -> Bool {
        guard let sqliteDB = self.sqlite else {return false}
        let id = TextID.init(stringLiteral: id)
        if let entry = sqliteDB.getEntryFor(id: id) {
            if let strings = sqliteDB.getTextStrings(id) {
                TextWindowController.new(entry, strings: strings, catalogue: sqliteDB)
                return true
            }
        }
        return false
    }

    @objc func handleAppleEvent(event: NSAppleEventDescriptor, replyEvent: NSAppleEventDescriptor) {
        guard let appleEventDescription = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject)) else {return}
        guard let appleEventURLString = appleEventDescription.stringValue else {return}

        guard let url = URL(string: appleEventURLString) else {return}
        guard let sqlite = self.sqlite else {return}

        if let host = url.host {

            let window: TextWindowController?

            switch host {
            case "first":
                let components = url.pathComponents.reduce("", {result, next in
                    if next == "/" {
                        return result
                    } else {
                        return "\(result)\(next.lowercased())"
                    }
                })

                let results = sqlite.search(components)
                guard let first = results.first else {return}
                guard let strings = sqlite.getTextStrings(first.id) else {return}
                window = TextWindowController.new(first, strings: strings, catalogue: sqlite)

            case "id":
                let idString = url.lastPathComponent.uppercased()
                guard idString.count == 7 else {return}
                guard "PQX".contains(idString.prefix(1)) else {return}
                let id = TextID.init(stringLiteral: idString)

                guard let result = sqlite.getEntryFor(id: id) else {return}
                guard let strings = sqlite.getTextStrings(id) else {return}
                window = TextWindowController.new(result, strings: strings, catalogue: sqlite)

            case "search":
                let searchString = url.pathComponents.reduce("", {result, next in
                    if next == "/" {
                        return result
                    } else {
                        return "\(result)\(next.lowercased())"
                    }
                })

                let projectWindow = ProjectListWindowController.new(catalogue: sqlite)
                projectWindow.searchField.stringValue = searchString
                projectWindow.projectViewController.search(searchString)
                return

            default:
                return
            }

            if let query = url.query {
                guard let window = window else {return}
                switch query {
                case "cuneiform":
                    window.textViewController.first?.textSelected.selectedSegment = 0
                case "transliteration":
                    window.textViewController.first?.textSelected.selectedSegment = 1
                case "translation":
                    window.textViewController.first?.textSelected.selectedSegment = 3
                default:
                    return
                }

                window.textViewController.first?.setText(self)
            }

        }

    }

}
