//
//  NoteSQLAnnotations.swift
//  SAAo-SX
//
//  Created by Chaitanya Kanchan on 31/03/2019.
//  Copyright © 2019 Chaitanya Kanchan. All rights reserved.
//

import Foundation
import SQLite
import CDKSwiftOracc
import CloudKit
import os

extension NoteSQLDatabase {
    /// Saves a new annotation to the SQL store, syncs it with CloudKit, updates tag indexes and dispatches notifications
    ///
    /// - Parameters:
    ///   - annotationToSave: This must be a new annotation otherwise the operation will fail
    ///   - updateCloudKit: defaults to `true` - this should only be false if called from a CloudKit database change notification handler
    func createAnnotation(_ annotationToSave: Annotation, updateCloudKit: Bool = true) {
        
        // Persist the annotation to the local database
        let tagString = annotationToSave.tags.joined(separator: ",")
        do {
            _ = try db.run(Schema.annotationTable.insert(
                Schema.nodeReference <- String(describing: annotationToSave.nodeReference),
                Schema.textID <- String(describing: annotationToSave.nodeReference.base),
                Schema.transliteration <- annotationToSave.transliteration,
                Schema.normalisation <- annotationToSave.normalisation,
                Schema.translation <- annotationToSave.translation,
                Schema.context <- annotationToSave.context,
                Schema.annotation <- annotationToSave.annotation,
                Schema.tags <- tagString
            ))
        } catch {
            os_log("Unable to save annotation with ID %s to database, error %s",
                   log: Log.NoteSQLite,
                   type: .error,
                   String(annotationToSave.nodeReference),
                   error.localizedDescription)
        }
        
        
        // Sync the annotation with CloudKit
        if updateCloudKit {
            cloudKitDB?.saveAnnotation(annotationToSave) {[unowned self] result in
                switch result {
                case .success(let record):
                    self.updateCloudKitMetadata(forAnnotation: annotationToSave, record: record)
                case .failure(let error):
                    os_log("Error saving annotation with ID %s to CloudKit: %s",
                           log: Log.CloudKit,
                           type: .error,
                           String(annotationToSave.nodeReference),
                           error.localizedDescription)
                }
            }
        }
        
       // Update tag indexes
        processTags(forNewAnnotation: annotationToSave)
        
        // Dispatch notifications about a new annotation being added, and a text edition being changed
        let notification = Notification.annotationAdded(reference: annotationToSave.nodeReference, tags: annotationToSave.tags)
        NotificationCenter.default.post(notification)
        
        let textChangeNotification = Notification.annotationsChanged(for: annotationToSave.nodeReference.base)
        NotificationCenter.default.post(textChangeNotification)
        
        os_log("Saved annotation with ID %s to database",
               log: Log.NoteSQLite,
               type: .info,
               String(annotationToSave.nodeReference))
    }
    
    func retrieveAnnotations(forID id: TextID) -> [Annotation] {
        let query = Schema.annotationTable.filter(Schema.textID == String(id))
        guard let annotationRows = try? db.prepare(query) else { return [] }
        return annotationRows.map(Annotation.init)
    }
    
    func retrieveSingleAnnotation(_ reference: NodeReference) -> Annotation? {
        let query = Schema.annotationTable.filter(Schema.nodeReference == String(reference))
        let row = try? db.pluck(query)
        return row.map(Annotation.init)
    }
    
    func retrieveAllAnnotations() -> [Annotation] {
        var annotations = [Annotation]()
        do {
            for row in try db.prepare(Schema.annotationTable) {
                annotations.append(Annotation(row: row))
            }
        } catch let Result.error(message: message, code: code, _) {
            os_log("Error retrieving all notes: code %{public}d, message: %{public}s",
                   log: Log.NoteSQLite,
                   type: .error,
                   code,
                   message)
            return []
        } catch {
            os_log("Error retrieving all notes: %s",
                   log: Log.NoteSQLite,
                   type: .error,
                   error.localizedDescription)
            return []
        }
        
        return annotations
    }
    
