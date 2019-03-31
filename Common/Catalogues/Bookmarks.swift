//
//  BookmarkedTextController.swift
//  CDKOraccControllers
//
//  Created by Chaitanya Kanchan on 23/02/2018.
//

import Foundation
import CDKSwiftOracc
import SQLite

/// Conform to this protocol to allow BookmarkedTextController to refresh the table view when entries are added or removed from the database.
@objc public protocol BookmarkDisplaying: AnyObject {
    func refreshTableView()
}

/// Responsible for saving and loading bookmarked texts to the SQLite store.
final public class Bookmarks: CatalogueProvider {
    public let source: CatalogueSource = .bookmarks

    public lazy var texts: [OraccCatalogEntry] = {
        return self.getCatalogueEntries() ?? []
    }()

    static let Update = Notification.Name("BookmarksUpdated")

    public func search(_ string: String) -> [OraccCatalogEntry] {
        let searchString = "%\(string)%"
        let query = Bookmarks.bookmarks.select(
            Bookmarks.id,
            Bookmarks.displayName,
            Bookmarks.ancientAuthor,
            Bookmarks.title,
            Bookmarks.project
            ).filter(
                Bookmarks.id.like(searchString) ||
                    Bookmarks.displayName.like(searchString)
        )

        if let results = try? db.prepare(query) {
            let x = results.map({(row: Row) -> OraccCatalogEntry in
                let textID = TextID.init(stringLiteral: row[Bookmarks.id])
                return OraccCatalogEntry(id: textID,
                                  displayName: row[Bookmarks.displayName],
                                  ancientAuthor: row[Bookmarks.ancientAuthor],
                                  title: row[Bookmarks.title],
                                  project: row[Bookmarks.project])
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
    public var textCount: Int? { return try? db.scalar(Bookmarks.bookmarks.count) }

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
        guard let result = try? db.scalar(Bookmarks.bookmarks.filter(Bookmarks.id == textID).count) else {return nil}

        if result > 0 {
            return true
        } else {
            return false
        }
    }

    public func getCatalogueEntries() -> [OraccCatalogEntry]? {
        let query = Bookmarks.bookmarks.select(
            Bookmarks.id,
            Bookmarks.displayName,
            Bookmarks.ancientAuthor,
            Bookmarks.title,
            Bookmarks.project
        )

        guard let rows = try? db.prepare(query) else { return nil }
        let entries = rows.map { (row: Row) -> OraccCatalogEntry in
            let textID = TextID.init(stringLiteral: row[Bookmarks.id])
            return OraccCatalogEntry(id: textID,
                                     displayName: row[Bookmarks.displayName],
                                     ancientAuthor: row[Bookmarks.ancientAuthor],
                                     title: row[Bookmarks.title],
                                     project: row[Bookmarks.project])}

        return entries
    }

    public func save(entry: OraccCatalogEntry, strings: TextEditionStringContainer) throws {
        let archiver = NSKeyedArchiver()
        strings.encode(with: archiver)
        let data = archiver.encodedData

        do {
            try db.run(Bookmarks.bookmarks.insert(
                Bookmarks.id <- entry.id.description,
                Bookmarks.displayName <- entry.displayName,
                Bookmarks.title <- entry.title,
                Bookmarks.ancientAuthor <- entry.ancientAuthor,
                Bookmarks.textStrings <- data,
                Bookmarks.project <- entry.project
            ))
        } catch let Result.error(message: message, code: code, statement: statement) where code == SQLITE_CONSTRAINT {
            print("Item already exists in database: \(message), \(String(describing: statement)), \(entry.id)")
        }

        entry.indexItem()
        postNotification()


    }

    public func remove(at row: Int) {
        let row = Int64(row)
        let query = Bookmarks.bookmarks.select(rowid == row)
        do {
            let result = try db.run(query.delete())
            print("Deleted", result)
            postNotification()
        } catch {
            print(error)
        }

    }

    func postNotification() {
         let notification = Notification.init(name: Bookmarks.Update, object: self, userInfo: nil)
        NotificationCenter.default.post(notification)
    }

    public func getRowDetails(at rowID: Int) -> (String, String, String)? {
        let rowID = Int64(rowID)
        let query = Bookmarks.bookmarks.select(Bookmarks.id, Bookmarks.displayName, Bookmarks.displayName, Bookmarks.title).filter(rowid == rowID)

        guard let row = try? db.pluck(query) else {return nil}

        return (row[Bookmarks.displayName], row[Bookmarks.title], row[Bookmarks.id])

    }

    public func getCatalogueEntry(at rowID: Int) -> OraccCatalogEntry? {
        let query = Bookmarks.bookmarks.select(
            Bookmarks.id,
            Bookmarks.displayName,
            Bookmarks.ancientAuthor,
            Bookmarks.title,
            Bookmarks.project
            ).filter(rowid == Int64(rowID))

        guard let r = ((try? db.pluck(query)) as Row??) else { return nil }

        guard let row = r else { return nil}
        let textID = TextID.init(stringLiteral: row[Bookmarks.id])
        
        let catalogueEntry = OraccCatalogEntry(id: textID,
                                               displayName: row[Bookmarks.displayName],
                                               ancientAuthor: row[Bookmarks.ancientAuthor],
                                               title: row[Bookmarks.title],
                                               project: row[Bookmarks.project])

        return catalogueEntry
    }

    public func getCatalogueEntry(forID id: String) -> OraccCatalogEntry? {
        let query = Bookmarks.bookmarks.select(
            Bookmarks.id,
            Bookmarks.displayName,
            Bookmarks.ancientAuthor,
            Bookmarks.title,
            Bookmarks.project
            ).filter(Bookmarks.id == id)

        guard let row = try? db.pluck(query) else {return nil}
        let textID = TextID.init(stringLiteral: row[Bookmarks.id])

        let catalogueEntry = OraccCatalogEntry(id: textID,
                                               displayName: row[Bookmarks.displayName],
                                               ancientAuthor: row[Bookmarks.ancientAuthor],
                                               title: row[Bookmarks.title],
                                               project: row[Bookmarks.project])

        return catalogueEntry
    }

    public func getTextStrings(_ id: String) -> TextEditionStringContainer? {
        let query = Bookmarks.bookmarks.select(Bookmarks.textStrings).filter(Bookmarks.id == id)

        guard let row = try? db.pluck(query) else {return nil}
        let encodedString = row[Bookmarks.textStrings]

        let decoder = NSKeyedUnarchiver(forReadingWith: encodedString)
        guard let stringContainer = TextEditionStringContainer(coder: decoder) else {return nil}

        return stringContainer

    }

    public func remove(entry: OraccCatalogEntry) {
        let query = Bookmarks.bookmarks.select(rowid).filter(Bookmarks.id == entry.id.description)

        guard let row = try? db.pluck(query) else {return} 
        let rowID = row[rowid]
        remove(at: Int(rowID))
        entry.deindexItem()
    }

    public init() throws {
        let paths = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let appSupportPath = paths[0].appendingPathComponent(Bundle.main.bundleIdentifier!, isDirectory: true)
        if !FileManager.default.fileExists(atPath: appSupportPath.path) {
            try FileManager.default.createDirectory(at: appSupportPath, withIntermediateDirectories: true, attributes: nil)
        }

        let path = appSupportPath.appendingPathComponent("bookmarks").appendingPathExtension("sqlite3")
        self.db = try Connection(path.path)
        try Bookmarks.initialiseTable(on: self.db)
    }
}
