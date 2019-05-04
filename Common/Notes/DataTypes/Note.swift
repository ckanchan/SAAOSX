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

extension Note {
    func formatted(withMetadata catalogueEntry: OraccCatalogEntry?) -> NSAttributedString {
        let str = NSMutableAttributedString()
        let title: String
        
        if let catalogueEntry = catalogueEntry {
            title = "\(catalogueEntry.displayName): \(catalogueEntry.title)"
        } else {
            title = String(self.id)
        }
        
        let formattedTitle = NSAttributedString(string: title,
                                                attributes: [
                                                             NSAttributedString.Key.font: NSFont.systemFont(ofSize: NSFont.systemFontSize)])
        let formattedNote = NSAttributedString(string: self.notes,
                                               attributes: [NSAttributedString.Key.font: NSFont.systemFont(ofSize: NSFont.systemFontSize)])
        
        str.append(formattedTitle)
        str.append(formattedNote)
        
        return NSAttributedString(attributedString: str)
    }
}
