//
//  SceneDelegate.swift
//  SAAi
//
//  Created by Chaitanya Kanchan on 11/06/2019.
//  Copyright © 2019 Chaitanya Kanchan. All rights reserved.
//

import UIKit
import CDKSwiftOracc

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var projectViewController: ProjectListViewController?
    var didChooseDetail = false
    
    func setUpControllers() -> UISplitViewController {
        let splitViewController = UISplitViewController()
        
        // Configure 'right' (detail) pane
        let detailViewController = TextEditionViewController()
        detailViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        detailViewController.navigationItem.leftItemsSupplementBackButton = true
        
        let detailNavigationController = UINavigationController(rootViewController: detailViewController)
        
        // Configure 'list' (master) pane
        let masterViewController = ProjectListViewController.new(detailViewController: detailViewController, sceneDelegate: self)
        detailViewController.catalogue = masterViewController.catalogue
        detailViewController.parentController = masterViewController
        projectViewController = masterViewController
        
        #if !targetEnvironment(UIKitForMac)
        // For all iPhone and iPad environments, embed the list controller in a nav view
        
        let masterNavigationController = UINavigationController(rootViewController: masterViewController)
        masterNavigationController.isToolbarHidden = false
        
        splitViewController.viewControllers = [masterNavigationController, detailNavigationController]
        
        #else
        splitViewController.viewControllers = [masterViewController, detailViewController]
        #endif
        
        return splitViewController
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        
        let splitViewController = setUpControllers()
        splitViewController.delegate = self
        
        #if targetEnvironment(UIKitForMac)
        splitViewController.primaryBackgroundStyle = .sidebar
        
        if let titleBar = windowScene.titlebar {
            let toolbar = NSToolbar(identifier: "MainWindow")
            toolbar.delegate = splitViewController.children[0] as! ProjectListViewController
            titleBar.toolbar = toolbar
        }
        
        #else
        splitViewController.preferredDisplayMode = .allVisible
        #endif
        
        window?.rootViewController = splitViewController
        
        window?.makeKeyAndVisible()
        
        if let userActivity = connectionOptions.userActivities.first ?? session.stateRestorationActivity {
            self.scene(scene, continue: userActivity)
        } else if connectionOptions.urlContexts.count == 1 {
            self.scene(scene, openURLContexts: connectionOptions.urlContexts)
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        for urlContext in URLContexts {
            guard let projectListViewController = self.projectViewController,
                let components = URLComponents(url: urlContext.url, resolvingAgainstBaseURL: true),
                let query = components.queryItems?.first,
                query.name == "id",
                let idString = query.value else {continue}
            
            switch components.path {
            case "/text":
                let textID = TextID(idString)!
                projectListViewController.navigate(to: textID)
                
            default:
                continue
            }

        }
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        if let id = TextID(userActivity.title ?? "") {
            projectViewController?.navigate(to: id)
        }
    }
}



extension SceneDelegate: UISplitViewControllerDelegate {
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
