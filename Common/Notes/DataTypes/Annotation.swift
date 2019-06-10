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
    
    
    init(nodeReference: NodeReference, transliteration: String, normalisation: String, translation: String, annotation: String, context: String, tags: Set<Tag>) {
        self.nodeReference = nodeReference
        self.transliteration = transliteration
        self.normalisation = normalisation
        self.translation = translation
        self.annotation = annotation
        self.context = context
        self.tags = tags
    }
}


#if canImport(AppKit)
import AppKit.NSFont
extension Array where Element == Annotation {
    func formatted(withMetadata catalogueEntry: OraccCatalogEntry?) -> NSAttributedString? {
        guard !self.isEmpty else {return nil}
        let str = NSMutableAttributedString()
        let title: String
        
        if let catalogueEntry = catalogueEntry {
            title = "\(catalogueEntry.displayName): \(catalogueEntry.title)"
        } else {
            title = "Annotations for \(self[0].nodeReference.base)"
        }
        
        let formattedTitle = NSAttributedString(string: title,
                                                attributes: [
                                                             NSAttributedString.Key.font: NSFont.systemFont(ofSize: NSFont.systemFontSize)])
        
        str.append(formattedTitle)
        str.append(NSAttributedString(string: "\n"))
        for annotation in self {
            let annotationStr = """
            
            Context: \(annotation.context)
            Note: \(annotation.annotation)
            Tags: \(annotation.tags.joined(separator: "; "))
            
            """
            
            str.append(NSAttributedString(string: annotationStr,
                                          attributes: [NSAttributedString.Key.font: NSFont.systemFont(ofSize: NSFont.systemFontSize)]))
        }
        return str
    }
}
#endif
