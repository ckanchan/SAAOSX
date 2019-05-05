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
    enum TagOperation {
        case add, remove
    }
    
    var tagSet: UserTags? {
        get {
            do {
                let query = Schema.tagsTable.select(Schema.tag)
                let rows = try db.prepare(query)
                let tags = rows.map({$0[Schema.tag]})
                return UserTags(tags)
            } catch {
                os_log("Unable to retrieve tags, error:",
                       log: Log.NoteSQLite,
                       type: .error,
                       error.localizedDescription)
                return nil
            }
        }
    }
    
    func updatePreexistingTags(_ tags: Set<Tag>, withReference reference: NodeReference, operation: TagOperation) {
        
        // Get the existing indexes for each pre-existing tag
        let indexPairs = tags.compactMap {tag -> (Tag, Set<NodeReference>)? in
            guard let index = retrieveIndex(forTag: tag) else {return nil}
            return (key: tag, value: index)
        }
        
        // Create a keyed dictionary from the retrieved indexes
        let indexes = Dictionary(uniqueKeysWithValues: indexPairs)
        let updatedIndexes: [Tag: Set<NodeReference>]
        
        // Add or remove the reference from the index
        switch operation {
        case .add:
            updatedIndexes = indexes.mapValues {$0.union([reference])}
        case .remove:
            updatedIndexes = indexes.mapValues {$0.subtracting([reference])}
        }
        
        
        // Commit the updated tag indexes
        updateIndexedTags(updatedIndexes)
    }
    
    func processTags(forNewAnnotation annotation: Annotation) {
        guard let tagSet = self.tagSet else {
            os_log("Could not process tags for annotation %s",
                   log: Log.NoteSQLite,
                   type: .error,
                   String(annotation.nodeReference))
            return
        }
        
        let preExistingTags = tagSet.tags.intersection(annotation.tags)
        let newTags = annotation.tags.subtracting(tagSet.tags)
        
        if !preExistingTags.isEmpty {
            updatePreexistingTags(preExistingTags, withReference: annotation.nodeReference, operation: .add)
        }
        
        if !newTags.isEmpty {
            newTags.forEach { tag in
                createIndexedTag(tag, index: Set([annotation.nodeReference]))
            }
        }
    }
    
    func updateTags(forReference reference: NodeReference, newTagsForAnnotation: Set<Tag>, deletedTags: Set<Tag>) {
        guard let tagSet = self.tagSet else {
            os_log("Could not process tags for annotation %s",
                   log: Log.NoteSQLite,
                   type: .error,
                   String(reference))
            return
        }
        
        let preExistingTags = tagSet.tags.intersection(newTagsForAnnotation)
        let newGlobalTags = newTagsForAnnotation.subtracting(tagSet.tags)
        
        if !preExistingTags.isEmpty {
            updatePreexistingTags(preExistingTags, withReference: reference, operation: .add)
        }
        
        if !newGlobalTags.isEmpty {
            newGlobalTags.forEach { tag in
                createIndexedTag(tag, index: Set([reference]))
            }
        }
        
        if !deletedTags.isEmpty {
            updatePreexistingTags(deletedTags, withReference: reference, operation: .remove)
        }
    }
    
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
        
        NotificationCenter.default.post(Notification.tagsDidChange)
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
        
        NotificationCenter.default.post(Notification.tagsDidChange)
    }
    
    func deleteIndexedTag(_ tag: Tag) {
        let query = Schema.tagsTable.filter(Schema.tag == tag)
        do {
            try deleteFromSQLAndCloud(query: query)
        } catch {
            os_log("Unable to delete indexed tag %s, error %s",
                   log: Log.NoteSQLite,
                   type: .error,
                   tag,
                   error.localizedDescription)
        }
        
        NotificationCenter.default.post(Notification.tagsDidChange)
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






