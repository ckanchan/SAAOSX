//
//  UserTagController.swift
//  SAAo-SX
//
//  Created by Chaitanya Kanchan on 05/04/2019.
//  Copyright © 2019 Chaitanya Kanchan. All rights reserved.
//

import Foundation
import CloudKit
import os

class UserTagController {
    private var userDefaults: UserDefaults = UserDefaults.standard
    var userTags: UserTags {
        didSet {
            userDefaults.set(Array(userTags.tags), forKey: UserTagController.userTagKey)
        }
    }
    var cloudKitDB: CloudKitNotes?
    
    func updateTags(adding newTags: UserTags) {
        let updatedTagSet = self.userTags.tags.union(newTags.tags)
        let userTags = UserTags(tags: updatedTagSet)
        saveTags(userTags)
    }
    
    func overwriteTags(with newTags: UserTags) {
        saveTags(newTags)
    }
    
    func removeTags(_ tagsToRemove: UserTags) {
        let updatedTagSet = self.userTags.tags.subtracting(tagsToRemove.tags)
        let userTags = UserTags(tags: updatedTagSet)
        saveTags(userTags)
    }
    
    func clearAllTags() {
        saveTags(UserTags([]))
    }
    
    private func saveTags(_ userTags: UserTags) {
        self.userTags = userTags
        
        // Sync tags with CloudKit
        if let cloudKitRecordData = userDefaults.data(forKey: UserTagController.userTagCKRecordSystemFields) {
            // Check if valid system fields have been recorded
            let unarchiver = NSKeyedUnarchiver(forReadingWith: cloudKitRecordData)
            unarchiver.requiresSecureCoding = true
            if let record = CKRecord(coder: unarchiver) {
                // We are modifying a pre-existing cloudkit record
                record["tags"] = Array(userTags.tags)
                cloudKitDB?.modifyRecord(record) {[userDefaults] result in
                    switch result {
                    case .success(let updatedRecord):
                        UserTagController.updateCloudKitMetadata(record: updatedRecord, userDefaults: userDefaults)
                    case .failure(let error):
                        os_log("Unable to sync user tags in CloudKit, error %s", log: Log.CloudKit, type: .error, error.localizedDescription)
                    }
                }
            }
        } else {
            // We need to create a new cloudkit tag record
            cloudKitDB?.saveTags(userTags) {[userDefaults] result in
                switch result {
                case .success(let record):
                    UserTagController.updateCloudKitMetadata(record: record, userDefaults: userDefaults)
                case .failure(let error):
                    os_log("Could not save new tag record to CloudKit, error %s", log: Log.CloudKit, type: .error, error.localizedDescription)
                }
            }
        }
    }
    
    init(tags: UserTags, userDefaults: UserDefaults) {
        self.userTags = tags
        self.userDefaults = userDefaults
    }
    
    convenience init(usingUserDefaults ud: UserDefaults = UserDefaults.standard) {
        let tags = ud.array(forKey: UserTagController.userTagKey) as? [Tag] ?? []
        self.init(tags: UserTags(tags), userDefaults: ud)
    }
    
    convenience init(withCloudKit ck: CloudKitNotes) {
        self.init()
        self.cloudKitDB = ck
    }
    
}

extension UserTagController {
    static var userTagKey: String {
        return "userTags"
    }
    
    static var userTagCKRecordSystemFields: String {
        return "userTagsCKRecordSystemFields"
    }
}

extension UserTagController {
    static func updateCloudKitMetadata(record: CKRecord, userDefaults: UserDefaults) {
        let data = NSMutableData()
        let coder = NSKeyedArchiver(forWritingWith: data)
        coder.requiresSecureCoding = true
        record.encodeSystemFields(with: coder)
        coder.finishEncoding()
        userDefaults.set(data, forKey: UserTagController.userTagCKRecordSystemFields)
    }
}
