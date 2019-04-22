//
//  Note.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 14/05/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Foundation
import CDKSwiftOracc

extension NSAttributedString.Key {
    static var referenceContext = NSAttributedString.Key("referenceContext")
}

struct Note: Codable {
    static let recordIdentifier = "Note"
    var id: TextID
    var notes: String
    
    init(id: TextID, notes: String){
        self.id = id
        self.notes = notes
    }
    
}
