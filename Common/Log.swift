//
//  Log.swift
//  SAAo-SX
//
//  Created by Chaitanya Kanchan on 21/04/2019.
//  Copyright © 2019 Chaitanya Kanchan. All rights reserved.
//

import Foundation
import os

enum Log {
    static var CloudKit: OSLog {
        return OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "CloudKit")
    }
    
    static var NoteSQLite: OSLog {
        return OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "NoteSQLite")
    }
    
    static var BookmarksSQLite: OSLog {
        return OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "BookmarksSQLite")
    }
    
    static var CatalogueSQLite: OSLog {
        return OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "CatalogueSQLite")
    }
    
    static var GlossarySQLite: OSLog {
                return OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "GlossarySQLite")
    }
}



 
