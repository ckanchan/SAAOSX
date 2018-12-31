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
    static var referenceContext = NSAttributedString.Key.init("referenceContext")
}


struct Note: Codable {
    struct Annotation: Codable {
        let nodeReference: NodeReference
        let transliteration: String
        let normalisation: String
        let translation: String
        
        let context: String
        
        var annotation: String
        var tags: Set<String> 
        
        
        init(nodeReference: NodeReference, transliteration: String, normalisation: String, translation: String, annotation: String, context: String, tags: Set<String>) {
            self.nodeReference = nodeReference
            self.transliteration = transliteration
            self.normalisation = normalisation
            self.translation = translation
            self.annotation = annotation
            self.context = context
            self.tags = tags
        }
        
    }
    
    var id: TextID
    var notes: String
    var annotations: [NodeReference: Annotation]
    
    
    init(id: TextID, notes: String, annotations: [NodeReference: Annotation]){
        self.id = id
        self.notes = notes
        self.annotations = annotations
    }
    
}
