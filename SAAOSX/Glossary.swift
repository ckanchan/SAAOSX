//
//  GlossaryController.swift
//  CDKOraccControllers
//
//  Created by Chaitanya Kanchan on 23/02/2018.
//

import Foundation
import CDKSwiftOracc
import SQLite

public class Glossary {
    lazy var db: Connection = {
        let path = Bundle.main.resourcePath! + "/SAAO_CompleteGlossary.sqlite3"
        return try! Connection(path, readonly: true)
    }()
    
    let id = Expression<String>("id")
    let xisKey = Expression<String>("xis")
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
        
        guard let r = try? db.pluck(query) else {return nil}
        
        guard let row = r else {return nil}
        
        return(cf: row[citationForm], gw: row[guideWord] ?? "")
    }
    
    public func entryForRow(row: Int) -> GlossaryEntry? {
        let query = entries.filter(rowid == Int64(row))
        guard let r = try? db.pluck(query) else {return nil}
        
        guard let row = r else {return nil}
        
        guard let result: GlossaryEntry = try? row.decode() else {return nil}
        
        return result
        
    }
    
    public func getXISReferences(_ searchQuery: String) -> [String]? {
        guard searchQuery.prefix(3) == "cf:" else { return nil}
        let cf = String(searchQuery.dropFirst(3))
        let query = entries.select(rowid, xisKey).filter(citationForm.like(cf))
        
        guard let result = try? db.pluck(query) else { return nil }
        guard let row = result else {return nil}
        let xisRef = row[xisKey]
        
        let iQ = instances.select(xisInstances).filter(xisKey.like(xisRef))
        guard let instanceResult = try? db.pluck(iQ) else { return nil }
        guard let instanceRow = instanceResult else {return nil }
        let references = instanceRow[xisInstances]
        let referenceStrings = references.split(separator: ",")
            .map({String($0)})
            .map({String($0.trimmingCharacters(in: .whitespacesAndNewlines))})
            .filter({$0.count > 6})
            
        return referenceStrings
    }
    
    
    public init(){
        
    }
}
