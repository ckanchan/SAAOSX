//
//  Annotation.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 31/12/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Foundation
import CDKSwiftOracc

struct Annotation: Codable {
    let nodeReference: NodeReference
    let transliteration: String
    let normalisation: String
    let translation: String
    
    let context: String
    
    var annotation: String
    var tags: Set<Tag>
    
    
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

protocol SingleAnnotationDisplaying: AnyObject {
    func annotationDidChange(_ annotation: Annotation)
}
