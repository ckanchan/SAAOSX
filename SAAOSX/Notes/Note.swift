//
//  Note.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 14/05/2018.
//  Copyright © 2018 Chaitanya Kanchan. All rights reserved.
//

import Foundation
import CDKSwiftOracc

extension String {
    /// Formats a period-delimited path to a dashed one so it can be stored in Firebase
    var periodsToDashes: String {
        return self.replacingOccurrences(of: ".", with: "-")
    }
    
    /// Restores a period-delimited path from a dashed one so it can be reinitialised into a `Nodereference` (usually)
    var dashesToPeriods: String {
        return self.replacingOccurrences(of: "-", with: ".")
    }
}

extension NSAttributedStringKey {
    static var referenceContext = NSAttributedStringKey.init("referenceContext")
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
        
        var firebaseData: [String: Any] {
            return ["nodeReference": nodeReference.description,
                    "transliteration": transliteration,
                    "normalisation": normalisation,
                    "translation": translation,
                    "context": context,
                    "annotation": annotation,
                    "tags": Array(tags)
            ]
        }
        
        init(nodeReference: NodeReference, transliteration: String, normalisation: String, translation: String, annotation: String, context: String, tags: Set<String>) {
            self.nodeReference = nodeReference
            self.transliteration = transliteration
            self.normalisation = normalisation
            self.translation = translation
            self.annotation = annotation
            self.context = context
            self.tags = tags
        }
        
        init?(withFirebaseDictionary dictionary: [String: Any]) {
            guard let reference = dictionary["nodeReference"] as? String,
                let transliteration = dictionary["transliteration"] as? String,
                let normalisation = dictionary["normalisation"] as? String,
                let translation = dictionary["translation"] as? String,
                let context = dictionary["context"] as? String,
                let annotation = dictionary["annotation"] as? String else {return nil}
            
            let tags = dictionary["tags"] as? [String] ?? []
            let tagSet = Set(tags)

            let nodeReference = NodeReference.init(stringLiteral: reference)
            
            self.init(nodeReference: nodeReference, transliteration: transliteration, normalisation: normalisation, translation: translation, annotation: annotation, context: context, tags: tagSet)
            
        }
    }
    
    var id: TextID
    var notes: String
    var annotations: [NodeReference: Annotation]
    
    var firebaseData: [String: Any] {
        var encodedAnnotations = [String: Any]()
        annotations.forEach {encodedAnnotations[$0.key.description.periodsToDashes] = $0.value.firebaseData}
        let data: [String: Any] = ["id": self.id.description, "notes": self.notes, "annotations": encodedAnnotations]
        return data
    }
    
    init(id: TextID, notes: String, annotations: [NodeReference: Annotation]){
        self.id = id
        self.notes = notes
        self.annotations = annotations
    }
    
    init?(withFirebaseData data: [String: Any]) {
        var annotations = [NodeReference: Annotation]()
        if let encodedAnnotations = data["annotations"] as? [String: [String: Any]] {
            for (ref, annotation) in encodedAnnotations {
                let nodeReference = NodeReference.init(stringLiteral: ref.dashesToPeriods)
                let annotation = Annotation(withFirebaseDictionary: annotation)
                annotations[nodeReference] = annotation
            }
        }
        
        guard let id = data["id"] as? String ?? annotations.keys.first?.base.description else {return nil}
        let notes = data["notes"] as? String ?? ""
        
        
        self.init(id: TextID.init(stringLiteral: id), notes: notes, annotations: annotations)
    }
}
