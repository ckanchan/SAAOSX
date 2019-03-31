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
    enum RecordType {
        static let Annotation = "Annotation"
        static let Note = "Note"
    }
    func toNote() -> Note? {
        guard self.recordType == RecordType.Note else {return nil}
        guard let textIDStr = self["textID"] as? String,
            let noteStr = self["notes"] as? String else {return nil}
        
        let textID = TextID.init(stringLiteral: textIDStr)
        return Note(id: textID, notes: noteStr)
    }
    
    func toAnnotation() -> Annotation? {
        guard self.recordType == RecordType.Annotation else {return nil}
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

extension Note {
    func toCKRecord() -> CKRecord {
        let record = CKRecord(recordType: CKRecord.RecordType.Note)
        record["textID"] = self.id.description
        record["notes"] = self.notes
        return record
    }
}

extension Annotation {
    func toCKRecord() -> CKRecord {
        let record = CKRecord(recordType: CKRecord.RecordType.Annotation)
        record["textID"] = self.nodeReference.base.description
        record["nodeReference"] = self.nodeReference.description
        record["transliteration"] = self.transliteration
        record["normalisation"] = self.normalisation
        record["translation"] = self.translation
        record["context"] = self.context
        record["annotation"] = self.annotation
        record["tags"] = Array(self.tags)
        
        return record
    }
}
