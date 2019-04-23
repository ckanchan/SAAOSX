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
    
    func rowToAnnotation(_ row: Row) -> Annotation {
        let reference = NodeReference.init(stringLiteral: row[nodeReference])
        let tagArray = row[tags]
            .split(separator: ",")
            .map({String($0)})
        
        return Annotation(nodeReference: reference,
                          transliteration: row[transliteration],
                          normalisation: row[normalisation],
                          translation: row[translation],
                          annotation: row[annotation],
                          context: row[context],
                          tags: Set(tagArray))
    }
    
    func createAnnotation(_ annotationToSave: Annotation, updateCloudKit: Bool = true) {
        // Persist the annotation to the local database
        let tagString = annotationToSave.tags.joined(separator: ",")
        do {
            _ = try db.run(annotationTable.insert(
                nodeReference <- String(describing: annotationToSave.nodeReference),
                textID <- String(describing: annotationToSave.nodeReference.base),
                transliteration <- annotationToSave.transliteration,
                normalisation <- annotationToSave.normalisation,
                translation <- annotationToSave.translation,
                context <- annotationToSave.context,
                annotation <- annotationToSave.annotation,
                tags <- tagString
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
            cloudKitDB?.saveAnnotation(annotationToSave) {[weak self] result in
                switch result {
                case .success(let record):
                    guard let noteSQLDB = self else {return}
                    noteSQLDB.updateCloudKitMetadata(forAnnotation: annotationToSave, record: record)
                case .failure(let error):
                    os_log("Error saving annotation with ID %s to CloudKit: %s", log: Log.CloudKit, type: .error, String(annotationToSave.nodeReference), error.localizedDescription)
                }
            }
        }
        
        let notification = Notification.annotationAdded(reference: annotationToSave.nodeReference)
        NotificationCenter.default.post(notification)
        
        let textChangeNotification = Notification.annotationsChanged(for: annotationToSave.nodeReference.base)
        NotificationCenter.default.post(textChangeNotification)
        
        os_log("Saved annotation with ID %s to database",
               log: Log.NoteSQLite,
               type: .info,
               String(annotationToSave.nodeReference))
    }
    
    func retrieveAnnotations(forID id: TextID) -> [Annotation] {
        let query = annotationTable.filter(textID == String(id))
        guard let annotationRows = try? db.prepare(query) else { return [] }
        return annotationRows.map(rowToAnnotation)
    }
    
    func retrieveSingleAnnotation(_ reference: NodeReference) -> Annotation? {
        let query = annotationTable.filter(nodeReference == String(reference))
        let row = try? db.pluck(query)
        return row.map(rowToAnnotation)
    }
    
    func updateAnnotation(_ updatedAnnotation: Annotation, updateCloudKit: Bool = true) {
        // Persist the annotation to the local database
        let reference = String(describing: updatedAnnotation.nodeReference)
        let query = annotationTable.filter(nodeReference == reference)
        do {
            _ = try db.run(query.update(
                annotation <- updatedAnnotation.annotation
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
                let ckRecordData = row[ckSystemFields] else {return}
            
            let unarchiver = NSKeyedUnarchiver(forReadingWith: ckRecordData)
            unarchiver.requiresSecureCoding = true
            guard let record = CKRecord(coder: unarchiver) else {return}
            
            record["annotation"] = updatedAnnotation.annotation
            
            cloudKitDB?.modifyRecord(record) { [weak self] result in
                guard let noteDB = self else {return}
                switch result {
                case .success(let record):
                    noteDB.updateCloudKitMetadata(forAnnotation: updatedAnnotation, record: record)
                    os_log("Synced updated annotation %s with CloudKit", log: Log.CloudKit, type: .info, String(updatedAnnotation.nodeReference))
                case .failure(let error):
                    os_log("Error updating annotation with ID %s to CloudKit: %s", log: Log.CloudKit, type: .error, String(updatedAnnotation.nodeReference), error.localizedDescription)
                }
            }
        }
        
        let notification = Notification.annotationAdded(reference: updatedAnnotation.nodeReference)
        NotificationCenter.default.post(notification)
        let textChangeNotification = Notification.annotationsChanged(for: updatedAnnotation.nodeReference.base)
        NotificationCenter.default.post(textChangeNotification)
        
        os_log("Updated annotation with ID %s to database",
               log: Log.NoteSQLite,
               type: .info,
               String(updatedAnnotation.nodeReference))
    }

    func deleteAnnotation(withReference reference: NodeReference) {
        let query = annotationTable.filter(nodeReference == String(describing: reference))
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
        let query = annotationTable.filter(ckRecordID == recordData)
        guard let row = try db.pluck(query) else {
            os_log("Unable to find record for CloudKit ID %s",
                   log: Log.NoteSQLite,
                   type: .error,
                   String(describing: recordID))
            return
        }
        
        let nodeReferenceStr = row[nodeReference]
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
        let query = annotationTable.filter(tags.like("%\(tag)%"))
        var results = [Annotation]()
        do {
            let rows = try db.prepare(query)
            results = rows.compactMap(rowToAnnotation)
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
