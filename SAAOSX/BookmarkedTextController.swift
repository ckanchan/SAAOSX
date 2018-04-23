//
//  BookmarkedTextController.swift
//  CDKOraccControllers
//
//  Created by Chaitanya Kanchan on 23/02/2018.
//

import Foundation
import CDKSwiftOracc
import SQLite

/// Conform to this protocol to allow BookmarkedTextController to send messages when entries are added or removed from its database.
@objc public protocol BookmarkDisplaying: AnyObject {
    func refreshTableView()
}

/// Responsible for saving and loading bookmarked texts to the SQLite store.
public class BookmarkedTextController: CatalogueProvider {
    public var source: CatalogueSource = .bookmarks
    
    public lazy var texts: [OraccCatalogEntry] = {
        return self.getCatalogueEntries() ?? []
    }()
    
    
    static let Update = Notification.Name.init("BookmarksUpdated")
    
    public func search(_ string: String) -> [OraccCatalogEntry] {
        let searchString = "%\(string)%"
        let query = BookmarkedTextController.bookmarks.select(
            BookmarkedTextController.id,
            BookmarkedTextController.displayName,
            BookmarkedTextController.ancientAuthor,
            BookmarkedTextController.title,
            BookmarkedTextController.project
            ).filter(
                BookmarkedTextController.id.like(searchString) ||
                    BookmarkedTextController.displayName.like(searchString)
        )
        
        if let results = try? db.prepare(query) {
            let x = results.map({row in
                return OraccCatalogEntry.initFromSaved(id: row[BookmarkedTextController.id], displayName: row[BookmarkedTextController.displayName], ancientAuthor: row[BookmarkedTextController.ancientAuthor], title: row[BookmarkedTextController.title], project: row[BookmarkedTextController.project])
            })
            return x
        } else {
            return []
        }
    }
    
    public func text(at row: Int) -> OraccCatalogEntry? {
        let row = row + 1
        return self.getCatalogueEntry(at: row)
    }
    
    
    // MARK :- Protocol conformances
    public let name: String = "Bookmarked Texts"
    public var count: Int {
        return self.textCount ?? 0
    }
    
    let db: Connection
    
    // Bookmarked text count. Returns nil if unable to access the database.
    public var textCount: Int? { return try? db.scalar(BookmarkedTextController.bookmarks.count) }
    
    
    // MARK: - Table Definitions
    static let bookmarks = Table("Bookmarks")
    
    static let id = Expression<String>("id")
    static let project = Expression<String>("project")
    static let displayName = Expression<String>("DisplayName")
    static let title = Expression<String>("Title")
    static let ancientAuthor = Expression<String?>("Ancient Author")
    static let textStrings = Expression<Data>("Text")
    
