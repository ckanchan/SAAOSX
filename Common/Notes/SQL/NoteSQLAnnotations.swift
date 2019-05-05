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
        
        if updateCloudKit {
            // Sync the annotation with CloudKit
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
    
    func updateAnnotation(_ updatedAnnotation: Annotation, updateCloudKit: Bool = true) {
        // Persist the annotation to the local database
        let reference = String(updatedAnnotation.nodeReference)
        let query = Schema.annotationTable.filter(Schema.nodeReference == reference)
        do {
            _ = try db.run(query.update(
                Schema.annotation <- updatedAnnotation.annotation
            ))
        } catch {
            os_log("Unable to update annotation with ID %s to database, error %s",
                   log: Log.NoteSQLite,
                   type: .error,
                   String(updatedAnnotation.nodeReference),
                   error.localizedDescription)
        }
        
        if updateCloudKit {
            // Get Cloudkit saved metadata
            guard let row = try? db.pluck(query),
                let ckRecordData = row[Schema.ckSystemFields] else {return}
            
            let unarchiver = NSKeyedUnarchiver(forReadingWith: ckRecordData)
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
        
        let notification = Notification.annotationAdded(reference: updatedAnnotation.nodeReference, tags: updatedAnnotation.tags)
        NotificationCenter.default.post(notification)
        let textChangeNotification = Notification.annotationsChanged(for: updatedAnnotation.nodeReference.base)
        NotificationCenter.default.post(textChangeNotification)
        
        os_log("Updated annotation with ID %s to database",
               log: Log.NoteSQLite,
               type: .info,
               String(updatedAnnotation.nodeReference))
    }

    func deleteAnnotation(withReference reference: NodeReference) {
        let query = Schema.annotationTable.filter(Schema.nodeReference == String(describing: reference))
        do {
            try delete(query: query)
        } catch {
            os_log("Unable to delete annotation %s, error %s",
                   log: Log.NoteSQLite,
                   type: .error,
                   String(reference),
                   error.localizedDescription)
        }
        
        let notification = Notification.annotationDeleted(reference: reference)
        NotificationCenter.default.post(notification)
        
        let textChangeNotification = Notification.annotationsChanged(for: reference.base)
        NotificationCenter.default.post(textChangeNotification)

    }
    
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
        
        let nodeReferenceStr = row[Schema.nodeReference]
        let reference = NodeReference(stringLiteral: nodeReferenceStr)
        try db.run(query.delete())
        
        let notification = Notification.annotationDeleted(reference: reference)
        NotificationCenter.default.post(notification)
        
        let textChangeNotification = Notification.annotationsChanged(for: reference.base)
        NotificationCenter.default.post(textChangeNotification)
        
        os_log("Deleted local annotation %s after it was deleted in CloudKit",
               log: Log.NoteSQLite,
               type: .info,
               String(reference))
    }

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
        let query = Schema.annotationTable.filter(Schema.tags.like("%\(tag)%"))
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