    /// Updates a pre-existing annotation to the SQL store, syncs it with CloudKit, updates tag indexes and dispatches notifications
    ///
    /// - Parameters:
    ///   - updatedAnnotation: this annotation must already exist in the SQL store otherwise the operation wil fail
    ///   - updateCloudKit: defaults to `true` - this should only be false if called from a CloudKit database change notification handler
    func updateAnnotation(_ updatedAnnotation: Annotation, updateCloudKit: Bool = true) {
        // Persist the annotation to the local database
        let reference = String(updatedAnnotation.nodeReference)
        let query = Schema.annotationTable.filter(Schema.nodeReference == reference)
        
        // Need to initialise it here and make it a `var` because the compiler can't tell its initialised across all paths
        var previousTags = Set<Tag>()
        
        // We need to get the previous tags in order to compare them with the updated ones.
        // This also serves to check that there is indeed a pre-existing entry in the database for this updated annotation
        do {
            guard let row = try db.pluck(query) else {throw Result.error(message: "No rows found", code: 16, statement: nil)}
            let prevTagArray = row[Schema.tags].split(separator: ",").map{String($0)} as [Tag]
            previousTags = Set(prevTagArray)
        } catch {
            os_log("Unable to find pre-existing annotation %s in database, error %s",
                   log: Log.NoteSQLite,
                   type: .error,
                   String(updatedAnnotation.nodeReference),
                   error.localizedDescription)
        }
        
        // Update the annotation with new annotation note and tags
        do {
            let tagString = updatedAnnotation.tags.joined(separator: ",")
            _ = try db.run(query.update(
                Schema.annotation <- updatedAnnotation.annotation,
                Schema.tags <- tagString
            ))
        } catch {
            os_log("Unable to update annotation with ID %s to database, error %s",
                   log: Log.NoteSQLite,
                   type: .error,
                   String(updatedAnnotation.nodeReference),
                   error.localizedDescription)
        }
        
        // Push the changes to the cloud
        if updateCloudKit {
            // Get Cloudkit saved metadata
            guard
                let row = try? db.pluck(query),
                let ckRecordData = row[Schema.ckSystemFields],
                let unarchiver = try? NSKeyedUnarchiver(forReadingFrom: ckRecordData)
            else {return}
            unarchiver.requiresSecureCoding = true
            guard let record = CKRecord(coder: unarchiver) else {return}
            
            record["annotation"] = updatedAnnotation.annotation
            
            cloudKitDB?.modifyRecord(record) { [unowned self] result in
                switch result {
                case .success(let record):
                    self.updateCloudKitMetadata(forAnnotation: updatedAnnotation, record: record)
                    os_log("Synced updated annotation %s with CloudKit",
                           log: Log.CloudKit,
                           type: .info,
                           String(updatedAnnotation.nodeReference))
                case .failure(let error):
                    os_log("Error updating annotation with ID %s to CloudKit: %{public}s",
                           log: Log.CloudKit,
                           type: .error,
                           String(updatedAnnotation.nodeReference),
                           error.localizedDescription)
                }
            }
        }
        
        // Update tag indexes
        let newTagsForAnnotation = updatedAnnotation.tags.subtracting(previousTags)
        let deletedTags = previousTags.subtracting(updatedAnnotation.tags)
        
        updateTags(forReference: updatedAnnotation.nodeReference,
                   newTagsForAnnotation: newTagsForAnnotation,
                   deletedTags: deletedTags)
        
        let notification = Notification.annotationAdded(reference: updatedAnnotation.nodeReference, tags: updatedAnnotation.tags)
        NotificationCenter.default.post(notification)
        let textChangeNotification = Notification.annotationsChanged(for: updatedAnnotation.nodeReference.base)
        NotificationCenter.default.post(textChangeNotification)
        
        os_log("Updated annotation with ID %s to database",
               log: Log.NoteSQLite,
               type: .info,
               String(updatedAnnotation.nodeReference))
    }

    
    /// Deletes an annotation from the SQL store, deletes it from CloudKit, then updates tag indexes
    ///
    /// - Parameter reference: `NodeReference` of the deleted annotation
    func deleteAnnotation(withReference reference: NodeReference) {
        let query = Schema.annotationTable.filter(Schema.nodeReference == String(describing: reference))
        var tagsToDelete = Set<Tag>()
        
        // We need to get the tags for this annotation in order to delete the reference from the indexed database
        // This also serves to check that there is indeed a pre-existing entry in the database for this deleted annotation
        do {
            guard let row = try db.pluck(query) else {throw Result.error(message: "No rows found", code: 16, statement: nil)}
            let prevTagArray = row[Schema.tags].split(separator: ",").map{String($0)} as [Tag]
            tagsToDelete = Set(prevTagArray)
        } catch {
            os_log("Unable to find pre-existing annotation %s in database, error %s",
                   log: Log.NoteSQLite,
                   type: .error,
                   String(reference),
                   error.localizedDescription)
        }
        
        do {
            try deleteFromSQLAndCloud(query: query)
        } catch {
            os_log("Unable to delete annotation %s, error %s",
                   log: Log.NoteSQLite,
                   type: .error,
                   String(reference),
                   error.localizedDescription)
        }
        
        // Delete the reference for this annotation from tag indexes
        updateTags(forReference: reference, newTagsForAnnotation: Set<Tag>(), deletedTags: tagsToDelete)
        
        let notification = Notification.annotationDeleted(reference: reference)
        NotificationCenter.default.post(notification)
        
        let textChangeNotification = Notification.annotationsChanged(for: reference.base)
        NotificationCenter.default.post(textChangeNotification)

    }
    
    
    /// Method called by a CloudKit database change handler when an annotation record is deleted on another device
    ///
    /// - Parameter recordID: CloudKit record ID
    /// - Throws: SQLite errors
    func deleteAnnotation(withRecordID recordID: CKRecord.ID) throws {
        let recordData = recordID.securelyEncoded()
        let query = Schema.annotationTable.filter(Schema.ckRecordID == recordData)
        guard let row = try db.pluck(query) else {
            os_log("Unable to find record for CloudKit ID %s",
                   log: Log.NoteSQLite,
                   type: .error,
                   String(describing: recordID))
            return
        }
        
        // Delete annotation from local database
        let nodeReferenceStr = row[Schema.nodeReference]
        let reference = NodeReference(nodeReferenceStr)!
        try db.run(query.delete())
        
        // Update tag indexes
        let tagString = row[Schema.tags]
        let tags = tagString.split(separator: ",").map{String($0)}
        updateTags(forReference: reference, newTagsForAnnotation: Set<Tag>(), deletedTags: Set(tags))
        
        let notification = Notification.annotationDeleted(reference: reference)
        NotificationCenter.default.post(notification)
        
        let textChangeNotification = Notification.annotationsChanged(for: reference.base)
        NotificationCenter.default.post(textChangeNotification)
        
        os_log("Deleted local annotation %s after it was deleted in CloudKit",
               log: Log.NoteSQLite,
               type: .info,
               String(reference))
    }

    
    /// Method called when CloudKit notifies an annotation has been changed. Checks whether the annotation exists in the local store: if it does, update the annotation, otherwise create a new annotation, without propagating the changes back to CloudKit (which would create an infinite loop)
    ///
    /// - Parameter record: new CloudKit annotation
    func processCloudKitAnnotation(from record: CKRecord) {
        guard let annotation = Annotation(ckRecord: record) else {return}
        
        os_log("Received updated annotation %s from CloudKit",
               log: Log.CloudKit,
               type: .info,
               String(annotation.nodeReference))
        
        if let _ = self.retrieveSingleAnnotation(annotation.nodeReference) {
            updateAnnotation(annotation, updateCloudKit: false)
        } else {
            createAnnotation(annotation, updateCloudKit: false)
        }
        
        updateCloudKitMetadata(forAnnotation: annotation, record: record)
    }
}

