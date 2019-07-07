//
//  CloudKitProjects.swift
//  SAAo-SX
//
//  Created by Chaitanya Kanchan on 07/07/2019.
//  Copyright © 2019 Chaitanya Kanchan. All rights reserved.
//

import CDKSwiftOracc
import CloudKit
import Foundation
import os
import SQLite

extension SQLiteCatalogue {
    var cloudKitDatabase: CKDatabase {
        return CKContainer(identifier: "iCloud.me.chaidk.SAAo-SX").publicCloudDatabase
    }
    
    func initialiseTable() {
        guard !readOnly else {
            os_log("The connection is using a read-only catalogue",
                   log: Log.CatalogueSQLite,
                   type: .error)
            return
        }
        do {
            try db.run(Schema.textTable.create(ifNotExists: true) { t in
                t.column(Schema.textid, primaryKey: true)
                t.column(Schema.project)
                t.column(Schema.displayName)
                t.column(Schema.title)
                t.column(Schema.ancientAuthor)
                
                // Additional catalogue data
                t.column(Schema.chapterNumber)
                t.column(Schema.chapterName)
                t.column(Schema.museumNumber)
                
                //Archaeological data
                t.column(Schema.genre)
                t.column(Schema.material)
                t.column(Schema.period)
                t.column(Schema.provenience)
                
                //Publication data
                t.column(Schema.primaryPublication)
                t.column(Schema.publicationHistory)
                t.column(Schema.notes)
                t.column(Schema.credits)
                
                //Pleiades data
                t.column(Schema.pleiadesID)
                t.column(Schema.pleiadesCoordinateX)
                t.column(Schema.pleiadesCoordinateY)
                
                t.column(Schema.textStrings)
            })
            
            try db.run(Schema.textTable.createIndex(Schema.ancientAuthor))
            try db.run(Schema.textTable.createIndex(Schema.displayName))
            try db.run(Schema.textTable.createIndex(Schema.textid, unique: true))
            try db.run(Schema.textTable.createIndex(Schema.title))
        } catch let SQLite.Result.error(message, code, _){
            os_log("SQLite error initialising a writeable database, code %{public}d, message %{public}s",
                   log: Log.CatalogueSQLite,
                   type: .error,
                   code, message)
        } catch {
            os_log("Unspecified error creating table: %{public}s",
                   log: Log.CatalogueSQLite,
                   type: .error,
                   error.localizedDescription)
        }
    }
    
    func insert(_ volume: SAAVolume) {
        guard let id = cloudKitReferenceCache[volume] else {return}
        cloudKitDatabase.fetch(withRecordID: id) {[unowned self] record, error in
            if let error = error {
                os_log("Error retrieving volume with code %{public}s, error: ",
                       log: Log.CatalogueSQLite,
                       type: .error,
                       volume.code, error.localizedDescription)
            } else if let record = record,
                let downloadedVolumeFile = record["data"] as? CKAsset,
                let dbUrl = downloadedVolumeFile.fileURL,
                let temporaryDatabase = SQLiteCatalogue(url: dbUrl, readonly: true),
                let rows = try? temporaryDatabase.db.prepare(Schema.selectAll(withStrings: true)) {
                rows.forEach {
                    do {
                        try $0.insertInto(self.db)
                        os_log("Added db entry for id %{public}s",
                               log: Log.CatalogueSQLite,
                               type: .info,
                               $0[Schema.textid])
                    } catch let SQLite.Result.error(message, code, _){
                        os_log("Error adding db entry, code %{public}d, message %{public}s",
                               log: Log.CatalogueSQLite,
                               type: .error,
                               code, message)
                    } catch {
                        os_log("Unspecified error adding db entry: %{public}s",
                               log: Log.CatalogueSQLite,
                               type: .error,
                               error.localizedDescription)
                    }
                }
                
                let notification = Notification(name: Notification.Name("downloadedVolumesDidChange"), userInfo: ["volume": volume.code, "op": "add"])
                NotificationCenter.default.post(notification)
            }
        }
    }
    
