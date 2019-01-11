//
//  AppDelegate.swift
//  SAAiOS
//
//  Created by Chaitanya Kanchan on 06/03/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import UIKit
import CDKSwiftOracc

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?
    lazy var sqlDB: SQLiteCatalogue = { return SQLiteCatalogue() }()!

    lazy var glossaryDB: Glossary = { return Glossary() }()

    var splitViewController: UISplitViewController {
        return window!.rootViewController as! UISplitViewController
    }

    var navigationController: UINavigationController {
        return splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
    }

    var detailNavigationController: UINavigationController {
     return self.splitViewController.viewControllers.last! as! UINavigationController
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        splitViewController.delegate = self

        return true
    }

    func application(_ application: UIApplication, didDecodeRestorableStateWith coder: NSCoder) {
        self.sqlDB = SQLiteCatalogue()!
        self.glossaryDB = Glossary()
    }

    // MARK: - Split view

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let topAsDetailController = secondaryAsNavController.topViewController as? TextEditionViewController else { return false }
        if topAsDetailController.textItem == nil {
            // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
            return true
        }
        return false
    }

    func application(_ application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
        return true
    }

    func application(_ application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
        return true
    }

}
