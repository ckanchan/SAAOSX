//
//  CKRecord+Conversions.swift
//  SAAOSX
//
//  Created by Chaitanya Kanchan on 01/01/2019.
//  Copyright © 2019 Chaitanya Kanchan. All rights reserved.
//

import Foundation
import CDKSwiftOracc
import CloudKit.CKRecord

extension CKRecord {
    enum RecordTypes {
        static let Annotation = "Annotation"
        static let Note = "Note"
    }
    func toNote() -> Note? {
        guard self.recordType == RecordTypes.Note else {return nil}
        guard let textIDStr = self["textID"] as? String,
            let noteStr = self["notes"] as? String else {return nil}
        
        let textID = TextID.init(stringLiteral: textIDStr)
        return Note(id: textID, notes: noteStr)
    }
    
    func toAnnotation() -> Annotation? {
        guard self.recordType == RecordTypes.Annotation else {return nil}
        guard let nodeReferenceStr = self["nodeReference"] as? String,
            let transliteration = self["transliteration"] as? String,
            let normalisation = self["normalisation"] as? String,
            let translation = self["translation"] as? String,
            let context = self["context"] as? String,
            let annotationText = self["annotation"] as? String,
            let tags = self["tags"] as? [String] else {return nil}
        
        let nodeReference = NodeReference(stringLiteral: nodeReferenceStr)
        
        return Annotation(
            nodeReference: nodeReference,
            transliteration: transliteration,
            normalisation: normalisation,
            translation: translation,
            annotation: annotationText,
            context: context,
            tags: Set(tags))
    }
}
