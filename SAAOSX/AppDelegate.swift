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
        return try! OraccGithubToSwiftInterface()
    }()
    


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    @IBAction func newProjectListWindow(_ sender: Any) {
        let storyboard = NSStoryboard.main
        
        guard let newWindow = storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("ProjectListWindow")) as? NSWindowController else {return}
        newWindow.showWindow(nil)
    }


}

