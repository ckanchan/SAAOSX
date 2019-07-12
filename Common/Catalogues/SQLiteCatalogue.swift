//
//  SQLiteCatalogue.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 24/02/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Foundation
import SQLite
import CDKSwiftOracc
import os
import CloudKit.CKRecord

final class SQLiteCatalogue {
    // MARK: Instance Variables
    let db: Connection
    let readOnly: Bool
    
    let url: URL
    private lazy var textMetadataCache: [OraccCatalogEntry] = {
        self.getCatalogueEntries() ?? []
    }()
    
    var cloudKitReferenceCache: [SAAVolume: CKRecord.ID] = [:]
    
    public var textCount: Int {
        return try! db.scalar(Schema.textTable.count)
    }
    
    public func getCatalogueEntries() -> [OraccCatalogEntry]? {
        let query = Schema.selectAll()
        guard let rows = try? db.prepare(query) else { return nil }
        return rows.map(OraccCatalogEntry.init)
    }
    
    public func getSearchCollection(term: String, references: [String]) -> TextSearchCollection {
        var results = [OraccCatalogEntry?]()
        for reference in references {
            let stringID = String(reference.prefix(while: {$0 != "."}))
            let textID = TextID.init(stringLiteral: stringID)
            results.append(self.getEntryFor(id: textID))
        }
        
        var members = [TextID: OraccCatalogEntry]()
        for result in results.compactMap({$0}) {
            members[result.id] = result
        }
        
        return TextSearchCollection(searchTerm: term, members: members, searchIDs: references)
    }
    
    func getEntryAt(row: Int) -> OraccCatalogEntry? {
        guard row < texts.count else {return nil}
        return texts[row]
    }
    
    func getEntryFor(id cdliID: TextID) -> OraccCatalogEntry? {
        let query = Schema
            .selectAll()
            .filter(Schema.textid == cdliID.description)
        
        guard let row = try? db.pluck(query) else {return nil}
        return OraccCatalogEntry(row: row)
    }
    
    func entriesForVolume(_ volume: SAAVolume) -> [OraccCatalogEntry] {
        let query = Schema
            .selectAll()
            .filter(Schema.project == volume.path)
        
        guard let rows = try? db.prepare(query) else { return [] }
        return rows.map(OraccCatalogEntry.init)
    }
    
    func getTextStrings(_ textId: TextID) -> TextEditionStringContainer? {
        let query = Schema.selectTextID().filter(Schema.textid == textId.description)
        do {
            guard let row = try db.pluck(query) else {return nil}
            let encodedString = row[Schema.textStrings]
            let decoder = try NSKeyedUnarchiver(forReadingFrom: encodedString)
            decoder.requiresSecureCoding = false
            let stringContainer = TextEditionStringContainer(coder: decoder)
            return stringContainer
        } catch let SQLite.Result.error(message, code, _) {
            os_log("SQLite error retrieving strings, code %{public}d, message %{public}s",
                   log: Log.CatalogueSQLite,
                   type: .error,
                   code, message)
            return nil
        } catch {
            os_log("Unable to decode text strings: %{public}s",
                   log: Log.CatalogueSQLite,
                   type: .error,
                   error.localizedDescription)
            return nil
        }
    }
    
    convenience init? () {
        guard let url = Bundle.main.url(forResource: "SAA_Lemmatised", withExtension: "sqlite3") else {return nil}
        self.init(url: url)
    }
    
    init?(url: URL, readonly: Bool = true) {
        do {
            self.url = url
            self.readOnly = readonly
            let connection = try Connection(url.path, readonly: readOnly)
            self.db = connection
        } catch {
            os_log("Fatal error initialising catalogue: %s",
                   log: Log.CatalogueSQLite,
                   type: .error,
                   error.localizedDescription)
            return nil
        }
    }
}

extension SQLiteCatalogue: CatalogueProvider {
    public var name: String { return "Database" }
    public var count: Int { return self.textCount }
    public var texts: [OraccCatalogEntry] { return self.textMetadataCache }
    public var source: CatalogueSource {return .sqlite}
    
    func text(at row: Int) -> OraccCatalogEntry? {
        return getEntryAt(row: row)
    }
    
    func search(_ string: String) -> [OraccCatalogEntry] {
        let searchString = "%\(string)%"
        let query = Schema.selectAll()
            .filter(Schema.textid.like(searchString)
                || Schema.displayName.like(searchString)
                || Schema.title.like(searchString)
                || Schema.ancientAuthor.like(searchString))
        
        if let rows = try? db.prepare(query) {
            return rows.map(OraccCatalogEntry.init)
        } else {
            return []
        }
    }
}

extension OraccCatalogEntry {
    init(row: Row) {
        let coordinate: (Double, Double)?
        if let x = row[SQLiteCatalogue.Schema.pleiadesCoordinateX], let y = row[SQLiteCatalogue.Schema.pleiadesCoordinateY] {
            coordinate = (x, y)
        } else {
            coordinate = nil
        }
        
        self.init(displayName: row[SQLiteCatalogue.Schema.displayName],
                  title: row[SQLiteCatalogue.Schema.title],
                  id: row[SQLiteCatalogue.Schema.textid],
                  ancientAuthor: row[SQLiteCatalogue.Schema.ancientAuthor],
                  project: row[SQLiteCatalogue.Schema.project],
                  chapterNumber: row[SQLiteCatalogue.Schema.chapterNumber],
                  chapterName: row[SQLiteCatalogue.Schema.chapterName],
                  genre: row[SQLiteCatalogue.Schema.genre],
                  material: row[SQLiteCatalogue.Schema.material],
                  period: row[SQLiteCatalogue.Schema.period],
                  provenience: row[SQLiteCatalogue.Schema.provenience],
                  primaryPublication: row[SQLiteCatalogue.Schema.primaryPublication],
                  museumNumber: row[SQLiteCatalogue.Schema.museumNumber],
                  publicationHistory: row[SQLiteCatalogue.Schema.publicationHistory],
                  notes: row[SQLiteCatalogue.Schema.notes],
                  pleiadesID: row[SQLiteCatalogue.Schema.pleiadesID],
                  pleiadesCoordinate: coordinate,
                  credits: row[SQLiteCatalogue.Schema.credits])
    }
}

