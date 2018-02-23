//
//  PinnedTextController.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 19/02/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Cocoa
import OraccJSONtoSwift
import SQLite


class PinnedTextController: CatalogueProvider {
    let db: Connection
    var tableViews: NSHashTable = NSHashTable<ProjectListViewController>.weakObjects()
    
    var textCount: Int {
        return try! db.scalar(PinnedTextController.pinnedTextTable.count)
    }
    
    var texts: [OraccCatalogEntry] {
        return self.getCatalogueEntries() ?? []
    }
    
    let name: String = "Pinned Texts"

    
    //Column Definitions
    static let pinnedTextTable = Table("PinnedTexts")
    
    static let id = Expression<String>("id")
    static let project = Expression<String>("project")
    static let displayName = Expression<String>("DisplayName")
    static let title = Expression<String>("Title")
    static let ancientAuthor = Expression<String?>("Ancient Author")
    static let textStrings = Expression<Data>("Text")

    
    class func initialiseTable(on db: Connection) throws {
        try db.run(pinnedTextTable.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(project)
            t.column(displayName)
            t.column(title)
            t.column(ancientAuthor)
            t.column(textStrings)
        })
    }
    
    func contains(textID: String) -> Bool? {
        guard let result = try? db.scalar(PinnedTextController.pinnedTextTable.filter(PinnedTextController.id == textID).count) else {return nil}
        
        if result > 0 {
            return true
        } else {
            return false
        }
    }

    func getCatalogueEntries() -> [OraccCatalogEntry]? {
        let query = PinnedTextController.pinnedTextTable.select(
            PinnedTextController.id,
            PinnedTextController.displayName,
            PinnedTextController.ancientAuthor,
            PinnedTextController.title,
            PinnedTextController.project
        )
        
        guard let rows = try? db.prepare(query) else { return nil }
        let entries = rows.map { row in return OraccCatalogEntry.initFromSaved(id: row[PinnedTextController.id], displayName: row[PinnedTextController.displayName], ancientAuthor: row[PinnedTextController.ancientAuthor], title: row[PinnedTextController.title], project: row[PinnedTextController.project])
        }
        
        return entries
    }
    
    
    func save(entry: OraccCatalogEntry, strings: TextEditionStringContainer) throws {
        let archiver = NSKeyedArchiver()
        strings.encode(with: archiver)
        let data = archiver.encodedData
        
        
        do {
        try db.run(PinnedTextController.pinnedTextTable.insert(
            PinnedTextController.id <- entry.id,
            PinnedTextController.displayName <- entry.displayName,
            PinnedTextController.title <- entry.title,
            PinnedTextController.ancientAuthor <- entry.ancientAuthor,
            PinnedTextController.textStrings <- data,
            PinnedTextController.project <- entry.project
        ))
        } catch let Result.error(message: message, code: code, statement: statement) where code == SQLITE_CONSTRAINT {
            print("Item already exists in database: \(message), \(String(describing: statement)), \(entry.id)")
        }
        
        if tableViews.count != 0 {
            tableViews.allObjects.forEach {
                $0.catalogueEntryView.reloadData()
            }
        }
        
    }

    func getRowDetails(at rowID: Int) -> (String, String, String)? {
        let rowID = Int64(rowID)
        let query = PinnedTextController.pinnedTextTable.select(PinnedTextController.id, PinnedTextController.displayName, PinnedTextController.displayName, PinnedTextController.title).filter(rowid == rowID)
        
        guard let row = try? db.pluck(query) else { return nil }
        
        return (row![PinnedTextController.displayName], row![PinnedTextController.title], row![PinnedTextController.id])
        
    }
    
    func getCatalogueEntry(at rowID: Int) -> OraccCatalogEntry? {
        let query = PinnedTextController.pinnedTextTable.select(
            PinnedTextController.id,
            PinnedTextController.displayName,
            PinnedTextController.ancientAuthor,
            PinnedTextController.title,
            PinnedTextController.project
        ).filter(rowid == Int64(rowID))
        
        guard let r = try? db.pluck(query) else { return nil }
        
        guard let row = r else { return nil}
        
        let catalogueEntry = OraccCatalogEntry.initFromSaved(id: row[PinnedTextController.id], displayName: row[PinnedTextController.displayName], ancientAuthor: row[PinnedTextController.ancientAuthor], title: row[PinnedTextController.title], project: row[PinnedTextController.project])
        
        return catalogueEntry
    }
    
    func getTextStrings(_ id: String) -> TextEditionStringContainer? {
        let query = PinnedTextController.pinnedTextTable.select(PinnedTextController.textStrings).filter(PinnedTextController.id == id)
        
        guard let encodedStringRow = try? db.pluck(query) else {return nil}
        guard let row = encodedStringRow else {return nil}
        let encodedString = row[PinnedTextController.textStrings]
        
//        let decoder = JSONDecoder()
//        guard let stringContainer = try? decoder.decode(TextEditionStringContainer.self, from: encodedString.data(using: .utf8)!) else {return nil}
        
        let decoder = NSKeyedUnarchiver(forReadingWith: encodedString)
        guard let stringContainer = TextEditionStringContainer(coder: decoder) else {return nil}
        
        return stringContainer

        
    }
    
    init() throws {
        let path = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("pinnedTexts").appendingPathExtension("sqlite3")
        self.db = try Connection(path.path)
        try PinnedTextController.initialiseTable(on: self.db)
    }
}
