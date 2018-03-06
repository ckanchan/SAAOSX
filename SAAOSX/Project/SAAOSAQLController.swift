//
//  SAAOSAQLController.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 24/02/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Cocoa
import SQLite
import OraccJSONtoSwift

class SAAOSQLController: CatalogueProvider {
    
    let textTable = Table("texts")
    let id = Expression<String>("id")
    let project = Expression<String>("project")
    let displayName = Expression<String>("DisplayName")
    let title = Expression<String>("Title")
    let ancientAuthor = Expression<String?>("Ancient Author")
    let textStrings = Expression<Data>("Text")
    
    var count: Int {
        return self.textCount
    }
    
    func text(at row: Int) -> OraccCatalogEntry? {
        return getEntryAt(row: row)
    }
    
    func search(_ string: String) -> [OraccCatalogEntry] {
        let searchString = "%\(string)%"
        let query = textTable.select(id, displayName, title, ancientAuthor, project).filter(id.like(searchString) || displayName.like(searchString) || title.like(searchString) || ancientAuthor.like(searchString))
        
        if let rows = try? db.prepare(query) {
            let entries = rows.map { row in return OraccCatalogEntry.initFromSaved(id: row[id], displayName: row[displayName], ancientAuthor: row[ancientAuthor], title: row[title], project: row[project])
            }
            return entries
        } else {
            return []
        }
    }
  
    let db: Connection
    
    public var textCount: Int {
        return try! db.scalar(textTable.count)
    }
    
    var name: String = "Database"
    
    
    
    public func getCatalogueEntries() -> [OraccCatalogEntry]? {
        let query = textTable.select(id, displayName,ancientAuthor, title, project)
        
        guard let rows = try? db.prepare(query) else { return nil }
        let entries = rows.map { row in return OraccCatalogEntry.initFromSaved(id: row[id], displayName: row[displayName], ancientAuthor: row[ancientAuthor], title: row[title], project: row[project])
        }
        
        return entries
    }
    
    
    func getEntryAt(row: Int) -> OraccCatalogEntry? {
        let query = textTable.select(rowid).order(displayName).limit(1, offset: row)
        guard let qr = try? db.pluck(query) else {return nil}
        guard let qrow = qr else {return nil}
        let rowId = qrow[rowid]
        let entryQuery = textTable.select(id, displayName, ancientAuthor, title, project).filter(rowid == rowId)
        guard let r = try? db.pluck(entryQuery) else {return nil}
        
        guard let row = r else {return nil}
        return OraccCatalogEntry.initFromSaved(id: row[id], displayName: row[displayName], ancientAuthor: row[ancientAuthor], title: row[title], project: row[project])
    }
    
    func getEntryFor(id cdliID: String) -> OraccCatalogEntry? {
        let query = textTable.select(id, displayName,ancientAuthor, title, project).filter(id == cdliID)
        guard let r = try? db.pluck(query) else {return nil}
        guard let row = r else {return nil}
        return OraccCatalogEntry.initFromSaved(id: row[id], displayName: row[displayName], ancientAuthor: row[ancientAuthor], title: row[title], project: row[project])
    }
    
    
    func getTextStrings(_ textId: String) -> TextEditionStringContainer? {
        let query = textTable.select(textStrings).filter(id == textId)
        
        guard let encodedStringRow = try? db.pluck(query) else {return nil}
        guard let row = encodedStringRow else {return nil}
        let encodedString = row[textStrings]
        
        let decoder = NSKeyedUnarchiver(forReadingWith: encodedString)
        guard let stringContainer = TextEditionStringContainer(coder: decoder) else {return nil}
        
        return stringContainer
    }
    
    init? () {
        guard let bundle = Bundle.main.resourceURL else {return nil}
        let url = bundle.appendingPathComponent("SAA_Lemmatised").appendingPathExtension("sqlite3").path
        do {
            let connection = try Connection(url, readonly: true)
            self.db = connection
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
