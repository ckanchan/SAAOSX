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
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var didChooseDetail = false
    
    // Essential app services
    lazy var sqlDB: SQLiteCatalogue = { return SQLiteCatalogue() }()!
    lazy var glossaryDB: Glossary = { return Glossary() }()
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UIView.appearance().tintColor = .purple
        self.window = self.window ?? UIWindow()
        let svc = UISplitViewController()
        let detailViewController = TextEditionViewController()
        let masterViewController = ProjectListViewController.new(detailViewController: detailViewController)
        let masterNavigationController = UINavigationController(rootViewController: masterViewController)
        
        masterNavigationController.isToolbarHidden = false
        
        let detailNavigationController = UINavigationController(rootViewController: detailViewController)
        
        svc.viewControllers = [masterNavigationController, detailNavigationController]
        svc.delegate = self
        
        self.window!.rootViewController = svc
        detailViewController.navigationItem.leftBarButtonItem = svc.displayModeButtonItem
        detailViewController.navigationItem.leftItemsSupplementBackButton = true
        
        self.window!.backgroundColor = .white
        self.window!.makeKeyAndVisible()
        
        return true
    }
    
}

extension AppDelegate: UISplitViewControllerDelegate {
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        if
            let navigationController = secondaryViewController as? UINavigationController,
            navigationController.topViewController is TextEditionViewController,
            self.didChooseDetail {
            return false
        } else {
            return true
        }
    }
}