    func delete(_ volume: SAAVolume) throws {
        let query = Schema.textTable.filter(Schema.project == volume.path)
        try db.run(query.delete())
        try db.execute("VACUUM;")
        let notification = Notification(name: Notification.Name("downloadedVolumesDidChange"), userInfo: ["volume": volume.code, "op": "delete"])
        NotificationCenter.default.post(notification)
    }
    
    func getRecordIDs() {
        let pred = NSPredicate(value: true)
        let query = CKQuery(recordType: "Project", predicate: pred)
        let operation = CKQueryOperation(query: query)
        var dict = [SAAVolume: CKRecord.ID]()
        operation.desiredKeys = ["code"]
        operation.recordFetchedBlock = { record in
            guard let code = record["code"] as? String,
                let volume = SAAVolume(code: code) else {return}
                dict[volume] = record.recordID
        }
        operation.queryCompletionBlock = { [weak self] _, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                DispatchQueue.main.async { [weak self] in
                    self?.cloudKitReferenceCache = dict
                }
            }
            
        }
        cloudKitDatabase.add(operation)
    }
    
    convenience init?(readOnly: Bool) {
        switch readOnly {
        case false:
            let supportURL = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                                 .userDomainMask,
                                                                 true).first!
            let url = URL(fileURLWithPath: supportURL, isDirectory: true)
                .appendingPathComponent("writeableTextDB")
                .appendingPathExtension("sqlite3")
            
            self.init(url: url, readonly: false)
            self.initialiseTable()
            self.getRecordIDs()
        case true:
            self.init() // Initialises with bundle database
        }
    }
}

extension Row {
    func insertInto(_ db: Connection) throws {
        try db.run(SQLiteCatalogue.Schema.textTable.insert(
            SQLiteCatalogue.Schema.textid <- self[SQLiteCatalogue.Schema.textid],
            SQLiteCatalogue.Schema.project <- self[SQLiteCatalogue.Schema.project],
            SQLiteCatalogue.Schema.displayName <- self[SQLiteCatalogue.Schema.displayName],
            SQLiteCatalogue.Schema.title <- self[SQLiteCatalogue.Schema.title],
            SQLiteCatalogue.Schema.ancientAuthor <- self[SQLiteCatalogue.Schema.ancientAuthor],
            SQLiteCatalogue.Schema.chapterNumber <- self[SQLiteCatalogue.Schema.chapterNumber],
            SQLiteCatalogue.Schema.chapterName <- self[SQLiteCatalogue.Schema.chapterName],
            SQLiteCatalogue.Schema.museumNumber <- self[SQLiteCatalogue.Schema.museumNumber],
            SQLiteCatalogue.Schema.genre <- self[SQLiteCatalogue.Schema.genre],
            SQLiteCatalogue.Schema.material <- self[SQLiteCatalogue.Schema.material],
            SQLiteCatalogue.Schema.period <- self[SQLiteCatalogue.Schema.period],
            SQLiteCatalogue.Schema.provenience <- self[SQLiteCatalogue.Schema.provenience],
            SQLiteCatalogue.Schema.primaryPublication <- self[SQLiteCatalogue.Schema.primaryPublication],
            SQLiteCatalogue.Schema.publicationHistory <- self[SQLiteCatalogue.Schema.publicationHistory],
            SQLiteCatalogue.Schema.notes <- self[SQLiteCatalogue.Schema.notes],
            SQLiteCatalogue.Schema.credits <- self[SQLiteCatalogue.Schema.credits],
            SQLiteCatalogue.Schema.pleiadesID <- self[SQLiteCatalogue.Schema.pleiadesID],
            SQLiteCatalogue.Schema.pleiadesCoordinateX <- self[SQLiteCatalogue.Schema.pleiadesCoordinateX],
            SQLiteCatalogue.Schema.pleiadesCoordinateY <- self[SQLiteCatalogue.Schema.pleiadesCoordinateY],
            SQLiteCatalogue.Schema.textStrings <- self[SQLiteCatalogue.Schema.textStrings]
        ))
    }
}
