//
//  CloudKitChanges.swift
//  SAAo-SX
//
//  Created by Chaitanya Kanchan on 19/04/2019.
//  Copyright © 2019 Chaitanya Kanchan. All rights reserved.
//

import Foundation
import CloudKit
import os

extension CloudKitNotes {
    var databaseChangeToken: CKServerChangeToken? {
        get {
            guard let data = userDefaults.data(forKey: .CloudKitDatabaseChangeTokenKey) else {return nil}
            let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
            unarchiver.requiresSecureCoding = true
            return CKServerChangeToken(coder: unarchiver)
        } set {
            if let token = newValue {
                let data = token.securelyEncoded()
                userDefaults.set(data, forKey: .CloudKitDatabaseChangeTokenKey)
            } else {
                userDefaults.removeObject(forKey: .CloudKitDatabaseChangeTokenKey)
            }
        }
    }
    
    func getChangeToken(for noteType: NoteType) -> CKServerChangeToken? {
        guard let data = userDefaults.data(forKey: noteType.changeTokenKey) else {return nil}
        let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
        unarchiver.requiresSecureCoding = true
        return CKServerChangeToken(coder: unarchiver)
    }
    
    func setChangeToken(_ changeToken: CKServerChangeToken?, for noteType: NoteType) {
        if let newToken = changeToken {
            let data = newToken.securelyEncoded()
            userDefaults.set(data, forKey: noteType.changeTokenKey)
        } else {
            userDefaults.removeObject(forKey: noteType.changeTokenKey)
        }
    }
    
    func updateChangeToken(_ changeToken: CKServerChangeToken?, for zoneID: CKRecordZone.ID) {
        if zoneID == noteZoneID {
            setChangeToken(changeToken, for: .Note)
        } else if zoneID == annotationZoneID {
            setChangeToken(changeToken, for: .Annotation)
        } else if zoneID == tagZoneID {
            setChangeToken(changeToken, for: .Tag)
        } else {
            os_log("Received call to update change token for an unknown zone type, with zoneID: %s", log: Log.CloudKit, type: .debug, String(describing: zoneID))
        }
    }
    
    func registerDatabaseSubscription(then completionHandler: ((Result<[CKSubscription], Error>) -> Void)? = nil) {
        let subscription = CKDatabaseSubscription()
        let notificationInfo = CKSubscription.NotificationInfo()
        #if os(macOS)
        notificationInfo.soundName = ""
        notificationInfo.title = ""
        notificationInfo.alertBody = ""
        #endif
        
        subscription.notificationInfo = notificationInfo
        
        let operation = CKModifySubscriptionsOperation(subscriptionsToSave: [subscription], subscriptionIDsToDelete: nil)
        operation.modifySubscriptionsCompletionBlock = { subscriptions, _, error in
            if let error = error {
                completionHandler?(.failure(error))
            } else if let subscriptions = subscriptions {
                completionHandler?(.success(subscriptions))
            }
        }
        
        CKContainer.default().privateCloudDatabase.add(operation)
    }
    
    func processDatabaseChanges() {
        let operation = CKFetchDatabaseChangesOperation(previousServerChangeToken: databaseChangeToken)
        operation.changeTokenUpdatedBlock = { [unowned self] changeToken in
            self.databaseChangeToken = changeToken
        }

        var changedRecordZoneIDs = [CKRecordZone.ID]()
        
        operation.recordZoneWithIDChangedBlock = { recordZoneID in
            changedRecordZoneIDs.append(recordZoneID)
        }
        
        operation.fetchDatabaseChangesCompletionBlock = { [unowned self] changeToken, _, error in
            if let error = error {
                os_log("Error fetching database changes: %s",
                       log: Log.CloudKit,
                       type: .error,
                       error.localizedDescription)
            }
            
            if let newChangeToken = changeToken {
                self.databaseChangeToken = newChangeToken
            }
            
            os_log("Fetched database changes", log: Log.CloudKit, type: .info)
            self.fetchRecordZoneChanges(changedRecordZoneIDs)
        }
        
        CKContainer.default().privateCloudDatabase.add(operation)
    }
    
    func fetchRecordZoneChanges(_ recordZoneIDs: [CKRecordZone.ID]) {
        let operation = CKFetchRecordZoneChangesOperation()
        operation.recordZoneIDs = recordZoneIDs
        operation.recordZoneChangeTokensUpdatedBlock = { [unowned self] recordZoneID, serverChangeToken, clientChangeTokenData in
            self.updateChangeToken(serverChangeToken, for: recordZoneID)
        }
        
        operation.recordChangedBlock = { [unowned self] record in
            self.updateCKRecord(record)
        }
        
        operation.recordWithIDWasDeletedBlock = { [unowned self] recordID, recordType in
            guard let noteType = NoteType.fromString(recordType) else {return}
            do {
                try self.sqlDB.delete(recordID: recordID, type: noteType)
            } catch {
                os_log("Could not delete %s record with ID %s from local database",
                       log: Log.NoteSQLite,
                       type: .error,
                       String(describing: noteType),
                       String(describing: recordID))
            }
        }
        
        operation.recordZoneFetchCompletionBlock = { [unowned self] completedZoneID, serverChangeToken, clientChangeTokenData, _, recordZoneError in
            if let error = recordZoneError {
                os_log("Error fetching changes for zone %s, %s",
                       log: Log.CloudKit,
                       type: .error,
                       completedZoneID.zoneName,
                       error.localizedDescription)
            } else {
                os_log("Fetched changes for zone %s",
                       log: Log.CloudKit,
                       type: .info,
                       completedZoneID.zoneName)
            }
            
            self.updateChangeToken(serverChangeToken, for: completedZoneID)
            
        }
        
        CKContainer.default().privateCloudDatabase.add(operation)
    }
    
    func updateCKRecord(_ record: CKRecord) {
        switch record.recordType {
        case CKRecord.RecordType.Annotation:
            sqlDB.processCloudKitAnnotation(from: record)
            
        case CKRecord.RecordType.Note:
            sqlDB.processCloudKitNote(from: record)

        case CKRecord.RecordType.Tags:
            return
        default:
            return
        }
    }
    
    func deleteCKRecord(_ record: CKRecord) {
        
    }
}