extension NoteSQLDatabase {
    func annotationsForTag(_ tag: String) -> [Annotation] {
        guard let index = retrieveIndex(forTag: tag) else {return []}
        let strIndex = index.map{String($0)}
        let query = Schema.annotationTable.filter(strIndex.contains(Schema.nodeReference))
        
//        let query = Schema.annotationTable.filter(Schema.tags.like("%\(tag)%"))
        var results = [Annotation]()
        do {
            let rows = try db.prepare(query)
            results = rows.compactMap(Annotation.init)
        } catch {
            os_log("Could not retrieve annotations for tag %s in database: %{public}s",
                   log: Log.NoteSQLite,
                   type: .error,
                   tag,
                   error.localizedDescription)
        }
        
        return results
    }
}

extension Annotation {
    init(row: Row) {
        let reference = NodeReference.init(stringLiteral: row[NoteSQLDatabase.Schema.nodeReference])
        let tagArray = row[NoteSQLDatabase.Schema.tags]
            .split(separator: ",")
            .map({String($0)})
        
        self.nodeReference = reference
        self.transliteration = row[NoteSQLDatabase.Schema.transliteration]
        self.normalisation = row[NoteSQLDatabase.Schema.normalisation]
        self.translation = row[NoteSQLDatabase.Schema.translation]
        self.annotation = row[NoteSQLDatabase.Schema.annotation]
        self.context = row[NoteSQLDatabase.Schema.context]
        self.tags = Set(tagArray)
    }
}
