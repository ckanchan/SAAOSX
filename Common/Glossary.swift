//
//  GlossaryController.swift
//  CDKOraccControllers
//
//  Created by Chaitanya Kanchan on 23/02/2018.
//

import Foundation
import CDKSwiftOracc
import SQLite
import os

final public class Glossary {
    lazy var db: Connection = {
        let path = Bundle.main.resourcePath! + "/SAAO_CompleteGlossary.sqlite3"
        return try! Connection(path, readonly: true)
    }()

    let id = Expression<String>("id")
    let xisInstances = Expression<String>("xisInstances")
    let headWord = Expression<String>("headword")
    let citationForm = Expression<String>("cf")
    let guideWord = Expression<String?>("gw")
    let partOfSpeech = Expression<String?>("pos")
    let instanceCount = Expression<String?>("icount")
    let forms = Expression<String?>("forms")
    let norms = Expression<String?>("norms")
    let senses = Expression<String?>("senses")

    let entries = Table("entries")
    let instances = Table("instances")

    public var glossaryCount: Int {
        return try! db.scalar(entries.count)
    }

    public func searchDatabase(_ searchQuery: String) -> [(Int, String, String)] {
        let query: Table

        if searchQuery.prefix(3) == "cf:" {
            let cf = String(searchQuery.dropFirst(3))
            query = entries.select(rowid, citationForm, guideWord).filter(citationForm.like(cf))
        } else {
            query = entries.select(rowid, citationForm, guideWord).filter(headWord.like("%\(searchQuery)%"))
        }

        if let results = try? db.prepare(query) {
            let x = results.map({ row in return
                (Int(row[rowid]), row[citationForm], row[guideWord] ?? "")})

            return x
        } else {
            return []
        }
    }

    public func labelsForRow(row: Int) -> (String, String)? {
        let query = entries.select(citationForm, guideWord).filter(rowid == Int64(row))

        guard let row = try? db.pluck(query) else {return nil}

        return(cf: row[citationForm], gw: row[guideWord] ?? "")
    }

    public func entryForRow(row: Int) -> GlossaryEntry? {
        let query = entries.filter(rowid == Int64(row))
        do {
            guard let row = try? db.pluck(query)  else { return nil }
            let result: GlossaryEntry = try row.decode()
            return result
        } catch {
            os_log("Unable to get glossary entry, %{public}s",
                   log: Log.GlossarySQLite,
                   type: .error,
                   error.localizedDescription)
            
            return nil
        }
    }

    public func getXISReferences(_ searchQuery: String) -> [String]? {
        let iQ = instances.select(xisInstances).filter(headWord.like(searchQuery))

        guard let instanceResult = try? db.prepare(iQ) else { return nil }
        var referenceStrings = [String]()
        for instanceRow in instanceResult {
            let references = instanceRow[xisInstances]
            let strings = references.split(separator: ",")
                .map({String($0)})
                .map({String($0.trimmingCharacters(in: .whitespacesAndNewlines))})
                .filter({$0.count > 6})

            referenceStrings.append(contentsOf: strings)

        }

        return referenceStrings
    }
    
    public func getNameForId(_ idToQuery: String) -> String? {
        let query = entries.select(guideWord).filter(id == idToQuery)
        guard let row = try? db.pluck(query),
            let guideWord = row[guideWord]
            else {return nil}
        return guideWord
    }
    
    public func getIDforName(_ nameToQuery: String) -> String? {
        let query = entries.select(id).filter(citationForm == nameToQuery)
        guard let row = try? db.pluck(query) else {return nil} 
        return row[id]
    }

    public init() {

    }
}