    static func initialiseTable(on db: Connection) throws {
        try db.run(bookmarks.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(project)
            t.column(displayName)
            t.column(title)
            t.column(ancientAuthor)
            t.column(textStrings)
        })
    }
    
    public func contains(textID: String) -> Bool? {
        guard let result = try? db.scalar(BookmarkedTextController.bookmarks.filter(BookmarkedTextController.id == textID).count) else {return nil}
        
        if result > 0 {
            return true
        } else {
            return false
        }
    }
    
    public func getCatalogueEntries() -> [OraccCatalogEntry]? {
        let query = BookmarkedTextController.bookmarks.select(
            BookmarkedTextController.id,
            BookmarkedTextController.displayName,
            BookmarkedTextController.ancientAuthor,
            BookmarkedTextController.title,
            BookmarkedTextController.project
        )
        
        guard let rows = try? db.prepare(query) else { return nil }
        let entries = rows.map { row in return OraccCatalogEntry.initFromSaved(id: row[BookmarkedTextController.id], displayName: row[BookmarkedTextController.displayName], ancientAuthor: row[BookmarkedTextController.ancientAuthor], title: row[BookmarkedTextController.title], project: row[BookmarkedTextController.project])
        }
        
        return entries
    }
    
    public func save(entry: OraccCatalogEntry, strings: TextEditionStringContainer) throws {
        let archiver = NSKeyedArchiver()
        strings.encode(with: archiver)
        let data = archiver.encodedData
        
        
        do {
            try db.run(BookmarkedTextController.bookmarks.insert(
                BookmarkedTextController.id <- entry.id,
                BookmarkedTextController.displayName <- entry.displayName,
                BookmarkedTextController.title <- entry.title,
                BookmarkedTextController.ancientAuthor <- entry.ancientAuthor,
                BookmarkedTextController.textStrings <- data,
                BookmarkedTextController.project <- entry.project
            ))
        } catch let Result.error(message: message, code: code, statement: statement) where code == SQLITE_CONSTRAINT {
            print("Item already exists in database: \(message), \(String(describing: statement)), \(entry.id)")
        }
        
        entry.indexItem()
        postNotification()

        
//        if tableViews.count != 0 {
//            tableViews.allObjects.forEach {
//                $0.refreshTableView()
//            }
//        }
        
    }
    
    public func remove(at row: Int) {
        let row = Int64(row)
        let query = BookmarkedTextController.bookmarks.select(rowid == row)
        do {
            let result = try db.run(query.delete())
            print("Deleted", result)
            postNotification()
//            if tableViews.count != 0 {
//                tableViews.allObjects.forEach {
//                    $0.refreshTableView()
//                }
//            }
            
        } catch {
            print(error)
        }
        
    }
    
    func postNotification() {
         let notification = Notification.init(name: BookmarkedTextController.Update, object: self, userInfo: nil)
        NotificationCenter.default.post(notification)
    }
    
    
    public func getRowDetails(at rowID: Int) -> (String, String, String)? {
        let rowID = Int64(rowID)
        let query = BookmarkedTextController.bookmarks.select(BookmarkedTextController.id, BookmarkedTextController.displayName, BookmarkedTextController.displayName, BookmarkedTextController.title).filter(rowid == rowID)
        
        guard let r = try? db.pluck(query) else { return nil }
        guard let row = r else {return nil}
        
        return (row[BookmarkedTextController.displayName], row[BookmarkedTextController.title], row[BookmarkedTextController.id])
        
    }
    
    public func getCatalogueEntry(at rowID: Int) -> OraccCatalogEntry? {
        let query = BookmarkedTextController.bookmarks.select(
            BookmarkedTextController.id,
            BookmarkedTextController.displayName,
            BookmarkedTextController.ancientAuthor,
            BookmarkedTextController.title,
            BookmarkedTextController.project
            ).filter(rowid == Int64(rowID))
        
        guard let r = try? db.pluck(query) else { return nil }
        
        guard let row = r else { return nil}
        
        let catalogueEntry = OraccCatalogEntry.initFromSaved(id: row[BookmarkedTextController.id], displayName: row[BookmarkedTextController.displayName], ancientAuthor: row[BookmarkedTextController.ancientAuthor], title: row[BookmarkedTextController.title], project: row[BookmarkedTextController.project])
        
        return catalogueEntry
    }
    
    public func getCatalogueEntry(forID id: String) -> OraccCatalogEntry? {
        let query = BookmarkedTextController.bookmarks.select(
            BookmarkedTextController.id,
            BookmarkedTextController.displayName,
            BookmarkedTextController.ancientAuthor,
            BookmarkedTextController.title,
            BookmarkedTextController.project
            ).filter(BookmarkedTextController.id == id)
        
        guard let r = try? db.pluck(query) else { return nil }
        
        guard let row = r else { return nil}
        
        let catalogueEntry = OraccCatalogEntry.initFromSaved(id: row[BookmarkedTextController.id], displayName: row[BookmarkedTextController.displayName], ancientAuthor: row[BookmarkedTextController.ancientAuthor], title: row[BookmarkedTextController.title], project: row[BookmarkedTextController.project])
        
        return catalogueEntry
    }
    
    public func getTextStrings(_ id: String) -> TextEditionStringContainer? {
        let query = BookmarkedTextController.bookmarks.select(BookmarkedTextController.textStrings).filter(BookmarkedTextController.id == id)
        
        guard let encodedStringRow = try? db.pluck(query) else {return nil}
        guard let row = encodedStringRow else {return nil}
        let encodedString = row[BookmarkedTextController.textStrings]
        
        let decoder = NSKeyedUnarchiver(forReadingWith: encodedString)
        guard let stringContainer = TextEditionStringContainer(coder: decoder) else {return nil}
        
        return stringContainer
        
    }
    
    public func remove(entry: OraccCatalogEntry) {
        let query = BookmarkedTextController.bookmarks.select(rowid).filter(BookmarkedTextController.id == entry.id)
        
        guard let r = try? db.pluck(query) else {return}
        guard let row = r else {return}
        let rowID = row[rowid]
        remove(at: Int(rowID))
        entry.deindexItem()
    }
    

    
    public init() throws {
        let paths = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let appSupportPath = paths[0].appendingPathComponent("SAAOSX", isDirectory: true)
        if !FileManager.default.fileExists(atPath: appSupportPath.path) {
            try FileManager.default.createDirectory(at: appSupportPath, withIntermediateDirectories: true, attributes: nil)
        }
        
        let path = paths[0].appendingPathComponent("SAAOSX").appendingPathComponent("bookmarks").appendingPathExtension("sqlite3")
       // let path = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("bookmarks").appendingPathExtension("sqlite3")
        self.db = try Connection(path.path)
        try BookmarkedTextController.initialiseTable(on: self.db)
    }
    
}
