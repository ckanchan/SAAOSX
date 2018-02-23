//
//  GlossaryController.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 17/02/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Foundation
import OraccJSONtoSwift
import SQLite

class GlossaryController {
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
    
    var glossaryCount: Int {
        return try! db.scalar(entries.count)
    }
    
    func searchDatabase(_ query: String) -> [(Int, String, String)] {
        let query = entries.select(rowid, citationForm, guideWord).filter(headWord.like("%\(query)%"))
        
        if let results = try? db.prepare(query) {
            let x = results.map({ row in return
                (Int(row[rowid]), row[citationForm], row[guideWord] ?? "")})
            
            return x
        } else {
            return []
        }
    }
    
    func labelsForRow(row: Int) -> (String, String)? {
        let query = entries.select(citationForm, guideWord).filter(rowid == Int64(row))
        
        guard let r = try? db.pluck(query) else {return nil}
        
        guard let row = r else {return nil}
        
        return(cf: row[citationForm], gw: row[guideWord] ?? "")
    }
    
    func entryForRow(row: Int) -> GlossaryEntry? {
        let query = entries.filter(rowid == Int64(row))
        guard let r = try? db.pluck(query) else {return nil}
        
        guard let row = r else {return nil}
        
        guard let result: GlossaryEntry = try? row.decode() else {return nil}
        
        return result
        
    }
    
    
    init(){
        
    }
}

