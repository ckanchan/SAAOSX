//
//  WindowController.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 14/01/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Cocoa

class ProjectListWindowController: NSWindowController, NSComboBoxDelegate {
    @IBOutlet weak var volumesBox: NSComboBox!
    @IBOutlet weak var loadingIndicator: NSProgressIndicator!
    @IBOutlet weak var searchField: NSSearchField!
    @IBOutlet weak var pinnedToggle: NSButton!
    @IBOutlet weak var connectionStatus: NSTextField!

    @discardableResult static func new(catalogue: CatalogueProvider?) -> ProjectListWindowController {
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: Bundle.main)
        let sceneIdentifier = NSStoryboard.SceneIdentifier("ProjectListWindow")
        let newWindow = storyboard.instantiateController(withIdentifier: sceneIdentifier) as! ProjectListWindowController
        newWindow.projectViewController.catalogueProvider = catalogue
        newWindow.showWindow(nil)
        return newWindow
    }

    lazy var projectViewController: ProjectListViewController = {
        let splitView = self.contentViewController as! NSSplitViewController
        return splitView.childViewControllers.first! as! ProjectListViewController
    }()

    var previousCatalogue: CatalogueProvider?
    var previousConnection: String?

    override func windowDidLoad() {
        super.windowDidLoad()
    }

    func setTitle(_ title: String) {
        self.window?.title = title
    }

    func comboBoxSelectionDidChange(_ notification: Notification) {
        let box = notification.object as! NSComboBox
        let item = box.objectValueOfSelectedItem as! NSString
        switch item {
        case "rinap/rinap1":
            pinnedToggle.state = .off
            projectViewController.loadCatalogue("rinap1")
        case "rinap/rinap3":
            pinnedToggle.state = .off
            projectViewController.loadCatalogue("rinap3")
        case "rinap/rinap4":
            pinnedToggle.state = .off
            projectViewController.loadCatalogue("rinap4")
        case "saao/saa01":
            pinnedToggle.state = .off
            projectViewController.loadCatalogue("saa01")
        case "saao/saa02":
            pinnedToggle.state = .off
            projectViewController.loadCatalogue("saa02")
        case "saao/saa05":
            projectViewController.loadCatalogue("saa05")
        case "saao/saa08":
            projectViewController.loadCatalogue("saa08")
        case "saao/saa10":
            projectViewController.loadCatalogue("saa10")
        case "saao/saa13":
            projectViewController.loadCatalogue("saa13")
        case "saao/saa15":
            projectViewController.loadCatalogue("saa15")
        case "saao/saa16":
            projectViewController.loadCatalogue("saa16")
        case "saao/saa17":
            projectViewController.loadCatalogue("saa17")
        case "saao/saa18":
            projectViewController.loadCatalogue("saa18")
        case "saao/saa19":
            projectViewController.loadCatalogue("saa19")
        case "cams/gkab":
            projectViewController.loadCatalogue("gkab")
        case "pins":
            pinnedToggle.state = .on
            projectViewController.loadCatalogue("pins")
        case "sqlite":
            projectViewController.loadCatalogue("sqlite")
        default:
            return
        }
    }

    @IBAction func performFindPanelAction(_ sender: Any) {
        searchField.selectText(nil)
    }

    @IBAction func search(_ sender: NSSearchFieldCell) {
        projectViewController.search(sender)
    }

    @IBAction func togglePinned(_ sender: NSButton) {
        if sender.state == .on {
            sender.state = .on
            previousCatalogue = projectViewController.catalogueProvider
            previousConnection = connectionStatus.stringValue
            projectViewController.loadCatalogue("pins")
        } else {
            sender.state = .off
            if let catalogue = previousCatalogue {
                projectViewController.setCatalogueProvider(catalogue)
                setConnectionStatus(to: previousConnection ?? "")
                previousCatalogue = nil
                previousConnection = nil
            } else {
                projectViewController.loadCatalogue("saa01")
            }
        }
    }

    func setConnectionStatus(to state: String) {
        connectionStatus.stringValue = state
    }

}
