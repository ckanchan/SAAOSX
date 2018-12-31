//
//  ViewControllerExtensions.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 14/01/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Cocoa
import CDKSwiftOracc
import CDKOraccInterface

extension NSViewController {
    var appDelegate: AppDelegate {
        return NSApplication.shared.delegate! as! AppDelegate
    }

    var oracc: OraccInterface {
        return appDelegate.oraccInterface
    }

    var bookmarks: Bookmarks {
        return appDelegate.bookmarks
    }

    var glossary: Glossary {
        return appDelegate.glossary
    }

    var sqlite: SQLiteCatalogue? {return appDelegate.sqlite}
}
