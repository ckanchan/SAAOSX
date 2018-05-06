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

class SQLiteCatalogue: CatalogueProvider {
    let source: CatalogueSource = .sqlite
    
    let textid = Expression<String>("textid")
    let project = Expression<String>("project")
    let displayName = Expression<String>("display_name")
    let title = Expression<String>("title")
    let ancientAuthor = Expression<String?>("ancient_author")
    
    // Additional catalogue data
    let chapterNumber = Expression<Int?>("chapter_num")
    let chapterName = Expression<String?>("chapter_name")
    let museumNumber = Expression<String?>("museum_num")
    
    //Archaeological data
    let genre = Expression<String?>("genre")
    let material = Expression<String?>("material")
    let period = Expression<String?>("period")
    let provenience = Expression<String?>("provenience")
    
    
    //Publication data
    let primaryPublication = Expression<String?>("primary_publication")
    let publicationHistory = Expression<String?>("publication_history")
    let notes = Expression<String?>("notes")
    let credits = Expression<String?>("credits")
    
    
    // A place to encode TextEditionStringContainer with NSCoding
     let textStrings = Expression<Data>("Text")
    
    
    let textTable = Table("texts")
   
   
   
    
    var count: Int {
        return self.textCount
    }
    
    public lazy var texts: [OraccCatalogEntry] = {
        self.getCatalogueEntries() ?? []
    }()
    
    func text(at row: Int) -> OraccCatalogEntry? {
        return getEntryAt(row: row)
    }
    
    func search(_ string: String) -> [OraccCatalogEntry] {
        let searchString = "%\(string)%"
        let query = textTable.select(displayName, title, textid, ancientAuthor, project, chapterNumber, chapterName, genre, material, period, provenience, primaryPublication, museumNumber, publicationHistory, notes, credits).filter(textid.like(searchString) || displayName.like(searchString) || title.like(searchString) || ancientAuthor.like(searchString))
        
        if let rows = try? db.prepare(query) {
            let entries = rows.map { row in return OraccCatalogEntry(displayName: row[displayName], title: row[title], id: row[textid], ancientAuthor: row[ancientAuthor], project: row[project], chapterNumber: row[chapterNumber], chapterName: row[chapterName], genre: row[genre], material: row[material], period: row[period], provenience: row[provenience], primaryPublication: row[primaryPublication], museumNumber: row[museumNumber], publicationHistory: row[publicationHistory], notes: row[notes], credits: row[credits])}
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
        let query = textTable.select(displayName, title, textid, ancientAuthor, project, chapterNumber, chapterName, genre, material, period, provenience, primaryPublication, museumNumber, publicationHistory, notes, credits)
        
        guard let rows = try? db.prepare(query) else { return nil }
        let entries = rows.map { row in return OraccCatalogEntry(displayName: row[displayName], title: row[title], id: row[textid], ancientAuthor: row[ancientAuthor], project: row[project], chapterNumber: row[chapterNumber], chapterName: row[chapterName], genre: row[genre], material: row[material], period: row[period], provenience: row[provenience], primaryPublication: row[primaryPublication], museumNumber: row[museumNumber], publicationHistory: row[publicationHistory], notes: row[notes], credits: row[credits])}
        
        return entries
    }
    
    public func getSearchCollection(term: String, references: [String]) -> TextSearchCollection {
        var results = [OraccCatalogEntry?]()
        for reference in references {
            results.append(self.getEntryFor(id: String(reference.prefix(while:{$0 != "."}))))
        }
        
        var members = [String: OraccCatalogEntry]()
        for result in results.compactMap({$0}) {
            members[result.id] = result
        }

        
        return TextSearchCollection(searchTerm: term, members: members, searchIDs: references)
    }
    
    
    func getEntryAt(row: Int) -> OraccCatalogEntry? {
        guard row < texts.count else {return nil}
        return texts[row]
    }
    
    func getEntryFor(id cdliID: String) -> OraccCatalogEntry? {
        let query = textTable.select(displayName, title, textid, ancientAuthor, project, chapterNumber, chapterName, genre, material, period, provenience, primaryPublication, museumNumber, publicationHistory, notes, credits).filter(textid == cdliID)
        
        guard let r = try? db.pluck(query) else {return nil}
        guard let row = r else {return nil}
        return OraccCatalogEntry(displayName: row[displayName], title: row[title], id: row[textid], ancientAuthor: row[ancientAuthor], project: row[project], chapterNumber: row[chapterNumber], chapterName: row[chapterName], genre: row[genre], material: row[material], period: row[period], provenience: row[provenience], primaryPublication: row[primaryPublication], museumNumber: row[museumNumber], publicationHistory: row[publicationHistory], notes: row[notes], credits: row[credits])
    }
    
    
    func getTextStrings(_ textId: String) -> TextEditionStringContainer? {
        let query = textTable.select(textStrings).filter(textid == textId)
        
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
