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
    lazy var sqlDB: SQLiteCatalogue = {
        return SQLiteCatalogue()
        }()!

    lazy var glossaryDB: Glossary = {
        return Glossary()
    }()

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

        let themeController = ThemeController()
        themeController.change(theme: themeController.themePreference)
        self.registerThemeNotifications()

        return true
    }

    deinit {
        deregisterThemeNotifications()
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
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

extension AppDelegate: Themeable {

    func enableDarkMode() {
        UIApplication.shared.statusBarStyle = .lightContent
    }

    func disableDarkMode() {
        UIApplication.shared.statusBarStyle = .default
    }

    var darkTheme: Bool {
        switch ThemeController().themePreference {
        case .dark:
            return true
        default:
            return false
        }
    }
}
