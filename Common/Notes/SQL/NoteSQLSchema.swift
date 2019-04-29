//
//  NoteSQLSchema.swift
//  SAAo-SX
//
//  Created by Chaitanya Kanchan on 29/04/2019.
//  Copyright © 2019 Chaitanya Kanchan. All rights reserved.
//

import Foundation
import SQLite

extension NoteSQLDatabase {
    enum Schema {
        static var textID: Expression<String> { return Expression<String>("textid") }
        static var note: Expression<String> { return Expression<String>("note") }
        static var ckSystemFields: Expression<Data?> {return Expression<Data?>("ckSystemFields") }
        static var ckRecordID: Expression<Data?> { return Expression<Data?>("ckRecordID") }
        static var notesTable: Table { return Table("notes") }
        
        static var nodeReference: Expression<String> { return Expression<String>("nodeReference") }
        static var transliteration: Expression<String> { return Expression<String>("transliteration") }
        static var normalisation: Expression<String> { return Expression<String>("normalisation")}
        static var translation: Expression<String> { return Expression<String>("translation") }
        static var context: Expression<String> { return Expression<String>("context") }
        static var annotation: Expression<String> { return Expression<String>("annotation") }
        static var tags: Expression<String> { return Expression<String>("tags") }
        static var annotationTable: Table { return Table("annotations") }
    }
}


