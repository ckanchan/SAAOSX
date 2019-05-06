//
//  CloudKitZones.swift
//  SAAo-SX
//
//  Created by Chaitanya Kanchan on 05/04/2019.
//  Copyright © 2019 Chaitanya Kanchan. All rights reserved.
//

import CloudKit
import Foundation
import os

extension CloudKitNotes {
    var noteZoneID: CKRecordZone.ID? {
        return zoneIDForNoteType(.Note)
    }
    
    var annotationZoneID: CKRecordZone.ID? {
        return zoneIDForNoteType(.Annotation)
    }
    
    var tagZoneID: CKRecordZone.ID? {
        return zoneIDForNoteType(.Tag)
    }
    
    
    func zoneIDForNoteType(_ noteType: NoteType) -> CKRecordZone.ID? {
        guard let data = userDefaults.data(forKey: noteType.zoneIDKey) else {return nil}
        let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
        unarchiver.requiresSecureCoding = true
        return CKRecordZone.ID(coder: unarchiver)
    }
    
    /// Polls the CloudKit server for all record zones
    ///
    /// - Parameter completionHandler: Returns an array of all record zones on the server
    func checkServerZones(then completionHandler: @escaping (Result<[CKRecordZone], Error>) -> Void) {
        let checkZoneOperation = CKFetchRecordZonesOperation.fetchAllRecordZonesOperation()
        checkZoneOperation.fetchRecordZonesCompletionBlock = {zoneDictionary, error in
            if let e = error {
                completionHandler(.failure(e))
            } else if let zoneDictionary = zoneDictionary {
                let serverZones = Array(zoneDictionary.values)
                completionHandler(.success(serverZones))
            }
        }
        
        CKContainer.default().privateCloudDatabase.add(checkZoneOperation)
    }
    
    /// Caches a zone ID to the specified `UserDefaults` object, corresponding to one of the given `NoteType`s
    ///
    /// - Parameters:
    ///   - zoneID: the `CKRecordZone.ID` to save
    ///   - zoneType: whether the `zoneID` is for a `Note`, `Annotation` or `Tag` zone
    func saveZoneIDLocally(_ zoneID: CKRecordZone.ID, for zoneType: NoteType) {
        let key = zoneType.zoneIDKey
        let data = zoneID.securelyEncoded()
        userDefaults.set(data, forKey: key)
    }
    
    func saveZoneID(_ zone: CKRecordZone) {
        if let noteType = NoteType.fromString(zone.zoneID.zoneName) {
            saveZoneIDLocally(zone.zoneID, for: noteType)
        } else {
            os_log("Zone ID does not match any known zone types, received ID with zone name: %{public}s",
                   log: Log.CloudKit,
                   type: .error,
                   zone.zoneID.zoneName)
        }
    }
    
    /// Checks the zones on the server and then saves any missing zones
    ///
    /// - Parameter completionHandler: a closure that takes an array of `CKRecordZone`s saved to the server
    func saveZonesToServer(then completionHandler: ((Result<[CKRecordZone], Error>) -> Void)? = nil) {
        checkServerZones { [weak self] result in
            switch result {
            case .success(let cloudZones):
                os_log("Received list of zones from server, count: %{public}d",
                       log: Log.CloudKit,
                       type: .info,
                       cloudZones.count)
                
                var zonesToSave = [CKRecordZone]()
                NoteType.allCases.forEach { noteType in
                    let zone = noteType.zone
                    if let cloudZone = cloudZones.first(where: {$0 == zone}) {
                        self?.saveZoneIDLocally(cloudZone.zoneID, for: noteType)
                    } else {
                        zonesToSave.append(zone)
                    }
                }
                
                guard !zonesToSave.isEmpty else {return}
                os_log("Zones to add to server: %s", log: Log.CloudKit, type: .info, zonesToSave.map({$0.zoneID.zoneName}).joined(separator: "; "))
                
                let operation = CKModifyRecordZonesOperation(recordZonesToSave: zonesToSave, recordZoneIDsToDelete: nil)
                operation.modifyRecordZonesCompletionBlock = {zones, _, error in
                    if let e = error {
                        completionHandler?(.failure(e))
                    } else if let z = zones {
                        z.forEach { savedZone in
                            self?.saveZoneID(savedZone)
                        }
                        completionHandler?(.success(z))
                    }
                }
                CKContainer.default().privateCloudDatabase.add(operation)
            case .failure(let error):
                os_log("Unable to check zones on server: %{public}s",
                       log: Log.CloudKit,
                       type: .error,
                       error.localizedDescription)
            }
        }
    }
}
