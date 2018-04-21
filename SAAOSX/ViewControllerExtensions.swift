//
//  ViewControllerExtensions.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 14/01/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Cocoa
import OraccJSONtoSwift
import CDKOraccInterface


extension NSViewController {
    var appDelegate: AppDelegate {
        return NSApplication.shared.delegate! as! AppDelegate
    }
    
    var oracc: OraccInterface {
        return appDelegate.oraccInterface
    }
    
    var bookmarkedTextController: BookmarkedTextController {
        return appDelegate.bookmarkedTextController
    }
    
    var glossaryController: GlossaryController {
        return appDelegate.glossaryController
    }
    
    var sqlite: SAAOSQLController? {return appDelegate.sqlite}
}
