//
//  NoteSQLTags.swift
//  SAAo-SX
//
//  Created by Chaitanya Kanchan on 05/05/2019.
//  Copyright © 2019 Chaitanya Kanchan. All rights reserved.
//

import Foundation
import CDKSwiftOracc
import SQLite
import CloudKit
import os

extension NoteSQLDatabase {
    func createIndexedTag(_ tag: Tag, index: Set<NodeReference>, updateCloudKit: Bool = true) {
        do {
            _ = try db.run(Schema.tagsTable.insert(
                Schema.tag <- tag,
                Schema.nodeReferences <- index.map{String($0)}.joined(separator: ",")
            ))
        } catch {
            os_log("Unable to save indexed tag %s, error %s",
                   log: Log.NoteSQLite,
                   type: .error,
                   tag,
                   error.localizedDescription)
        }
    
        if updateCloudKit {
            // Sync the indexed tag with CloudKit
            cloudKitDB?.saveIndexedTag(tag, index: index) {[unowned self] result in
                switch result {
                case .success(let record):
                    self.updateCloudKitMetadata(forIndexedTag: tag, record: record)
                case .failure(let error):
                    os_log("Error saving indexed tag %s to CloudKit",
                           log: Log.CloudKit,
                           type: .error,
                           tag,
                           error.localizedDescription)
                }
            }
        }
        os_log("Saved indexed tag %s to database",
               log: Log.NoteSQLite,
               type: .info,
               tag)
    }
    
    func retrieveIndex(forTag tag: Tag) -> Set<NodeReference>? {
        let query = Schema.tagsTable.filter(Schema.tag == tag).select(Schema.nodeReferences)
        guard let row = try? db.pluck(query) else {return nil}
        let references = row[Schema.nodeReferences]
            .split(separator: ",")
            .compactMap({NodeReference.init(String($0))})
        return Set(references)
    }
    
    func updateIndexedTags(_ tags: [Tag: Set<NodeReference>], updateCloudKit: Bool = true) {
        for (tag, index) in tags {
            let query = Schema.tagsTable.filter(Schema.tag == tag)
            do {
                _ = try db.run(query.update(
                    Schema.nodeReferences <- index.map{String($0)}.joined(separator: ",")
                ))
            } catch {
                os_log("Unable to update indexed tag %s, error %s",
                       log: Log.NoteSQLite,
                       type: .error,
                       tag,
                       error.localizedDescription)
            }
        }
        
        if updateCloudKit {
            // Construct a query to get the CloudKit system metadata for each tag
            let query = Schema.tagsTable
                .filter(tags.keys.contains(Schema.tag))
                .select(Schema.ckSystemFields, Schema.tag)
            
            do {
                let rows = try db.prepare(query)
                
                // Map from database rows to updated CKRecords
                let records = rows.compactMap { (row: Row) -> CKRecord? in
                    
                    // For each tag row, decode the system fields and get a CKRecord
                    guard let record = row.toIndexedTagCKRecord() else {return nil}
                    
                    // Look up the updated index in `tags` passed to the method, then update the record
                    let tag = row[Schema.tag]
                    let indexArray = Array(tags[tag]!).map({String($0)})
                    record["index"] = indexArray
                    return record
                }
                
                
                // Submit the updated CKRecords for upload, then for each updated record, update its metadata
                cloudKitDB?.modifyRecords(records){ [unowned self] result in
                    switch result {
                    case .success(let record):
                        
                        guard let tag = record["tag"] as? Tag else {
                            os_log("Received an erroneous updated tag record, record ID %{public}",
                                   log: Log.CloudKit,
                                   type: .error,
                                   String(describing: record.recordID))
                            return
                        }
                        
                        self.updateCloudKitMetadata(forIndexedTag: tag, record: record)
                        os_log("Synced updated tag %s with CloudKit",
                               log: Log.CloudKit,
                               type: .info,
                               tag)
                    case .failure(let error):
                        os_log("Error updating tag to CloudKit: %{public}s",
                               log: Log.CloudKit,
                               type: .error,
                               error.localizedDescription)
                    }
                }
            } catch {
                os_log("Error updating tags %s to CloudKit, error: %{public}s",
                       log: Log.CloudKit,
                       type: .error,
                       tags.keys.joined(separator: ", "))
            }
        }
    }
    
    func deleteIndexedTag(_ tag: Tag) {
        let query = Schema.tagsTable.filter(Schema.tag == tag)
        do {
            try delete(query: query)
        } catch {
            os_log("Unable to delete indexed tag %s, error %s",
                   log: Log.NoteSQLite,
                   type: .error,
                   tag,
                   error.localizedDescription)
        }
    }
    
    func processCloudKitIndexedTag(from record: CKRecord) {
        guard let tag = record["tag"] as? String,
            let indexString = record["index"] as? String else {return}
        
        os_log("Received updated indexed tag %s from CloudKit",
               log: Log.CloudKit,
               type: .info,
               tag)
        
        let references = indexString.split(separator: ",")
            .map{String($0)}
            .compactMap{NodeReference($0)}
        
        if let _ = self.retrieveIndex(forTag: tag) {
            updateIndexedTags([tag: Set(references)])
        } else {
            createIndexedTag(tag, index: Set(references))
        }
        
        updateCloudKitMetadata(forIndexedTag: tag, record: record)
    }
}

extension Row {
    func toIndexedTagCKRecord() -> CKRecord? {
        guard let recordData = self[NoteSQLDatabase.Schema.ckSystemFields] else {return nil}
        let unarchiver = NSKeyedUnarchiver(forReadingWith: recordData)
        unarchiver.requiresSecureCoding = true
        guard let record = CKRecord(coder: unarchiver) else {return nil}
        return record
    }
}






