//
//  CloudKitNotes.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 31/12/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Foundation
import CloudKit
import CDKSwiftOracc
import os

final class CloudKitNotes {
    enum Query {
        static func TextID(_ id: TextID) -> NSPredicate {
            let textID = id.description
            return NSPredicate(format: "textID == %@", textID)
        }
    }
    
    var userIsLoggedIn: Bool
    let userDefaults: UserDefaults
    let sqlDB: NoteSQLDatabase
    
    func deleteAllCloudKitData() {
        #warning("To be implemented")
    }
    
    @objc func userStatusDidChange() {
        CKContainer.default().accountStatus { [weak self] status, error in
            if let error = error {
                os_log("Error determining user status: %s",
                       log: Log.CloudKit,
                       type: .error,
                       error.localizedDescription)
                return
            }
            switch status {
            case .available:
                self?.userIsLoggedIn = true
            case .couldNotDetermine:
                os_log("Could not determine iCloud user status",
                       log: Log.CloudKit,
                       type: .error)
                self?.userIsLoggedIn = false
            default:
                self?.userIsLoggedIn = false
            }
        }
    }
    
    init(withDefaults userDefaults: UserDefaults = UserDefaults.standard, sqlDB: NoteSQLDatabase) {
        self.userDefaults = userDefaults
        self.sqlDB = sqlDB
        userIsLoggedIn = false
        self.userStatusDidChange()
        
        if self.databaseChangeToken == nil {
            self.registerDatabaseSubscription() { [unowned self] result in
                switch result {
                case .success:
                    os_log("Registered database subscription",
                           log: Log.CloudKit,
                           type: .info)
                    self.saveZonesToServer() { result in
                        if case let .failure( error) = result {
                            os_log("Error saving zones to server: %s",
                                   log: Log.CloudKit,
                                   type: .error,
                                   error.localizedDescription)
                        }
                    }
                    self.processDatabaseChanges()
                case .failure(let error):
                    os_log("Unable to register database subscription: %s",
                           log: Log.CloudKit,
                           type: .error,
                           error.localizedDescription)
                }
            }
        } else {
            self.processDatabaseChanges()
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(userStatusDidChange),
                                               name: .CKAccountChanged,
                                               object: nil)
    }
}
